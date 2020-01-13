//
//  RxAlertController.swift
//  RxAlertController
//
//  Created by Steve Kim on 05/10/2019.
//  Copyright © 2019 Steve Kim. All rights reserved.
//

import RxSwift

public struct RxAlertAction {
    public static let EmptyId = -1
    
    public let id: Int
    public let title: String
    public let style: UIAlertAction.Style
    public let userInfo: [String: Any]?
    
    public init(title: String, id: Int = EmptyId, style: UIAlertAction.Style = .default, userInfo: [String: Any]? = nil) {
        self.title = title
        self.id = id
        self.style = style
        self.userInfo = userInfo
    }
    
    public struct Result {
        public let action: RxAlertAction
        public let textFields: [UITextField]?
    }
}

public struct RxAlertModel {
    public let title: String?
    public let message: String?
    public let style: UIAlertController.Style
    
    public init(title: String? = nil, message: String? = nil, style: UIAlertController.Style = .alert) {
        self.title = title
        self.message = message
        self.style = style
    }
}

final public class RxAlertController {
    
    // MARK: - Public Properties
    
    public private(set) var vc: UIAlertController!
    
    // MARK: - Private Properties
    
    private var observer: AnyObserver<RxAlertAction.Result>?
    
    // MARK: - Constructors
    
    public init(title: String? = nil, message: String? = nil, preferredStyle: UIAlertController.Style = .alert) {
        vc = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    }
    convenience public init(_ model: RxAlertModel) {
        self.init(title: model.title, message: model.message, preferredStyle: model.style)
    }
    
    // MARK: - Public Methods
    
    public func add(_ action: RxAlertAction) -> Self {
        let item = UIAlertAction(title: action.title, style: action.style) { _ in
            if action.id != RxAlertAction.EmptyId {
                self.observer?.onNext(.init(action: action, textFields: self.vc.textFields))
                self.observer?.onCompleted()
            }
            self.observer = nil
        }
        
        action.userInfo?.forEach {
            item.setValue($0.value, forKey: $0.key)
        }
        
        vc.addAction(item)
        return self
    }
    public func add(_ actions: RxAlertAction ...) -> Self {
        actions.forEach { _ = add($0) }
        return self
    }
    public func add(_ actions: [RxAlertAction]) -> Self {
        actions.forEach { _ = add($0) }
        return self
    }
    public func addTextField(configurationHandler: ((UITextField) -> Void)?) -> Self {
        vc.addTextField(configurationHandler: configurationHandler)
        return self
    }
    public func show(in parent: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) -> Observable<RxAlertAction.Result> {
        return Observable<RxAlertAction.Result>.create { observer in
            self.observer = observer
            parent.present(self.vc, animated: animated, completion: completion)
            return Disposables.create()
        }
    }
}

extension ObservableType {
    public func keep(by disposeBag: DisposeBag) {
        subscribe(onNext: { _ in })
            .disposed(by: disposeBag)
    }
}
