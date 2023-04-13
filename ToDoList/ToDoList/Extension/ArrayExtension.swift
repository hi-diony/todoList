//
//  ArrayExtension.swift
//  ToDoList
//
//  Created by jiyeonpark on 2023/04/12.
//

import Foundation

extension Array {
    func hasIndex(_ index: Int) -> Bool {
        return indices.contains(index)
    }
}
