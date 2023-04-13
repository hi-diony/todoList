//
//  IntExtension.swift
//  ToDoList
//
//  Created by jiyeonpark on 2023/04/13.
//

import Foundation

extension Int {
    func asMoney() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        let number = NSNumber(value: self)
        return formatter.string(from: number) ?? "\(self)"
    }
}
