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
    var tickTimer : Timer? = nil
    
    lazy var button:UIButton = {
        let btn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        btn.setTitle("close", for: .normal)
        btn.addTarget(self, action: #selector(DetailViewController.onClick(sender:)), for: .touchUpInside)
        btn.setTitleColor(UIColor.black, for: .normal)
        return btn
    }()

    lazy var testFlatNext:UIButton = {
        let btn = UIButton(frame: CGRect(x: 100, y: 200, width: 100, height: 50))
        btn.setTitle("flatNext test", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(ViewController.onClick(sender:)), for: .touchUpInside)
        return btn
    }()
    
    func uploadRecord(complete : (Bool) -> Void){
        complete(true)
    }

    let onClickSignal = Signal(value: UIButton())

    deinit {
        print("deinit detail view controller")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.button)
        self.view.addSubview(self.testFlatNext)
        _ = viewController?.signal.subscribeNext(subscriber: { (x) in
            print("obs in detailViewController")
        }).addToDisposeBag(dispose: dispose)

        
        _ = onClickSignal.flatNext {[unowned self] (x) -> Signal<Int> in
            let timerSignal = Signal(value: 10)
            print("button clicked")
            self.tickTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in

                timerSignal.peek().flatMap(f: { (value) in
                    if value > 0{
                        timerSignal.update(value - 1)
                        print(value - 1)
                    }
                })
            })
            return timerSignal
            }.filter{
                return $0 <= 0
            }.map{
                $0 == 0
            }
            .flatNext(f: {[unowned self] (shouldRequestNetwork) -> Signal<Bool> in
                print("check!!!!!!!!!")
                let finishedNetworkSignal = Signal(value: false)
                if shouldRequestNetwork{
                    print("begin request network")
                    self.uploadRecord(complete: { (x) in
                        finishedNetworkSignal.update(true)
                    })
                }
                return finishedNetworkSignal
            }).flatNext(f: { (isFinished) -> Signal<String> in
                if isFinished{
                    print("upload successful")
                }
                return Signal(value: "")
            })
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onClick(sender : UIButton){
        if sender == self.button{
            self.tickTimer?.invalidate()
            dismiss(animated: true) {
                
            }
        }else if sender == self.testFlatNext{
            onClickSignal.update(sender)
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
