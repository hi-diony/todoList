//
//  MainViewModel.swift
//  ToDoList
//
//  Created by 박지연 on 2023/03/15.
//

import Foundation
import RxSwift
import RealmSwift
import RxRelay

/// refs
/// - 좀더 mvvm의 구조를 구조적으로 가져가는 방법..?
///     -  https://coding-idiot.tistory.com/7
///     - https://ios-development.tistory.com/140
final class MainViewModel {
    /// input
    let itemDeleted = PublishRelay<IndexPath>()
    let itemSelected = PublishRelay<IndexPath>()
    let endEditing = PublishRelay<String>()
    
    /// output
    // 기본적으로 subject는 background thread를 사용한다.
    // UI와 같은 처리를 하고 싶다면 driver 사용하기
    let todos = BehaviorSubject(value: [
        Section.Todo: [ToDo](),
        Section.Done: [ToDo]()
    ])
    
    private let disposeBag = DisposeBag()
    
    init() {
        guard let realm = try? Realm() else {
            return
        }
        
        // realm
        let allTodos = realm.objects(ToDo.self)
        Observable.changeset(from: allTodos)
            .subscribe(with: self,
                       onNext: { owner, realmChanges in
                let results = realmChanges.0
                
                let newTodo = results
                            .where({ $0.finishedAt == nil })
                            .sorted(byKeyPath: "createdAt", ascending: false)

                let newDone = results
                            .where({ $0.finishedAt != nil })
                            .sorted(byKeyPath: "finishedAt", ascending: false)

                // 새로운 값 전송
                let newTodos = [
                        Section.Todo: Array(newTodo),
                        Section.Done: Array(newDone)
                ]
                
                owner.todos.onNext(newTodos)
            })
            .disposed(by: disposeBag)
        
        // 삭제
        itemDeleted.bind(with: self,
                         onNext: { owner, indexPath in
            guard let sections = try? owner.todos.value(),
                  let section = Section(rawValue: indexPath.section),
                  let todos = sections[section] else {
                return
            }
            
            let todo = todos[indexPath.row]
            guard let realm = try? Realm() else {
                return
            }
            
            try? realm.write {
                realm.delete(todo)
            }

        })
        .disposed(by: disposeBag)
        
        // 상태 변경
        itemSelected.bind(with: self,
                          onNext: { owner, indexPath in
            // 해당 아이템이 터치될때마다 finish 상태가 바뀜
            guard let sections = try? owner.todos.value(),
                  let section = Section(rawValue: indexPath.section),
                  let todos = sections[section] else {
                return
            }
            
            let todo = todos[indexPath.row]
            guard let realm = try? Realm() else {
                return
            }
            
            try? realm.write {
                switch todo.isDone {
                case true:
                    // 다시 TODO항목으로 추가된다면 생성일이 최근으로 바뀐다
                    todo.createdAt = Date()
                    todo.finishedAt = nil
                    
                case false:
                    todo.finishedAt = Date()
                }
            }
        })
        .disposed(by: disposeBag)
        
        endEditing.bind(with: self,
                        onNext: { owner, text in
            guard let realm = try? Realm() else {
                return
            }

            // 데이터 추가
            let newTodo = ToDo()
            newTodo.text = text

            try? realm.write({
                realm.add(newTodo)
            })
        })
        .disposed(by: disposeBag)
    }
    
}
