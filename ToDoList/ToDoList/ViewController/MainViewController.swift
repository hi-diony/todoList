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
import ReactorKit
import RxGesture

class MainViewController: UIViewController, ReactorKit.View  {
    // MARK: - UI
    private let navigationView = UIView()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "해야할 일을 적어주세요."
        tf.leftViewMode = .always
        tf.leftView = UIView(frame: CGRect(x: 1, y: 1, width: 20, height: 1))
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .done
        return tf
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.allowsMultipleSelection = false
        tv.keyboardDismissMode = .interactiveWithAccessory
        tv.register(TodoCell.self, forCellReuseIdentifier: TodoCell.IDENTIFIER)
        return tv
    }()
    
    private let buttonView: UIStackView = {
        let s = UIStackView()
        s.alignment = .fill
        s.axis = .horizontal
        s.distribution = .fill
        return s
    }()
    
    private let colorThemeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paintpalette.fill"), for: .normal)
        button.snp.makeConstraints {
            $0.width.equalTo(40)
        }
        return button
    }()
    
    // MARK: - Property
    var disposeBag = DisposeBag()
    
    // MARK: - Function
    init() {
        super.init(nibName: nil, bundle: nil)
        
        reactor = MainViewReactor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    func bind(reactor: MainViewReactor) {
        bindState(reactor: reactor)
        bindAction(reactor: reactor)
    }
    
    private func initUI() {
        // 네비게이션 바
        view.addSubview(navigationView)
        navigationView.snp.makeConstraints({ make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        })
        
        navigationView.addSubview(buttonView)
        
        // 네비게이션의 버튼
        buttonView.snp.makeConstraints({ make in
            make.top.equalTo(navigationView.safeAreaLayoutGuide)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(40)
        })
        buttonView.addArrangedSubview(UIView())
        buttonView.addArrangedSubview(colorThemeButton)
        
        // 네비게이션의 텍스트필드
        navigationView.addSubview(textField)
        textField.snp.makeConstraints({ make in
            make.top.equalTo(buttonView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        })
        
        // 네비게이션의 하단 테이블 뷰
        view.addSubview(tableView)
        tableView.snp.makeConstraints({ make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        })
    }
}

extension MainViewController {
    private func bindAction(reactor: MainViewReactor) {
        // 삭제
        tableView.rx
            .itemDeleted
            .map { MainViewReactor.Action.delete($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 완료 혹은 다시 미완료 처리
        tableView.rx
            .gesture({
                let tapGesture = UITapGestureRecognizer()
                tapGesture.numberOfTapsRequired = 2
                return tapGesture
            }())
            .when(.ended)
            .compactMap { [weak self] gesture in
                guard let self = self else {
                    return nil
                }
                
                let touchPoint = gesture.location(in: self.tableView)
                guard let indexPath = self.tableView.indexPathForRow(at: touchPoint) else {
                    return nil
                }
                
                return MainViewReactor.Action.changeFinish(indexPath)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 추가
        textField.rx
            .controlEvent(.editingDidEndOnExit)
            .withLatestFrom(textField.rx.text.orEmpty)
            .filter { !$0.isEmpty }
            .map { MainViewReactor.Action.add($0) }
            .do(afterNext: { [weak self] _ in
                guard let self = self else { return }
                self.textField.text = ""
                self.textField.endEditing(true)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
                
        colorThemeButton.rx.tap
            .bind(with: self) { vc, _ in
                let alert = UIAlertController(title: "테마 선택",
                                              message: "테마를 선택해주세요.",
                                              preferredStyle: .actionSheet)
                
                Theme.allCases.forEach { theme in
                    guard theme != reactor.currentState.theme else {
                        return
                    }
                    
                    let action = UIAlertAction(title: theme.title,
                                               style: .default) { _ in
                        reactor.action.onNext(.changeTheme(theme))
                    }
                    alert.addAction(action)
                }
                
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                vc.present(alert, animated: true)
        }
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: MainViewReactor) {
        /// 테이블뷰
        // 데이터소스(셀 설정)
        // tableView와 Realm 바인딩 : https://stackoverflow.com/questions/48577819/how-to-bind-realm-object-to-uiswitch-using-rxswift-and-rxrealm
        // animated datasource로 하면 삭제시 앱 크래시 되는 이슈 있음 - https://github.com/RxSwiftCommunity/RxDataSources/issues/197
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<MainViewReactor.TodoGroup, TodoItem>>(
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
                let section = dataSource.sectionModels[sectionIndex].model
                switch section {
                case .todo:
                    return "TODO"
                    
                case .done:
                    return "DONE"
                }
            },
            canEditRowAtIndexPath: { _, _ in
                return true
            }
        )
        
        reactor.state
            .map { $0.section }
            .distinctUntilChanged()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.theme }
            .distinctUntilChanged()
            .onMain()
            .bind(with: self) { vc, theme in
                vc.view.backgroundColor = theme.backgroundColor
                vc.navigationView.backgroundColor = theme.navigationBarColor
                vc.textField.placeHolderColor = theme.textColor.withAlphaComponent(0.5)
                vc.textField.textColor = theme.textColor
                vc.textField.tintColor = theme.accentColor
                vc.colorThemeButton.tintColor = theme.buttonTintColor
            }
            .disposed(by: disposeBag)
        
    }
}
