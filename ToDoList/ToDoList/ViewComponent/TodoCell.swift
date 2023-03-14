//
//  TodoCell.swift
//  ToDoList
//
//  Created by 박지연 on 2023/03/08.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RealmSwift

class TodoCell: UITableViewCell {
    static let IDENTIFIER = "TodoCell"
    
    private let checkImageView = UIImageView()
    private let label = UILabel()
    
    private let disposeBag = DisposeBag()
//
//    override var isSelected: Bool {
//        didSet {
//            switch isSelected {
//            case false:
//                checkImageView.image = UIImage(systemName: "circle")
//                label.attributedText = label.attributedText?.string
//                    .toMutableAttributedString()
//                    .setFontColor(to: .label)
//                    .removeCancelLine()
//
//            case true:
//                checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
//                label.attributedText = label.attributedText?.string
//                    .toMutableAttributedString()
//                    .setFontColor(to: .systemGray4)
//                    .setCancelLine(to: .systemGray4)
//            }
//        }
//    }
//
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initUI()
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        backgroundColor = .systemGray5
        
        checkImageView.snp.makeConstraints({ make in
            make.height.greaterThanOrEqualTo(checkImageView.snp.width)
        })
//
//        let textFieldContainerView = UIView()
//        textFieldContainerView.addSubview(textField)
//        textField.snp.makeConstraints({ make in
//            make.edges.equalTo(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
//        })
        
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.addArrangedSubview(checkImageView)
        stackView.addArrangedSubview(label)
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
    
    private func bind() {
//        checkButton.rx.tap
//            .bind(with: self,
//                  onNext: { owner, _ in
//                owner.checkButton.isSelected.toggle()
//            })
//            .disposed(by: disposeBag)
    }
    
    
    
    func setData(todo: ToDo) {
        switch todo.isDone {
        case true:
            checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
            label.attributedText = todo.text
                .toMutableAttributedString()
                .setFontColor(to: .systemGray4)
                .setCancelLine(to: .systemGray4)
            
        case false:
            checkImageView.image = UIImage(systemName: "circle")
            label.attributedText = todo.text
                .toMutableAttributedString()
                .setFontColor(to: .label)
                .removeCancelLine()
        }
    }
}

