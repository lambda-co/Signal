//
//  DisposeBag.swift
//  SignalExample
//
//  Created by aaron on 2018/5/5.
//  Copyright © 2018年 aaron. All rights reserved.
//

import UIKit

protocol IDisposable : AnyObject {
    func dispose()
}

final class WeakBox<a : AnyObject>{
    weak var unbox : a?
    init(_ value:a){
        unbox = value
    }
}

class DisposeBag: NSObject {
    var disposeList : [WeakBox<AnyObject>] = []
    
    func registerDispose(x : IDisposable){
        let reference = WeakBox<AnyObject>(x)
        disposeList.append(reference)
    }
    
    deinit {
        for item in disposeList{
            item.unbox.flatMap{($0 as! IDisposable).dispose()}
        }
        
        disposeList.removeAll()
    }
}
