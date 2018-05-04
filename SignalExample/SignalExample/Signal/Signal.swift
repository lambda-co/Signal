//
//  Signal.swift
//  let.swift
//
//  Created by wenjin on 5/1/17.
//  Copyright © 2017 aaaron7. All rights reserved.
//

import Foundation
import UIKit

public class ObserveFunctions<a> : NSObject, IDisposable
{
    var id : Int = 0
    var function : (a)->Void
    weak var parentSignal : Signal<a>?
    init(function:@escaping (a) -> Void) {
        self.function = function
    }
    
    func addToDisposeBag(dispose : DisposeBag){
        dispose.registerDispose(x: self)
    }
    
    func dispose() {
        _ = parentSignal.flatMap { (x) -> String? in
            x.removeFunction(x: self)
            return nil
        }
    }
}

extension Array where Element:Equatable{
    mutating func removeElement(_ x : Element){
        if let idx = index(of: x){
            remove(at:idx)
        }
    }
}

public class Signal<a> : NSObject
{
    public typealias SignalToken = Int
    
    fileprivate var subscribers:[ObserveFunctions<a>] = []
    
    public private(set) var value : a?
        
    let queue = DispatchQueue(label: "com.swift.let.token")

    init(value : a?)
    {
        self.value = value
    }
    
    public func subscribeNext(hasInitialValue:Bool = false, subscriber : @escaping (a) -> Void) -> ObserveFunctions<a>
    {
        let newFunction = ObserveFunctions(function: subscriber)
        newFunction.parentSignal = self
        queue.sync{
            subscribers.append(newFunction)
            if hasInitialValue{
                subscriber(value!)
            }
        }
        
        return newFunction
    }
    
    func removeFunction(x : ObserveFunctions<a>){
        subscribers.removeElement(x)
    }
    
//    public func bind(signal : Signal<a>) -> SignalToken
//    {
//        let token = self.subscribeNext { (newValue : a) in
//            signal.update(newValue)
//        }
//
//        return token
//    }
//
//    public func unbind(token : SignalToken)
//    {
//        unscrible(token: token)
//    }
    
    public func update(_ value : a)
    {
        queue.sync{
            self.value = value
            for sub in subscribers {
                sub.function(value)
            }
        }
    }
    
    public func peek() -> a?
    {
        return value
    }
}

extension Signal{
    public func map<b>(f : @escaping (a) -> b) -> Signal<b>{
        let mappedValue = Signal<b>(value: nil)
        _ = self.subscribeNext { (x) in
            mappedValue.update(f(x))
        }
        return mappedValue
    }
    
    public func filter(f : @escaping (a) -> Bool) -> Signal<a>{
        let filterValue = Signal(value: self.value)
        _ = self.subscribeNext { (x) in
            if f(x){
                filterValue.update(x)
            }
        }
        return filterValue
    }
}


extension Signal
{
    public func bind(to control:NSObject, keyPath:String)
    {
        _ = self.subscribeNext(hasInitialValue: true, subscriber: { (v : a) in
            control.setValue(v, forKey: keyPath)
        })
    }
}

//extension Signal
//{
//    public func flatNext<b>(f : @escaping (a) -> Signal<b>) -> Signal<b>{
//        let signal:Signal<b> = Signal<b>(value: nil)
//        _ = self.subscribeNext(subscriber: { (x) in
//            let newS = f(x)
//            signal.update(newS.peek()!)
//            _ = newS.bind(signal: signal)
//        })
//        return signal
//    }
//}



