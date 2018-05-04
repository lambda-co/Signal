//
//  DisposeBag.swift
//  SignalExample
//
//  Created by aaron on 2018/5/5.
//  Copyright © 2018年 aaron. All rights reserved.
//

import UIKit

protocol IDisposable {
    func dispose()
}

class DisposeBag: NSObject {
    var disposeList : [IDisposable] = []
    
    func registerDispose(x : IDisposable){
        disposeList.append(x)
    }
    
    deinit {
        for item in disposeList{
            item.dispose()
        }
        
        disposeList.removeAll()
    }
}
