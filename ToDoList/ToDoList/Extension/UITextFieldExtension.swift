//
//  UITextFieldExtension.swift
//  ToDoList
//
//  Created by jiyeonpark on 2023/04/12.
//

import Foundation
import UIKit

extension UITextField {
    @IBInspectable
    var placeHolderColor: UIColor {
        get {
            guard let color = attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor else {
                return .placeholderText
            }
            return color
        }
        
        set {
            let text = placeholder ?? attributedPlaceholder?.string
            guard let text = text else {
                return
            }
            
            attributedPlaceholder = text
                .toMutableAttributedString()
                .setFontColor(to: newValue)
        }
    }
}
