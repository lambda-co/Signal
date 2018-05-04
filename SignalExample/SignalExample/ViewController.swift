//
//  ViewController.swift
//  SignalExample
//
//  Created by aaron on 2018/4/24.
//  Copyright © 2018年 aaron. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let signal = Signal(value: "1")
    let dispose = DisposeBag()
    
    lazy var button:UIButton = {
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        btn.setTitle("click me", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: Selector(("onClick")), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.button)
        _ = signal.subscribeNext { (x) in
            print("obs in vc")
        }.addToDisposeBag(dispose: dispose)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.signal.update("trigger")
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onClick(){
        let newc = DetailViewController()
        newc.viewController = self
        present(newc, animated: true) {
            
        }
    }

}

