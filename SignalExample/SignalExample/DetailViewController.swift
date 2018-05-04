//
//  DetailViewController.swift
//  SignalExample
//
//  Created by aaron on 2018/5/5.
//  Copyright © 2018年 aaron. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    let dispose = DisposeBag()
    weak var viewController : ViewController?
    
    lazy var button:UIButton = {
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        btn.setTitle("close", for: .normal)
        btn.addTarget(self, action: Selector(("onClick")), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.button)
        _ = viewController?.signal.subscribeNext(subscriber: { (x) in
            print("obs in detailViewController")
        }).addToDisposeBag(dispose: dispose)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onClick(){
        dismiss(animated: true) {
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
