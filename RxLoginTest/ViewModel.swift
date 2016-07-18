//
//  ViewModel.swift
//  RxLoginTest
//
//  Created by Tan on 16/7/18.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewModel {
    //  MARK: - Output
    let juhuaShow: Driver<Bool>
    let loginEnable: Driver<Bool>
    let tipString: Driver<String>
    
    init(input: (telNum: Driver<String>, password: Driver<String>, loginTap: Driver<Void>),
         dependency: (validateServer: ValidateServer, networkServer: NetworkServer)) {
        
        let telNumValidate = input.telNum
            .distinctUntilChanged()
            .map { return dependency.validateServer.validateTelNum($0) }
        
        let passwordValidate = input.password
            .distinctUntilChanged()
            .map { return dependency.validateServer.validatePassword($0) }
        
        let validateString = [telNumValidate, passwordValidate]
            .combineLatest { result -> String in
                var validateString = ""
                if case let .faild(message) = result[0] {
                    validateString = "\(message)"
                }
                if case let .faild(message) = result[1] {
                    validateString = "\(validateString) \(message)"
                }
                return validateString
            }
        
        let telNumAndPassWord = Driver.combineLatest(input.telNum, input.password) { ($0, $1) }
        
        let loginString = input.loginTap.withLatestFrom(telNumAndPassWord)
            .flatMapLatest {
                return dependency.networkServer.loginWork($0.0, password: $0.1)
            }
            .map { result -> String in
                switch result {
                case let .faild(message):
                    return "登录失败 \(message)"
                case let .succeed(user):
                    return "登录成功，用户名:\(user.name)，标识符:\(user.userToken)"
            }
        }
        
        self.loginEnable = [telNumValidate, passwordValidate]
            .combineLatest { result -> Bool in
                return result[0] ^-^ result[1]
        }
        
        self.juhuaShow = Driver.of(loginString.map{_ in false}, input.loginTap.map{_ in true})
            .merge()
        
        self.tipString = Driver.of(validateString, loginString)
            .merge()
    }
}
