//
//  SettingViewController.swift
//  ToDoList
//
//  Created by jiyeonpark on 2023/04/14.
//

import Foundation
import UIKit
import RxSwift
import ReactorKit
import RxCocoa

class SettingViewController: UIViewController, ReactorKit.View {
    static let CELL_IDENTIFIER = "UITableViewCell"
    
    // MARK: -UI
    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.register(UITableViewCell.self,
                   forCellReuseIdentifier: SettingViewController.CELL_IDENTIFIER)
        return t
    }()
    
    // MARK: -Property
    var disposeBag = DisposeBag()
    
    // MARK: Method
    init() {
        super.init(nibName: nil, bundle: nil)
        
        reactor = SettingViewReactor()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initLayout()
    }
    
    func bind(reactor: SettingViewReactor) {
        bindState(reactor: reactor)
        bindAction(reactor: reactor)
    }
    
    private func initLayout() {
        title = "설정"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bindAction(reactor: SettingViewReactor) {

    }
    
    private func bindState(reactor: SettingViewReactor) {
        reactor.state
            .map { $0.items }
            .bind(to: tableView.rx.items(cellIdentifier: SettingViewController.CELL_IDENTIFIER)) { row, item, cell in
                //                let config = UIContentConfiguration()
                //                config.text = item.title
                //                cell.contentConfiguration = config
                ////                cell.contentConfiguration = UIListContentConfiguration()
                ////                cell.contentConfiguration.
            }
            .disposed(by: disposeBag)
    }
}

