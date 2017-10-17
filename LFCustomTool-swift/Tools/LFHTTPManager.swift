//
//  LFHTTPManager.swift
//  AF的封装
//
//  Created by 刘丰 on 2017/9/23.
//  Copyright © 2017年 liufeng. All rights reserved.
//  网络工具类

import UIKit
import AFNetworking

public class LFHTTPManager: AFHTTPSessionManager {
    
    /// 单例
    public static let shareHTTPManager: LFHTTPManager = {
        let manager = LFHTTPManager()
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        return manager
    }()
}

//MARK: - 封装的方法
extension LFHTTPManager {
    
    /// post方法
    public func POST(urlStr: String, parameters: [String: Any], success: ((_ object: [String: Any]) -> ())?, failure: ((_ error: Error) -> ())?) {
        self.post(urlStr, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            success?(responseObject as! [String: Any])
        }) { (task: URLSessionDataTask?, error: Error) in
            failure?(error)
        }
    }
    
    /// get方法
    public func GET(urlStr: String, parameters: [String: Any], success: ((_ object: [String: Any]) -> ())?, failure: ((_ error: Error) -> ())?) {
        self.get(urlStr, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            success?(responseObject as! [String: Any])
        }) { (task: URLSessionDataTask?, error: Error) in
            failure?(error)
        }
    }
}
