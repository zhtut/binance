//
//  File.swift
//
//
//  Created by zhtg on 2023/6/18.
//

import Foundation
import UtilCore

/// api配置
public struct APIConfig {
    
    // 从文件中读取配置文件
    public static func readConfig(_ configURL: URL) throws {
        let data = try Data(contentsOf: configURL)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: String] else {
            throw CommonError(message: "解析config.json错误")
        }
        guard let apiKey = json["apiKey"], !apiKey.isEmpty,
              let secretKey = json["secretKey"], !secretKey.isEmpty else {
            throw CommonError(message: "apiKey或secretKey为空")
        }
        Self.apiKey = apiKey
        Self.secretKey = secretKey
    }
    
    public static var apiKey = ""
    public static var secretKey = ""
    
    public struct URLGroup {
        public var httpBaseURL: String
        public var wsBaseURL: String
    }
    
    public static var spot = URLGroup(httpBaseURL: "https://api.binance.com",
                                      wsBaseURL: "wss://stream.binance.com:9443/ws")
    public static var feature = URLGroup(httpBaseURL: "https://fapi.binance.com",
                                         wsBaseURL: "wss://fstream.binance.com/ws")
}
