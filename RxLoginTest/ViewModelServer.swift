//
//  ViewModelServer.swift
//  RxLoginTest
//
//  Created by Tan on 16/7/18.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Moya
import Argo

//  MARK: - ValidateServer
class ValidateServer {
    static let instance = ValidateServer()
    
    class func shareInstance() -> ValidateServer {
        return self.instance
    }
    
    let minTelNumCount = 11
    let minPasswordCount = 6
    
    func validateTelNum(telNum: String) -> ValidateResult {
        guard let _ = Int(telNum) else { return .faild(message: "号码格式错误") }
        return telNum.characters.count >= self.minTelNumCount ? .succeed : .faild(message: "号码长度不足")
    }
    
    func validatePassword(password: String) -> ValidateResult {
        return password.characters.count >= self.minPasswordCount ? .succeed : .faild(message: "密码长度不足")
    }
}

//  MARK: - NetworkServer
class NetworkServer {
    static let instance = NetworkServer()
    
    class func shareInstace() -> NetworkServer {
        return self.instance
    }
    
    //  Lazy
    private lazy var provider: RxMoyaProvider = {
        return RxMoyaProvider<RequestTarget>(stubClosure: MoyaProvider.ImmediatelyStub)
    }()
    
    func loginWork(telNum: String, password: String) -> Driver<ResponseResult> {
        return self.provider.request(.login(telNum: telNum, password: password))
            .mapJSON()
            .map { jsonObject -> ResponseResult in
                let decodeResult: Decoded<ResponseResult> = decode(jsonObject)
                return try decodeResult.dematerialize()
            }
            .asDriver(onErrorJustReturn: .faild(message: "网络或数据解析错误！"))
    }
}