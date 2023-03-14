//
//  DateExtension.swift
//  ToDoList
//
//  Created by 박지연 on 2023/03/15.
//

import Foundation

public extension Date {
    func toString(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
//        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return dateFormatter.string(from: self)
    }
}
