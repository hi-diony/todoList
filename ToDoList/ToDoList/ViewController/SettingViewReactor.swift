//
//  SettingViewReactor.swift
//  ToDoList
//
//  Created by jiyeonpark on 2023/04/14.
//

import Foundation
import ReactorKit
import RxSwift

class SettingViewReactor: ReactorKit.Reactor {
    var initialState: State

    init() {
        initialState = State()
    }

}

extension SettingViewReactor {
    enum Action {
    }

    enum Mutation {
    }

    struct State {
        let items = Category.allCases
    }
}

extension SettingViewReactor {
    enum Category: CaseIterable {
        case theme
        case font
        
        var title: String {
            switch self {
            case .theme:
                return "테마"
                
            case .font:
                return "폰트"
            }
        }
    }
}
