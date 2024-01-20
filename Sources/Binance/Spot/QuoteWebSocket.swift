//
//  File.swift
//
//
//  Created by zhtut on 2023/7/23.
//

import Foundation
import WebSocket
import UtilCore
#if canImport(CombineX)
import CombineX
#else
import Combine
#endif

/// 行情websocket
open class QuoteWebSocket: CombineBase {
    
    /// websocket连接
    public var ws = WebSocket()
        
    var symbol: String
    
    public init(symbol: String) {
        self.symbol = symbol
        super.init()
        
        // 监听事件
        ws.onDataPublisher
            .sink { [weak self] data in
                self?.processData(data)
            }
            .store(in: &subscriptions)
        
        // 开始连接
        open()
    }
    
    /// 处理数据
    /// - Parameter data: 收到的数据
    open func processData(_ data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let e = json.stringFor("e") {
                switch e {
                default:
                    print("")
                }
            }
        } catch {
            print("处理数据错误：\(error)")
        }
    }
    
    open func open() {
        let baseURL = APIConfig.spot.wsBaseURL
        let url = "\(baseURL)/\(symbol)"
        ws.url = URL(string: url)
        ws.open()
    }
}
