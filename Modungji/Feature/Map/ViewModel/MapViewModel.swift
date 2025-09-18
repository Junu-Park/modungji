//
//  MapViewModel.swift
//  Modungji
//
//  Created by 박준우 on 6/5/25.
//

import Combine

import NMapsMap

final class MapViewModel: ObservableObject {
    
    struct State {
        var currentAddress: String = ""
        var searchQuery: String = ""
        var selectedOptionType: MapOptionType?
        var selectedCategory: EstateCategory?
        var centerLocation: GeolocationEntity = GeolocationEntity(latitude: 37.5666805, longitude: 126.9784147)
        var maxDistance: Int?
        var showCurrentLocationMarker: Bool = false
        var filteredEstateList: [GetEstateWithGeoResponseEntity] = []
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
        var shouldMoveCamera: Bool = false
    }
    
    enum Action {
        case inputSearchQuery(query: String)
        case tapOption(option: MapOptionType?)
        case selectCategory(category: EstateCategory?)
        case moveCamera(entity: NaverMapEntity)
        case completeMoveCamera
        case tapCurrentLocationButton
        case tapEstate(estateID: String)
        case tapBackButton
        case search
    }
    
    @Published var state: State = State()
    private var cancellables: Set<AnyCancellable> = []
    private let service: MapService
    private let pathModel: PathModel
    private var estateList: [GetEstateWithGeoResponseEntity] = []
    
    init(service: MapService, pathModel: PathModel, selectedCategory: EstateCategory? = nil) {
        self.service = service
        self.pathModel = pathModel
        self.state.selectedCategory = selectedCategory
        
        self.transform()
    }
    
    func transform() {
        Publishers.CombineLatest3(
            self.$state.map(\.selectedCategory),
            self.$state.map(\.centerLocation),
            self.$state.map(\.maxDistance)
        )
        .dropFirst()
        .removeDuplicates(by: ==)
        .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
        .sink { [weak self] category, centerLocation, maxDistance  in
            guard let self else { return }
            Task {
                do {
                    let entity = GetEstateWithGeoRequestEntity(
                        category: nil,
                        longitude: centerLocation.longitude,
                        latitude: centerLocation.latitude,
                        maxDistance: maxDistance
                    )
                    
                    async let listResponse = self.service.getEstateWithGeo(entity: entity)
                    async let addressResponse = self.service.getAddress(coords: centerLocation)
                    
                    let (list, address) = try await (listResponse, addressResponse)
                    
                    self.estateList = list
                    
                    await MainActor.run {
                        self.state.filteredEstateList = self.estateList.filter { entity in
                            entity.category == self.state.selectedCategory?.rawValue
                        }
                        self.state.currentAddress = address
                    }
                } catch let error as EstateErrorResponseEntity {
                    await MainActor.run {
                        self.state.errorMessage = error.message
                        self.state.showErrorAlert = true
                    }
                }
            }
        }
        .store(in: &self.cancellables)
    }
    
    func action(_ action: Action) {
        switch action {
        case .inputSearchQuery(let query):
            self.state.searchQuery = query
        case .tapOption(let option):
            self.state.selectedOptionType = option
        case .selectCategory(let category):
            self.selectCategory(category)
        case .moveCamera(let entity):
            self.moveCamera(entity: entity)
        case .tapCurrentLocationButton:
            self.tapCurrentLocationButton()
        case .tapEstate(let estateID):
            self.tapEstate(estateID: estateID)
        case .tapBackButton:
            self.tapBackButton()
        case .search:
            self.search()
        case .completeMoveCamera:
            self.state.shouldMoveCamera = false
        }
    }
    
    private func selectCategory(_ category: EstateCategory?) {
        self.state.selectedCategory = category
        self.state.shouldMoveCamera = true
    }
    
    private func moveCamera(entity: NaverMapEntity) {
        if !self.state.filteredEstateList.isEmpty {
            self.state.filteredEstateList.removeAll()
        }
        
        self.state.centerLocation = entity.centerLocation
        
        let maxDistance = entity.centerLocation.getMeterDistance(with: entity.southLocation)
        self.state.maxDistance = maxDistance
    }
    
    
    private func tapCurrentLocationButton() {
        if self.state.showCurrentLocationMarker {
            self.state.showCurrentLocationMarker = false
        } else {
            Task {
                do {
                    let isPermitted = try await self.service.getUserLocation()
                    
                    await MainActor.run {
                        self.state.showCurrentLocationMarker = isPermitted
                    }
                } catch let error as EstateErrorResponseEntity {
                    await MainActor.run {
                        self.state.errorMessage = error.message
                        self.state.showErrorAlert = true
                    }
                }
            }
        }
    }
    
    private func tapEstate(estateID: String) {
        self.pathModel.push(.detail(estateID: estateID))
    }
    
    private func search() {
        if self.state.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.state.errorMessage = "올바른 검색어를 입력해주세요."
            self.state.showErrorAlert = true

            return
        }

        Task {
            do {
                let coord = try await self.service.getCoordinator(query: self.state.searchQuery)
                await MainActor.run {
                    self.state.centerLocation = coord.geolocation
                    self.state.shouldMoveCamera = true
                }
            } catch let error as EstateErrorResponseEntity {
                await MainActor.run {
                    self.state.errorMessage = error.message
                    self.state.showErrorAlert = true
                }
            } catch {
                await MainActor.run {
                    self.state.errorMessage = error.localizedDescription
                    self.state.showErrorAlert = true
                }
            }
        }
    }
    
    private func tapBackButton() {
        self.state.filteredEstateList.removeAll()
        self.state.shouldMoveCamera = true
        self.pathModel.pop()
    }
}
