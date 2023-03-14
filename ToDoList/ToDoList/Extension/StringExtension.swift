//
//  StringExtension.swift
//  ToDoList
//
//  Created by 박지연 on 2023/03/14.
//

import Foundation

public extension String {
    func toAttributedString() -> NSAttributedString {
        return NSAttributedString(string: self)
    }
    
    func toMutableAttributedString() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    func removeWhiteSpace() -> String {
        return replacingOccurrences(of: " ", with: "")
    }
}
