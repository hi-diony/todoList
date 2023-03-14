//
//  MainViewController.swift
//  ToDoList
//
//  Created by 박지연 on 2023/03/08.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import RxDataSources

class MainViewController: UIViewController {
    private let textField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .systemGray6
        tf.placeholder = "해야할 일을 적어주세요."
        tf.leftViewMode = .always
        tf.leftView = UIView(frame: CGRect(x: 1, y: 1, width: 20, height: 1))
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .done
        return tf
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .systemGray5
        tv.allowsMultipleSelection = false
        tv.keyboardDismissMode = .interactiveWithAccessory
        tv.register(TodoCell.self, forCellReuseIdentifier: TodoCell.IDENTIFIER)
        return tv
    }()
    
    private let viewModel: MainViewModel
    private let disposeBag = DisposeBag()
    private var sections = BehaviorSubject(value: [
        SectionModel(model: Section.Todo.sectionTitle, items: [ToDo]()),
        SectionModel(model: Section.Done.sectionTitle, items: [ToDo]())
    ])
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bind(to: viewModel)
    }
    
    private func initUI() {
        let navigationView = UIView()
        navigationView.backgroundColor = .systemGray6
        view.addSubview(navigationView)
        navigationView.snp.makeConstraints({ make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        })
        
        navigationView.addSubview(textField)
        textField.snp.makeConstraints({ make in
            make.top.equalTo(navigationView.safeAreaLayoutGuide)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(40)
        })
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints({ make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        })
    }
    
    private func bind(to viewModel: MainViewModel) {
        /// 테이블뷰
        // 데이터소스(셀 설정)
        // tableView와 Realm 바인딩 : https://stackoverflow.com/questions/48577819/how-to-bind-realm-object-to-uiswitch-using-rxswift-and-rxrealm
        // animated datasource로 하면 삭제시 앱 크래시 되는 이슈 있음 - https://github.com/RxSwiftCommunity/RxDataSources/issues/197
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, ToDo>>(
            configureCell: { dataSource, tableView, indexPath, todo in
                let cell: TodoCell = {
                    guard let c = tableView.dequeueReusableCell(withIdentifier: TodoCell.IDENTIFIER) as? TodoCell else {
                        return TodoCell()
                    }
                    return c
                }()
                
                cell.setData(todo: todo)
                return cell
            },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
            },
            canEditRowAtIndexPath: { _, _ in
                return true
            }
        )

        let todos = viewModel.todos
            .distinctUntilChanged() // 연달아 중복된 값이 올 경우 무시
            .observe(on:MainScheduler.asyncInstance)
        
        todos
            .map({ newDatas in
                // 테이블뷰에 맞게 데이터 변환
                return newDatas.keys.sorted(by: { $0.rawValue < $1.rawValue })
                    .map({ key in
                        let value = newDatas[key] ?? [ToDo]()
                        return SectionModel(model: "\(key) (\(value.count))",
                                                      items: value.map({ $0 }))
                    })
            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        todos
            .bind(with: self,
                  onNext: { owner, _ in
            owner.textField.text = ""
        })
            .disposed(by: disposeBag)
        
        // 삭제
        tableView.rx
            .itemDeleted
            .bind(to: viewModel.itemDeleted)
            .disposed(by: disposeBag)
        
        // 선택
        tableView.rx
            .itemSelected
            .bind(to: viewModel.itemSelected)
            .disposed(by: disposeBag)
        
        /// 텍스트필드
        textField.rx
            .controlEvent(.editingDidEndOnExit)
            // 두 Observable중 첫번째 Observable에서 아이템이 방출될 때마다 그 아이템을 두번째 Observable의 가장 최근 아이템과 결합해 방출합니다.
            // 즉, 편집이 끝날때마다 텍스트 필트의 텍스트값을 가져온단소리!!
            .withLatestFrom(textField.rx.text.orEmpty)
            .bind(to: viewModel.endEditing)
            .disposed(by: disposeBag)
    }
    
    
}

