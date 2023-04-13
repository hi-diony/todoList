//
//  MainViewModel.swift
//  ToDoList
//
//  Created by 박지연 on 2023/03/15.
//

import Foundation
import RealmSwift
import RxRelay
import ReactorKit
import RxDataSources

class MainViewReactor: ReactorKit.Reactor {
    var initialState: State
    
    init() {
        guard let realm = try? Realm() else {
            initialState = State()
            return
        }
        
        let allTodo = realm.objects(TodoItem.self)
        
        let todoLists = allTodo.where {
            $0.finishedAt == nil
        }
            .sorted(byKeyPath: "createdAt", ascending: false)
        
        let doneLists = allTodo.where {
            $0.finishedAt != nil
        }
            .sorted(byKeyPath: "finishedAt", ascending: false)
        
        initialState = State(
            todoSection: SectionModel(model: .todo,
                                      items: todoLists.map { $0 }),
            doneSection: SectionModel(model: .done,
                                      items: doneLists.map { $0 })
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .add(let text):
            guard let realm = try? Realm() else {
                return .empty()
            }
            
            let todo = TodoItem()
            todo.text = text
            
            try? realm.write {
                realm.add(todo)
            }
            
            return .just(.completeRealmWrite(isAdd: true))
            
        case .delete(let indexPath):
            guard let item = itemForIndexPath(indexPath),
                  let realm = try? Realm() else {
                return .empty()
            }
            
            try? realm.write {
                realm.delete(item)
            }
            
            return .just(.completeRealmWrite(isAdd: false))
            
        case .changeFinish(let indexPath):
            guard let item = itemForIndexPath(indexPath),
                  let realm = try? Realm() else {
                return .empty()
            }
            
            try? realm.write {
                if item.finishedAt == nil {
                    item.finishedAt = Date()
                } else {
                    item.finishedAt = nil
                }
            }
            
            return .just(.completeRealmWrite(isAdd: false))
            
        case .changeTheme(let theme):
            return .just(.changeTheme(theme))
        }
    }
    
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .completeRealmWrite:
            guard let realm = try? Realm() else {
                break
            }
            
            let allTodo = realm.objects(TodoItem.self)
            
            state.todoSection.items = allTodo.where {
                    $0.finishedAt == nil
                }
                .sorted(byKeyPath: "createdAt", ascending: false)
                .map { $0 }
        
            state.doneSection.items = allTodo.where {
                    $0.finishedAt != nil
                }
                .sorted(byKeyPath: "finishedAt", ascending: false)
                .map { $0 }
            
        case .changeTheme(let theme):
            state.theme = theme
        }
        
        return state
    }
    
    private func itemForIndexPath(_ indexPath: IndexPath) -> TodoItem? {
        guard currentState.section.hasIndex(indexPath.section) else {
            return nil
        }
        
        let section = currentState.section[indexPath.section]
        guard section.items.hasIndex(indexPath.row) else {
            return nil
        }
        
        return section.items[indexPath.row]
    }
}


extension MainViewReactor {
    enum Action {
        // 할일 추가 삭제
        case add(String)
        case delete(IndexPath)
        case changeFinish(IndexPath)
        
        case changeTheme(Theme)
    }
    
    enum Mutation {
        case completeRealmWrite(isAdd: Bool)
        
        case changeTheme(Theme)
    }
    
    struct State {
        var todoSection = SectionModel(model: TodoGroup.todo, items: [TodoItem]())
        var doneSection = SectionModel(model: TodoGroup.done, items: [TodoItem]())

        var section: [SectionModel<TodoGroup, TodoItem>] {
            return [todoSection, doneSection]
        }
        
        var theme: Theme = .green
    }
}

extension MainViewReactor {
    enum TodoGroup: Equatable {
        case todo
        case done
    }
}
