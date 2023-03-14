//
//  NSMutableAttributedString.swift
//  ToDoList
//
//  Created by 박지연 on 2023/03/14.
//

import Foundation
import UIKit

/* 스타일 변경 */
public extension NSMutableAttributedString {
    @objc func setFont(_ font: UIFont, rangeString: String? = nil) -> NSMutableAttributedString {
        let r: NSRange
        if let ranges = rangeString {
            let range = self.mutableString.range(of: ranges)
            if range.location != NSNotFound {
                r = range
            } else {
                r = NSRange(location: 0, length: mutableString.length)
            }
        } else {
            r = NSRange(location: 0, length: mutableString.length)
        }
        
        addAttribute(.font,
                     value: font,
                     range: r)
        return self
    }
    
    @objc func setBackgroundColor(to color: UIColor, rangeString: String? = nil) -> NSMutableAttributedString {
        let r: NSRange
        if let ranges = rangeString {
            let range = self.mutableString.range(of: ranges)
            if range.location != NSNotFound {
                r = range
            } else {
                r = NSRange(location: 0, length: mutableString.length)
            }
        } else {
            r = NSRange(location: 0, length: mutableString.length)
        }
        
        addAttribute(.backgroundColor,
                     value: color,
                     range: r)
        return self
    }
    
    @objc func setFontColor(to color: UIColor, rangeString: String? = nil) -> NSMutableAttributedString {
        let r: NSRange
        if let ranges = rangeString {
            let range = self.mutableString.range(of: ranges)
            if range.location != NSNotFound {
                r = range
            } else {
                r = NSRange(location: 0, length: mutableString.length)
            }
        } else {
            r = NSRange(location: 0, length: mutableString.length)
        }
        
        addAttribute(.foregroundColor,
                     value: color,
                     range: r)
        return self
    }
    
    @objc func setUnderLine(to color: UIColor, rangeString: String? = nil) -> NSMutableAttributedString {
        let r: NSRange
        if let ranges = rangeString {
            let range = self.mutableString.range(of: ranges)
            if range.location != NSNotFound {
                r = range
            } else {
                r = NSRange(location: 0, length: mutableString.length)
            }
        } else {
            r = NSRange(location: 0, length: mutableString.length)
        }
        
        addAttribute(.underlineStyle,
                     value: NSUnderlineStyle.single.rawValue,
                     range: r)
        addAttribute(.underlineColor,
                     value: color,
                     range: r)
        return self
    }
    
    @objc func setCancelLine(to color: UIColor, rangeString: String? = nil) -> NSMutableAttributedString {
        let r: NSRange
        if let ranges = rangeString {
            let range = self.mutableString.range(of: ranges)
            if range.location != NSNotFound {
                r = range
            } else {
                r = NSRange(location: 0, length: mutableString.length)
            }
        } else {
            r = NSRange(location: 0, length: mutableString.length)
        }
        
        addAttribute(.strikethroughStyle,
                     value: NSUnderlineStyle.single.rawValue,
                     range: r)
        addAttribute(.strokeColor,
                     value: color,
                     range: r)
        return self
    }
    
    @objc func removeCancelLine(rangeString: String? = nil) -> NSMutableAttributedString {
        let r: NSRange
        if let ranges = rangeString {
            let range = self.mutableString.range(of: ranges)
            if range.location != NSNotFound {
                r = range
            } else {
                r = NSRange(location: 0, length: mutableString.length)
            }
        } else {
            r = NSRange(location: 0, length: mutableString.length)
        }
        
        removeAttribute(.strikethroughStyle, range: r)
        removeAttribute(.strokeColor, range: r)
        
        return self
    }
    
    /* 처음부터 현재까지 적용 */
    @discardableResult
    @objc func setParagraphStyle(_ style: NSParagraphStyle) -> NSMutableAttributedString {
        addAttribute(.paragraphStyle,
                     value: style,
                     range: NSRange(location: 0, length: mutableString.length))
        return self
    }
    
    @objc func toLink(url link: String, isBlueUnderline: Bool = false) -> NSMutableAttributedString {
        addAttribute(.link,
                     value: link,
                     range: NSRange(location: 0, length: mutableString.length))
        return self
    }
    
    func setLineSpacing(_ lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()

        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = lineSpacing // Whatever line spacing you want in points

        // *** Apply attribute to string ***
        addAttribute(NSAttributedString.Key.paragraphStyle,
                     value: paragraphStyle,
                     range: NSRange(location: 0, length: length))
    }
}

public extension NSMutableAttributedString {
    @objc func append(_ string: String) {
        append(NSAttributedString(string: string))
    }
    
    func append(_ image: UIImage?, size: CGSize? = nil, in font: UIFont? = nil) {
        let attachment = NSTextAttachment()
        attachment.image = image
        
        guard let s = size else {
            append(NSAttributedString(attachment: attachment))
            return
        }
        
        guard let f = font else {
            attachment.bounds.size = s
            append(NSAttributedString(attachment: attachment))
            return
        }
            
        let y: CGFloat = (f.capHeight - s.height).rounded() / 2
        
        attachment.bounds = CGRect(x: 0,
                                   y: y,
                                   width: s.width,
                                   height: s.height)
        
        append(NSAttributedString(attachment: attachment))
        
        if y < 0,
           s.height - y/4 <= f.lineHeight {
            addAttribute(.baselineOffset, value: y/4, range: NSRange(location: 0, length: length))
        }
    }
}
