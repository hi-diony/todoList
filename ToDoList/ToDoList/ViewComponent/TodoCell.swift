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
    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.isHidden = true
        lb.textAlignment = .right
        lb.font = .preferredFont(forTextStyle: .caption1)
        lb.textColor = .systemGray
        return lb
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit \(classForCoder)")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        checkImageView.image = nil
        label.attributedText = nil
        
        dateLabel.text = nil
        dateLabel.isHidden = true
    }
    
    private func initUI() {
        selectionStyle = .none
        backgroundColor = .systemGray5
        
        contentView.addSubview(checkImageView)
        checkImageView.snp.makeConstraints({ make in
            make.width.height.equalTo(20)
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        })
        
        let textStackView = UIStackView(arrangedSubviews: [label, dateLabel])
        textStackView.spacing = 5
        textStackView.axis = .vertical
        textStackView.distribution = .fill
        textStackView.alignment = .fill
        textStackView.isLayoutMarginsRelativeArrangement = true
        textStackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15)
        
        contentView.addSubview(textStackView)
        
        textStackView.snp.makeConstraints({ make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(checkImageView.snp.right)
        })
    }
    
    
    func setData(todo: ToDo) {
        switch todo.isDone {
        case true:
            checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
            label.attributedText = todo.text
                .toMutableAttributedString()
                .setFontColor(to: .systemGray3)
                .setCancelLine(to: .systemGray3)
                
            if let finishTime = todo.finishedAt?.toString("yyyy.MM.dd HH:mm") {
                dateLabel.text = finishTime
                dateLabel.isHidden = false
            }
            
        case false:
            checkImageView.image = UIImage(systemName: "circle")
            label.attributedText = todo.text
                .toMutableAttributedString()
                .setFontColor(to: .label)
                .removeCancelLine()
            
            dateLabel.text = nil
            dateLabel.isHidden = true
        }
    }
}

