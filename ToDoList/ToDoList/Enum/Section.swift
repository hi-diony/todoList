//
//  Section.swift
//  ToDoList
//
//  Created by 박지연 on 2023/03/15.
//

import Foundation

enum Section: Int, CaseIterable {
    case Todo = 0
    case Done
    
    var sectionTitle: String {
        switch self {
        case .Todo:
            return "TODO"
            
        case .Done:
            return "DONE"
        }
    }
}
