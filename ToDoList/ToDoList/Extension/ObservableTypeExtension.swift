//
//  ObservableTypeExtension.swift
//  ToDoList
//
//  Created by jiyeonpark on 2023/04/12.
//

import Foundation
import RxSwift

extension ObservableType {
    public func bindOnMain(onNext: @escaping (Self.Element) -> Swift.Void) -> Disposable {
        return onMain().bind(onNext: onNext)
    }
    
    public func onMain() -> RxSwift.Observable<Self.Element> {
        return observe(on: MainScheduler.instance)
    }
}
