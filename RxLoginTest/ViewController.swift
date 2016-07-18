//
//  ViewController.swift
//  RxLoginTest
//
//  Created by Tan on 16/7/18.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var telNumTF: UITextField!
    @IBOutlet weak var passWordTF: UITextField!
    @IBOutlet weak var juhuaView: UIActivityIndicatorView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var tipLb: UILabel!
    
    private var viewModel: ViewModel?
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ViewModel(input: (
                                    self.telNumTF.rx_text.asDriver(),
                                    self.passWordTF.rx_text.asDriver(),
                                    self.loginBtn.rx_tap.asDriver()),
                                   dependency: (
                                    ValidateServer.shareInstance(),
                                    NetworkServer.shareInstace())
                                    )
        //  Binding
        self.viewModel!.juhuaShow
            .drive(self.juhuaView.rx_animating)
            .addDisposableTo(self.disposeBag)
        
        self.viewModel!.loginEnable
            .drive(self.loginBtn.rx_loginEnable)
            .addDisposableTo(self.disposeBag)
        
        self.viewModel!.tipString
            .drive(self.tipLb.rx_text)
            .addDisposableTo(self.disposeBag)
        
    }

}

private extension UIButton {
    var rx_loginEnable: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self, binding: { (button, bool) in
            self.enabled = bool
            if bool {
                button.backgroundColor = UIColor.greenColor()
            }else{
                button.backgroundColor = UIColor.redColor()
            }
        }).asObserver()
    }
}

