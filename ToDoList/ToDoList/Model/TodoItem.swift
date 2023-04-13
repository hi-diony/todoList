//
//  ToDo.swift
//  ToDoList
//
//  Created by 박지연 on 2023/03/14.
//

import Foundation
import RxRealm
import RealmSwift
import Differentiator

/* refs
 https://ali-akhtar.medium.com/rxrealm-realmswift-part-7-cf83c4a3edb5
 https://github.com/RxSwiftCommunity/RxRealm
 http://rx-marin.com/post/dotswift-rxswift-rxrealm-unidirectional-dataflow/
 */
class TodoItem: Object, IdentifiableType {
    typealias Identity = ObjectId
    
    var identity: RealmSwift.ObjectId {
        // RxTableViewSectionedAnimatedDataSource
        return _id
    }
    
    @Persisted(primaryKey: true) var _id: ObjectId
    
    @Persisted var text: String
    @Persisted var createdAt = Date() // 생성 시점
    @Persisted var finishedAt: Date? = nil // 종료 시점
    
    var isDone: Bool {
        return finishedAt != nil
    }
}
