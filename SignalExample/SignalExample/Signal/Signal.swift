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

extension Optional{
    func flatMap(f : @escaping (Wrapped) -> Void){
        _ = self.flatMap { (x) -> String? in
            f(x)
            return nil
        }
    }
}

public class Signal<a> : NSObject
{
    public typealias SignalToken = Int
    
    fileprivate var subscribers:[ObserveFunctions<a>] = []
    
    public private(set) var value : a?
    
    let dispose = DisposeBag()
        
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
    
    public func subscribeInternal(hasInitialValue:Bool = false, subscriber : @escaping (a) -> Void)
    {
        self.subscribeNext(hasInitialValue: hasInitialValue, subscriber: subscriber).addToDisposeBag(dispose: dispose)
    }
    
    func removeFunction(x : ObserveFunctions<a>){
        subscribers.removeElement(x)
    }
    
    public func bind(signal : Signal<a>) -> ObserveFunctions<a>
    {
        return self.subscribeNext { (newValue : a) in
            signal.update(newValue)
        }
    }

    
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
    
    deinit {
        value.flatMap { print("Signal deinit \($0)") }
    }
}

extension Signal{
    public func map<b>(f : @escaping (a) -> b) -> Signal<b>{
        let mappedValue = Signal<b>(value: nil)
        self.subscribeInternal { (x) in
            mappedValue.update(f(x))
        }
        return mappedValue
    }
    
    public func filter(f : @escaping (a) -> Bool) -> Signal<a>{
        let filterValue = Signal(value: self.value)
        self.subscribeInternal { (x) in
            if f(x){
                filterValue.update(x)
            }
        }
        return filterValue
    }
}

extension Signal
{
    public func flatNext<b>(f : @escaping (a) -> Signal<b>) -> Signal<b>{
        let signal:Signal<b> = Signal<b>(value: nil)
        self.subscribeInternal(subscriber: { (x) in
            let newS = f(x)
            signal.update(newS.peek()!)
            newS.bind(signal: signal).addToDisposeBag(dispose: newS.dispose)
        })
        return signal
    }
}



