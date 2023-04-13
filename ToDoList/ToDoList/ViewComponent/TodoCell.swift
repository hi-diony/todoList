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
    
    // MARK: -UI
    private let checkImageView = UIImageView()
    private let label: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        return lb
    }()
    
    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.isHidden = true
        lb.textAlignment = .right
        lb.font = .preferredFont(forTextStyle: .caption1)
        lb.textColor = .systemGray // TODO
        return lb
    }()
    
    // MARK: -Property
    var theme = PublishSubject<Theme>()
    var todo = PublishSubject<TodoItem>()
    
    private var disposeBag = DisposeBag()
    
    // MARK: -Function
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initUI()
        
        bind()
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
        backgroundColor = .clear
        
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
    
    
//    func setData(todo: TodoItem) {
//        switch todo.isDone {
//        case true:
//            checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
//            label.attributedText = todo.text
//                .toMutableAttributedString()
//                .setFontColor(to: .systemGray3)
//                .setCancelLine(to: .systemGray3)
//
//            if let finishTime = todo.finishedAt?.toString("yyyy.MM.dd HH:mm") {
//                dateLabel.text = finishTime
//                dateLabel.isHidden = false
//            }
//
//        case false:
//            checkImageView.image = UIImage(systemName: "circle")
//            label.attributedText = todo.text
//                .toMutableAttributedString()
//                .setFontColor(to: .label)
//                .removeCancelLine()
//
//            dateLabel.text = nil
//            dateLabel.isHidden = true
//        }
//    }
    
    private func bind() {
        Observable.combineLatest(todo, theme)
            .bindOnMain(onNext: { [weak self] todo, theme in
                guard let self = self else { return }
                self.checkImageView.tintColor = theme.buttonTintColor
                
                switch todo.isDone {
                case true:
                    self.checkImageView.image = UIImage(systemName: "checkmark.circle.fill")?
                        .withRenderingMode(.alwaysTemplate)
                        .withTintColor(theme.buttonTintColor)

                    self.label.attributedText = todo.text
                        .toMutableAttributedString()
                        .setFontColor(to: theme.placeHolderTextColor)
                        .setCancelLine(to: theme.placeHolderTextColor)
                        
                    if let finishTime = todo.finishedAt?.toString("yyyy.MM.dd HH:mm") {
                        self.dateLabel.text = finishTime
                        self.dateLabel.isHidden = false
                    }
                    
                case false:
                    self.checkImageView.image = UIImage(systemName: "circle")?
                        .withRenderingMode(.alwaysTemplate)
                        .withTintColor(theme.buttonTintColor)
                    
                    self.label.attributedText = todo.text
                        .toMutableAttributedString()
                        .setFontColor(to: theme.textColor)
                        .removeCancelLine()
                    
                    self.dateLabel.text = nil
                    self.dateLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
}
