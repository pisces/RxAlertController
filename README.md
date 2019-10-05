# RxAlertController

![Swift](https://img.shields.io/badge/Swift-4.2-orange.svg)
[![CI Status](http://img.shields.io/travis/pisces/RxAlertController.svg?style=flat)](https://travis-ci.org/pisces/RxAlertController)
[![Version](https://img.shields.io/cocoapods/v/RxAlertController.svg?style=flat)](http://cocoapods.org/pods/RxAlertController)
[![License](https://img.shields.io/cocoapods/l/RxAlertController.svg?style=flat)](http://cocoapods.org/pods/RxAlertController)
[![Platform](https://img.shields.io/cocoapods/p/RxAlertController.svg?style=flat)](http://cocoapods.org/pods/RxAlertController)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

- Library for Reactive programming of UIAlertController.

## Features
- RxSwift Compatible
- Easy to use

## Using

### Simple presenting
```swift
RxAlertController(title: "title", message: "message", preferredStyle: .alert)
    .add(.init(title: "ok", style: .default))
    .show(in: self)
    .keep(by: disposeBag)
```

### Presenting with completion
```swift
RxAlertController(title: "title", message: "message", preferredStyle: .alert)
    .add(.init(title: "ok", style: .default))
    .show(in: self) {
        print("presenting completed")
    }.keep(by: disposeBag)
```

### Subscribe if action has id is not empty
```swift
RxAlertController(title: "title", message: "message", preferredStyle: .alert)
    .add(.init(title: "cancel", style: .cancel))
    .add(.init(title: "ok", id: 1, style: .default))
    .show(in: self)
    .subscribe(onNext: {
        print("\($0.action.title) clicked")
    }).disposed(by: disposeBag)
```

### Presenting with textfields
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
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### CocoaPods

RxAlertController is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RxAlertController', '~> 1.0.0'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate RxAlertController into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pisces/RxAlertController" ~> 1.0.0
```

Run `carthage update` to build the framework and drag the built `RxAlertController.framework` into your Xcode project.

## Requirements

iOS Deployment Target 9.0 higher

## Author

Steve Kim, hh963103@gmail.com

## License

RxAlertController is available under the MIT license. See the LICENSE file for more info.
