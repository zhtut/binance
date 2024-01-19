//
//  File.swift
//  
//
//  Created by zhtg on 2023/6/18.
//

import Foundation
import Networking

public struct BAResponse {

    public var res: Response

    public init(res: Response) {
        self.res = res
        if let json = res.bodyJson {
            if res.succeed {
            } else {
                if let dict = json as? [String: Any] {
                    self.code = dict["code"] as? Int
                    self.msg = dict["msg"] as? String
                }
            }
        }
    }

    public var code: Int?
    public var data: Any? {
        if let _ = res.modelType {
           return res.model
        } else {
            return res.data
        }
    }
    
    /// 服务器返回的错误日志
    private var msg: String?

    public var succeed: Bool {
        if res.succeed {
            return code == nil || code == 200
        }
        return false
    }
    
    /// 优先展示服务器错误，否则展示网络sdk的错误
    public var errMsg: String? {
        if self.code != nil && self.msg != nil {
            return self.msg
        }
        return res.error?.localizedDescription
    }
}
