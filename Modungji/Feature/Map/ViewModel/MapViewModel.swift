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
        var selectedMaxAreaLevel: Double = 0
        var selectedMaxMonthlyRentLevel: Double = 12
        var selectedMaxDepositLevel: Double = 22
        var centerLocation: GeolocationEntity = GeolocationEntity(latitude: 37.5666805, longitude: 126.9784147)
        var maxDistance: Int?
        var showCurrentLocationMarker: Bool = false
        var filteredEstateList: [GetEstateWithGeoResponseEntity] = []
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
        var shouldMoveCamera: Bool = false
        var shouldReloadData: Bool = false
    }
    
    enum Action {
        case inputSearchQuery(query: String)
        case tapOption(option: MapOptionType?)
        case selectCategory(category: EstateCategory?)
        case moveCamera(entity: NaverMapEntity)
        case completeMoveCamera
        case completeReloadData
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
        Publishers.CombineLatest4(self.$state.map(\.selectedCategory), self.$state.map(\.selectedMaxAreaLevel), self.$state.map(\.selectedMaxDepositLevel), self.$state.map(\.selectedMaxMonthlyRentLevel))
            .dropFirst()
            .removeDuplicates(by: ==)
            .debounce(for: .seconds(0.7), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.state.filteredEstateList = await self.filteringEstateList()
                    self.state.shouldReloadData = true
                }
            }
            .store(in: &self.cancellables)
        
        Publishers.CombineLatest(
            self.$state.map(\.centerLocation),
            self.$state.map(\.maxDistance)
        )
        .dropFirst()
        .removeDuplicates(by: ==)
        .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
        .sink { [weak self] centerLocation, maxDistance  in
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
                    
                    let filtered = await self.filteringEstateList()
                    
                    await MainActor.run {
                        self.state.filteredEstateList = filtered
                        self.state.currentAddress = address
                        self.state.shouldReloadData = true
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
            self.state.selectedCategory = category
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
            Task { @MainActor in
                self.state.shouldMoveCamera = false
            }
        case .completeReloadData:
            Task { @MainActor in
                self.state.shouldReloadData = false
            }
        }
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
    
    private func filteringEstateList() async -> [GetEstateWithGeoResponseEntity] {
        return self.estateList.filter { entity in
            let category = self.state.selectedCategory?.rawValue == nil ? true : entity.category == self.state.selectedCategory?.rawValue
            
            return category && entity.area >= self.convertAreaLevel() && entity.deposit <= self.convertDepositLevel() && entity.monthlyRent <= self.convertMonthlyRentLevel()
        }
    }
    
    private func convertAreaLevel() -> Double {
        let result: Double
        let lv = self.state.selectedMaxAreaLevel
        
        switch lv {
        case 1...10: result = lv * 5
        default: result = 1
        }
        return result
    }
    
    private func convertMonthlyRentLevel() -> Int {
        let result: Int
        let lv = Int(self.state.selectedMaxMonthlyRentLevel)
        
        switch lv {
        case 1...11: result = lv * 100_000
        case 12...: result = Int.max
        default: result = 0
        }
        return result
    }
    
    private func convertDepositLevel() -> Int {
        let result: Int
        let lv = Int(self.state.selectedMaxDepositLevel)
        
        switch lv {
        case 1...10: result = lv * 1_000_000
        case 11...18: result = (Int(lv / 10) + Int(lv) % Int(10)) * 10_000_000
        case 19: result = 100_000_000
        case 20: result = 150_000_000
        case 21: result = 200_000_000
        case 22: result = Int.max
        default: result = 0
        }
        
        return result
    }
}
