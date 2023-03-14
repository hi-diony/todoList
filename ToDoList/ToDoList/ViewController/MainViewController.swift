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
    private var sections = BehaviorSubject(value: [
        AnimatableSectionModel(model: Section.Todo.sectionTitle, items: [ToDo]()),
        AnimatableSectionModel(model: Section.Done.sectionTitle, items: [ToDo]())
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bind()
    }
    
    private func bind() {
        guard let realm = try? Realm() else {
            return
        }

        /// 테이블뷰
        // tableView와 Realm 바인딩 : https://stackoverflow.com/questions/48577819/how-to-bind-realm-object-to-uiswitch-using-rxswift-and-rxrealm
        let allTodos = realm.objects(ToDo.self)
        Observable.changeset(from: allTodos)
            .subscribe(with: self,
                       onNext: { owner, realmChanges in
                let results = realmChanges.0
                guard var sections = try? owner.sections.value() else {
                    return
                }
                
                let newTodo = results
                            .where({ $0.finishedAt == nil })
                            .sorted(byKeyPath: "createdAt", ascending: false)

                let newFinished = results
                            .where({ $0.finishedAt != nil })
                            .sorted(byKeyPath: "finishedAt", ascending: false)

                guard let changes = realmChanges.1 else {
                    /// 변경사항이 없다면 (처음 초기값)
                    sections = [
                        AnimatableSectionModel(model: Section.Todo.sectionTitle, items: newTodo.map({ $0 })),
                        AnimatableSectionModel(model: Section.Done.sectionTitle, items: newFinished.map({ $0 }))
                    ]
                    owner.sections.onNext(sections)
                    return
                }

                let updateTodo = results.enumerated().compactMap({
                    if changes.updated.contains($0.offset) {
                        return $0.element
                    }
                    return nil
                })

                /// 초기값에서 변경사항이 존재함
                /// Todo 리스트
                var originalTodo = sections[Section.Todo.rawValue].items

                // 삭제
                let willDeleteTodoIndexs = Set(originalTodo).subtracting(newTodo)
                    .compactMap({
                        originalTodo.firstIndex(of: $0)
                    })
                originalTodo.remove(atOffsets: IndexSet(willDeleteTodoIndexs))

                // 삽입
                let willInsertTodoIndexs = Set(newTodo).subtracting(originalTodo)
                    .compactMap({
                        newTodo.firstIndex(of: $0)
                    })
                willInsertTodoIndexs.forEach({ row in
                    originalTodo.insert(newTodo[row], at: row)
                })

                // 업데이트
                updateTodo.forEach({ willUpdatTodo in
                    guard let index = originalTodo.firstIndex(where: { $0._id == willUpdatTodo._id }) else {
                        return
                    }
                    originalTodo[index] = willUpdatTodo
                })

                sections[Section.Todo.rawValue] = AnimatableSectionModel(model: Section.Todo.sectionTitle, items: originalTodo)

                /// Done 리스트
                var originalFinished = sections[Section.Done.rawValue].items
                // 삭제
                let willDeleteFinishedIndexs = Set(originalFinished).subtracting(newFinished)
                    .compactMap({
                        originalFinished.firstIndex(of: $0)
                    })
                originalFinished.remove(atOffsets: IndexSet(willDeleteFinishedIndexs))

                // 삽입
                let willInsertFinishedIndexs = Set(newFinished).subtracting(originalFinished)
                    .compactMap({
                        newFinished.firstIndex(of: $0)
                    })
                willInsertFinishedIndexs.forEach({ row in
                    originalFinished.insert(newFinished[row], at: row)
                })

                // 업데이트
                updateTodo.forEach({ willUpdatTodo in
                    guard let index = originalFinished.firstIndex(where: { $0._id == willUpdatTodo._id }) else {
                        return
                    }
                    originalFinished[index] = willUpdatTodo
                })

                sections[Section.Done.rawValue] = AnimatableSectionModel(model: Section.Done.sectionTitle, items: originalFinished)

                owner.sections.onNext(sections)
            })
            .disposed(by: disposeBag)
        
        
        // 데이터소스 추가(셀 설정)
        let dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, ToDo>>(
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
            titleForHeaderInSection: { [weak self] dataSource, sectionIndex in
                guard let self = self,
                      let sectionTitle = Section(rawValue: sectionIndex)?.sectionTitle,
                      let sections = try? self.sections.value() else {
                    return ""
                }
                
                return "\(sectionTitle) (\(sections[sectionIndex].items.count))"
            },
            canEditRowAtIndexPath: { _, _ in
                return true
            }
        )

        sections
            .distinctUntilChanged() // 연달아 중복된 값이 올 경우 무시
            .observe(on:MainScheduler.asyncInstance)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // 삭제
        tableView.rx.itemDeleted
            .bind(with: self,
                  onNext: { owner, indexPath in
                guard var section = try? owner.sections.value() else { return }
                var updateSection = section[indexPath.section]
                
                // Update item
                updateSection.items.remove(at: indexPath.item)
                
                // Update section
                
                section[indexPath.section] = updateSection
                
                // Emit
                owner.sections.onNext(section)
            })
            .disposed(by: self.disposeBag)
        
        tableView.rx
            .itemSelected
            .subscribe(with: self,
                       onNext: { owner, indexPath in
                // 해당 아이템이 터치될때마다 finish 상태가 바뀜
                guard let sections = try? owner.sections.value() else {
                    return
                }
                
                let todo = sections[indexPath.section].items[indexPath.row]
                guard let realm = try? Realm() else {
                    return
                }
                
                try? realm.write {
                    switch todo.isDone {
                    case true:
                        // 다시 TODO항목으로 추가된다면 생성일이 최근으로 바뀐다
                        todo.createdAt = Date()
                        todo.finishedAt = nil
                        
                    case false:
                        todo.finishedAt = Date()
                    }
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

extension MainViewController {
    enum Section: Int, CaseIterable {
        case Todo = 0
        case Done
        
        var sectionTitle: String {
            switch self {
            case .Todo:
                return "TODO"
                
            case .Done:
                return "DONE"
            }
        }
    }
}


