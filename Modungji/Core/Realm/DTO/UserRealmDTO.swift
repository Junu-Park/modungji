//
//  UserRealmDTO.swift
//  Modungji
//
//  Created by 박준우 on 8/20/25.
//

import Foundation

import RealmSwift

final class UserRealmDTO: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var nick: String
    @Persisted var profileImage: String
    @Persisted var introduction: String
}
