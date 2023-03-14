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
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bind()
    }
    
    private func bind() {
        /// 데이터
        guard let realm = try? Realm() else {
            return
        }
        
        let todos = realm.objects(ToDo.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
        
        /// 테이블뷰
        // tableView와 Realm 바인딩 : https://stackoverflow.com/questions/48577819/how-to-bind-realm-object-to-uiswitch-using-rxswift-and-rxrealm
        Observable.changeset(from: todos)
            .subscribe(with: self,
                       onNext: { owner, realmChanges in
//                let results = realmChanges.0
                guard let changes = realmChanges.1 else {
                    owner.tableView.reloadData()
                    return
                }
//                
//                let todo = results.filter({ $0.finishedAt == nil })
//                let finished = results.filter({ $0.finishedAt != nil })
//                let sections = [
//                    SectionModel(model: "TO DO (\(todo.count))", items: todo),
//                    SectionModel(model: "DONE (\(finished.count))", items: finished)
//                ]
//                
                owner.tableView.beginUpdates()
                owner.tableView.deleteRows(at: changes.deleted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                owner.tableView.insertRows(at: changes.inserted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                owner.tableView.reloadRows(at: changes.updated.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                owner.tableView.endUpdates()
            })
            .disposed(by: disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(
            configureCell: { (_, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = element
                return cell
            },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
            }
        )

        
        
        Observable.collection(from: todos)
            .bind(to: tableView.rx.items(cellIdentifier: TodoCell.IDENTIFIER, cellType: TodoCell.self)) {
                indexPath, todo, cell in

                cell.selectionStyle = .none
                cell.setData(todo: todo)
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemSelected
            .subscribe(with: self,
                       onNext: { owner, indexPath in
                guard let realm = try? Realm() else {
                    return
                }
                
                try? realm.write {
                    todos[indexPath.row].finishedAt = todos[indexPath.row].finishedAt == nil ? Date() : nil
                }
            })
            .disposed(by: disposeBag)
        
        // 텍스트필드
        textField.rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(with: self,
                       onNext: { owner, _ in
                guard let text = owner.textField.text,
                      !text.removeWhiteSpace().isEmpty else {
                    // 빈텍스트는 추가 안함
                    return
                }

                guard let realm = try? Realm() else {
                    return
                }

                // 데이터 추가
                let newTodo = ToDo()
                newTodo.text = text

                try? realm.write({
                    realm.add(newTodo)
                })

                owner.textField.text = ""
            })
            .disposed(by: disposeBag)
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
}
