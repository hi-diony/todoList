//
//  UIViewExtension.swift
//  ToDoList
//
//  Created by jiyeonpark on 2023/04/13.
//

import Foundation
import UIKit

extension UIView {
    func addLineToBottom(color: UIColor = .separator) {
        let lineView = UIView()
        lineView.backgroundColor = color
        addSubview(lineView)
        
        lineView.snp.makeConstraints {
            $0.height.equalTo(1/UIScreen.main.scale)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
