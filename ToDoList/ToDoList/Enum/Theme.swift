//
//  Theme.swift
//  ToDoList
//
//  Created by jiyeonpark on 2023/04/12.
//

import Foundation
import UIKit

enum Theme: CaseIterable {
    case pink
    case green
    case black
    
    var title: String {
        switch self {
        case .pink:
            return "발그레"
            
        case .green:
            return "잔디"
            
        case .black:
            return "그림자"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .pink:
            return .pink_0
            
        case .green:
            return .green_0
            
        case .black:
            return .black_0
        }
    }
    
    var navigationBarColor: UIColor {
        switch self {
        case .pink:
            return .pink_2
        
        case .green:
            return .green_2
            
        case .black:
            return .black_2
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .pink, .green:
            return .black
            
        case .black:
            return .white
        }
    }
    
    var placeHolderTextColor: UIColor {
        return textColor.withAlphaComponent(0.5)
    }
    
    var buttonTintColor: UIColor {
        switch self {
        case .pink:
            return .pink_3
            
        case .green:
            return .green_3
            
        case .black:
            return .black_3
        }
    }
    
    var accentColor: UIColor {
        switch self {
        case .pink:
            return .pink_3
            
        case .green:
            return .green_3
            
        case .black:
            return .black_3
        }
    }
}
