//
//  ViewController.swift
//  RxAlertController
//
//  Created by Steve Kim on 10/05/2019.
//  Copyright (c) 2019 Steve Kim. All rights reserved.
//

import RxSwift
import RxAlertController

class ViewController: UIViewController {
    
    private lazy var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        testSimplePresenting()
//        testPresentingCompletion()
//        testOnlyOkSubscribing()
//        testAllSubscribing()
        testWithTextFields()
    }
    
    func testSimplePresenting() {
        RxAlertController(title: "title", message: "message", preferredStyle: .alert)
            .add(.init(title: "ok", style: .default))
            .show(in: self)
            .keep(by: disposeBag)
    }
    func testPresentingCompletion() {
        RxAlertController(title: "title", message: "message", preferredStyle: .alert)
            .add(.init(title: "ok", style: .default))
            .show(in: self) {
                print("presenting completed")
            }.keep(by: disposeBag)
    }
    func testOnlyOkSubscribing() {
        RxAlertController(title: "title", message: "message", preferredStyle: .alert)
            .add(.init(title: "cancel", style: .cancel))
            .add(.init(title: "ok", id: 1, style: .default))
            .show(in: self)
            .subscribe(onNext: {
                print("\($0.action.title) clicked")
            }).disposed(by: disposeBag)
    }
    func testAllSubscribing() {
        RxAlertController(title: "title", message: "message", preferredStyle: .alert)
            .add(.init(title: "cancel", id: 0, style: .cancel))
            .add(.init(title: "ok", id: 1, style: .default))
            .show(in: self)
            .subscribe(onNext: {
                print("\($0.action.title) clicked: \($0.action.id)")
            }).disposed(by: disposeBag)
    }
    func testWithTextFields() {
        RxAlertController(title: "title", message: "message", preferredStyle: .alert)
            .add(.init(title: "cancel", style: .cancel))
            .add(.init(title: "ok", id: 1, style: .default))
            .addTextField {
                $0.placeholder = "textfield 1"
            }
            .addTextField {
                $0.placeholder = "textfield 1"
            }
            .show(in: self)
            .subscribe(onNext: {
                let text1 = $0.textFields?.first?.text ?? "nil"
                let text2 = $0.textFields?.last?.text ?? "nil"
                print("\($0.action.title) clicked -> text1: \(text1), text2: \(text2)")
            }).disposed(by: disposeBag)
    }
}

