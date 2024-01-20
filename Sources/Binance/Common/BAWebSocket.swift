//
//  File.swift
//  
//
//  Created by zhtut on 2023/7/23.
//

import Foundation
import WebSocket
#if canImport(CombineX)
import CombineX
#else
import Combine
#endif
import UtilCore

open class BAWebSocket: CombineBase {
    
    public var ws = WebSocket()
    
    public enum `Type` {
        case spot
        case feature
    }
    
    public init(type: `Type`) {
        super.init()
        var url: String
        switch type {
        case .spot:
            url = APIConfig.spot.wsBaseURL
        case .feature:
            url = APIConfig.feature.wsBaseURL
        }
        ws.url = URL(string: url)
        ws.onDataPublisher.sink { data in
            if let str = String(data: data, encoding: .utf8) {
              print("收到数据：\(str)")
            }
        }.store(in: &subscriptions)
    }
    
    open func open() {
        ws.open()
    }
}
