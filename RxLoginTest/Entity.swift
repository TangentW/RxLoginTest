//
//  Entity.swift
//  RxLoginTest
//
//  Created by Tan on 16/7/18.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Argo
import Moya
import Curry

//  MARK: - User
struct User {
    let name: String
    let userToken: String
}

extension User: Decodable {
    static func decode(json: JSON) -> Decoded<User> {
        return curry(self.init)
            <^> json <| "name"
            <*> json <| "user_token"
    }
}

//  MARK: - ResponseResult
enum ResponseResult {
    case succeed(user: User)
    case faild(message: String)
    
    var user: User? {
        switch self {
        case let .succeed(user):
            return user
        case .faild:
            return nil
        }
    }
}

extension ResponseResult: Decodable {
    init(statusCode: Int, message: String, user: User?) {
        if statusCode == 200 && user != nil {
            self = .succeed(user: user!)
        }else{
            self = .faild(message: message)
        }
    }
    
    static func decode(json: JSON) -> Decoded<ResponseResult> {
        return curry(self.init)
            <^> json <| "status_code"
            <*> json <| "message"
            <*> json <|? "user"
    }
}

//  MARK: - ValidateResult
enum ValidateResult {
    case succeed
    case faild(message: String)
    case empty
}


infix operator ^-^ {}
func ^-^ (lhs: ValidateResult, rhs: ValidateResult) -> Bool {
    switch (lhs, rhs) {
    case  (.succeed, .succeed):
        return true
    default:
        return false
    }
}

//  MARK: - RequestTarget
enum RequestTarget {
    case login(telNum: String, password: String)
}

extension RequestTarget: TargetType {
    var baseURL: NSURL {
        return NSURL(string: "")!
    }
    
    var path: String {
        return "/login"
    }
    
    var method: Moya.Method {
        return .POST
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case let .login(telNum, password):
            return ["tel_num": telNum, "password": password]
        default:
            ()
        }
    }
    
    var sampleData: NSData {
        let jsonString = "{\"status_code\":200, \"message\":\"登录成功\", \"user\":{\"name\":\"Tangent\",\"user_token\":\"abcdefg123456\"}}"
        return jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}


