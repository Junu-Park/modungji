//
//  DetailRepositoryImp.swift
//  Modungji
//
//  Created by 박준우 on 8/10/25.
//

import CoreLocation

struct DetailRepositoryImp: DetailRepository {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getEstateDetail(estateID: String) async throws -> GetEstateDetailResponseEntity {
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
    
    func updateEstateLike(estateID: String, request: UpdateEstateLikeRequestDTO) async throws -> UpdateEstateLikeResponseEntity {
        let response = try await self.networkManager.requestEstate(
            requestURL: EstateRouter.Estate.updateEstateLike(
                estateID: estateID,
                body: request
            ),
            successDecodingType: UpdateEstateLikeResponseDTO.self
        )
        switch response {
        case .success(let success):
            return self.convertToEntity(dto: success)
        case .failure(let failure):
            throw EstateErrorResponseEntity(message: failure.message, statusCode: failure.statusCode)
        }
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
            options: [
                EstateOptionEntity(name: "냉장고", image: .refrigerator, state: dto.options.refrigerator),
                EstateOptionEntity(name: "세탁", image: .washingMachine, state: dto.options.washer),
                EstateOptionEntity(name: "에어컨", image: .airConditioner, state: dto.options.airConditioner),
                EstateOptionEntity(name: "옷장", image: .closet, state: dto.options.closet),
                EstateOptionEntity(name: "신발장", image: .shoeCabinet, state: dto.options.shoeRack),
                EstateOptionEntity(name: "전자레인지", image: .microwave, state: dto.options.microwave),
                EstateOptionEntity(name: "싱크대", image: .sink, state: dto.options.sink),
                EstateOptionEntity(name: "TV", image: .television, state: dto.options.tv)
            ],
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
    
    private func convertToEntity(dto: UpdateEstateLikeResponseDTO) -> UpdateEstateLikeResponseEntity {
        return .init(likeStatus: dto.likeStatus)
    }
}
