//
//  MapRepositoryImp.swift
//  Modungji
//
//  Created by 박준우 on 6/5/25.
//

import CoreLocation

struct MapRepositoryImp: MapRepository {
    private let networkManager: NetworkManager
    private let locationManager: LocationManager
    
    init(networkManager: NetworkManager, locationManager: LocationManager) {
        self.networkManager = networkManager
        self.locationManager = locationManager
    }
    
    func getEstateWithGeo(entity: GetEstateWithGeoRequestEntity) async throws -> [GetEstateWithGeoResponseEntity] {
        let response = try await self.networkManager.requestEstate(
            requestURL: EstateRouter.Estate.getEstateWithGeo(
                category: entity.category,
                longitude: entity.longitude,
                latitude: entity.latitude,
                maxDistance: entity.maxDistance
            ),
            successDecodingType: GetEstateWithGeoResponseDTO.self
        )
        switch response {
        case .success(let success):
            return success.data.map{ self.convertToEntity(dto: $0) }
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message, statusCode: failure.statusCode)
        }
    }
    
    func getEstateWithID(estateID: String) async throws -> GetEstateDetailResponseEntity {
        let response = try await self.networkManager.requestEstate(
            requestURL: EstateRouter.Estate.getEstateDetail(
                estateID: estateID
            ),
            successDecodingType: GetEstateDetailResponseDTO.self
        )
        switch response {
        case .success(let success):
            return self.convertToEntity(dto: success)
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message, statusCode: failure.statusCode)
        }
    }
    
    func getAuthorizationState() -> CLAuthorizationStatus {
        return self.locationManager.getAuthorizationState()
    }
    
    func requestWhenInUseAuthorization() {
        return self.locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        return self.locationManager.requestAlwaysAuthorization()
    }
    
    private func convertToEntity(dto: EstateWithGeoDTO) -> GetEstateWithGeoResponseEntity {
        return GetEstateWithGeoResponseEntity(
            estateId: dto.estateId,
            category: dto.category,
            title: dto.title,
            thumbnail: dto.thumbnails.first ?? "",
            deposit: dto.deposit,
            monthlyRent: dto.monthlyRent,
            area: dto.area,
            floors: dto.floors,
            geolocation: GeolocationEntity(
                latitude: dto.geolocation.latitude,
                longitude: dto.geolocation.longitude
            ),
            distance: dto.distance
        )
    }
    
    private func convertToEntity(dto: GetEstateDetailResponseDTO) -> GetEstateDetailResponseEntity {
        return GetEstateDetailResponseEntity(
            estateID: dto.estateId,
            category: dto.category,
            title: dto.title,
            introduction: dto.introduction,
            reservationPrice: dto.reservationPrice,
            thumbnails: dto.thumbnails,
            description: dto.description,
            deposit: dto.deposit,
            monthlyRent: dto.monthlyRent,
            builtYear: dto.builtYear,
            maintenanceFee: dto.maintenanceFee,
            area: dto.area,
            parkingCount: dto.parkingCount,
            floors: dto.floors,
            options: EstateOptionEntity(
                refrigerator: dto.options.refrigerator,
                washer: dto.options.washer,
                airConditioner: dto.options.airConditioner,
                closet: dto.options.closet,
                shoeRack: dto.options.shoeRack,
                microwave: dto.options.microwave,
                sink: dto.options.sink,
                tv: dto.options.tv
            ),
            geolocation: GeolocationEntity(
                latitude: dto.geolocation.latitude,
                longitude: dto.geolocation.longitude
            ),
            creator: UserEntity(
                userID: dto.creator.userId,
                nick: dto.creator.nick,
                introduction: dto.creator.introduction ?? "",
                profileImage: dto.creator.profileImage ?? ""
            ),
            isLiked: dto.isLiked,
            isReserved: dto.isReserved,
            likeCount: dto.likeCount,
            isSafeEstate: dto.isSafeEstate,
            isRecommended: dto.isRecommended,
            comments: dto.comments
                .map {
                    CommentEntity(
                        commentID: $0.commentId,
                        content: $0.content,
                        createdAt: $0.createdAt,
                        creator: UserEntity(
                            userID: $0.creator.userId,
                            nick: $0.creator.nick,
                            introduction: $0.creator.introduction ?? "",
                            profileImage: $0.creator.profileImage ?? ""
                        ),
                        replies: $0.replies
                            .map {
                                ReplyEntity(
                                    commentID: $0.commentId,
                                    content: $0.content,
                                    createdAt: $0.createdAt,
                                    creator: UserEntity(
                                        userID: $0.creator.userId,
                                        nick: $0.creator.nick,
                                        introduction: $0.creator.introduction ?? "",
                                        profileImage: $0.creator.profileImage ?? ""
                                    )
                                )
                            }
                    )
                },
            createdAt: dto.createdAt ?? "",
            updatedAt: dto.updatedAt ?? ""
        )
    }
}
