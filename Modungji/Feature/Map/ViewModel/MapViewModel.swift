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
        var category: Category?
        var centerLocation: GeolocationEntity = GeolocationEntity(latitude: 37.5666805, longitude: 126.9784147)
        var maxDistance: Int?
        var showCurrentLocationMarker: Bool = false
        var estateList: [GetEstateWithGeoResponseEntity] = []
        var showErrorAlert: Bool = false
        var errorMessage: String = ""
    }
    
    enum Action {
        case moveCamera(entity: NaverMapEntity)
        case tapCurrentLocationButton
        case tapEstate(estateID: String)
    }
    
    @Published var state: State = State()
    private var cancellables: Set<AnyCancellable> = []
    private let service: MapService
    private let pathModel: PathModel
    
    init(service: MapService, pathModel: PathModel) {
        self.service = service
        self.pathModel = pathModel
        
        self.transform()
    }
    
    func transform() {
        Publishers.CombineLatest3(
            self.$state.map(\.category),
            self.$state.map(\.centerLocation),
            self.$state.map(\.maxDistance)
        )
        .dropFirst()
        .removeDuplicates(by: ==)
        .debounce(for: .seconds(0.7), scheduler: RunLoop.main)
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
                    
                    let result = try await self.service.getEstateWithGeo(entity: entity)
                    
                    await MainActor.run {
                        self.state.estateList = result
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
        case .moveCamera(let entity):
            self.moveCamera(entity: entity)
        case .tapCurrentLocationButton:
            self.tapCurrentLocationButton()
        case .tapEstate(let estateID):
            self.tapEstate(estateID: estateID)
        }
    }
    
    private func moveCamera(entity: NaverMapEntity) {
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
}
