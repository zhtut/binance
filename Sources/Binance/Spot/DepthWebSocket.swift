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

/// 深度websocket
open class DepthWebSocket: NSObject {
    
    public struct DepthPrice {
        var price: String
        var volume: String
        
        init(price: String, volume: String) {
            self.price = price
            self.volume = volume
        }
        
        init(arr: [String]) {
            self.price = arr.first ?? ""
            self.volume = arr.last ?? ""
        }
    }
    
    /// websocket连接
    public var ws = WebSocket()
        
    var symbol: String
    
    public init(symbol: String) {
        self.symbol = symbol
        super.init()
        
        // 监听事件
        ws.onDataPublisher
            .sink { data in
                self.processData(data)
            }
            .store(in: &subscriptionSet)
        
        // 开始连接
        open()
    }
    
    /// 处理数据
    /// - Parameter data: 收到的数据
    open func processData(_ data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                updateBook(with: json)
            }
        } catch {
            print("处理数据错误：\(error)")
        }
    }
    
    /// Payload: 账户更新
    /// 每当帐户余额发生更改时，都会发送一个事件outboundAccountPosition，其中包含可能由生成余额变动的事件而变动的资产。
    open func didReceiveAccountUpdate(_ position: OutboundAccountPosition) {
        BalanceManager.shared.updateWith(position)
    }
    
    /// Payload: 余额更新
    /// 当下列情形发生时更新:
    /// - 账户发生充值或提取
    /// - 交易账户之间发生划转(例如 现货向杠杆账户划转)
    open func didReceiveBalanceUpdate(_ update: BalanceUpdate) {
        BalanceManager.shared.updateWith(update)
    }
    
    /// Payload: 订单更新
    /// 订单通过executionReport事件进行更新。
    open func didReceiveOrderUpdate(_ report: ExecutionReport) {
        OrderManager.shared.updateWith(report)
    }
    
    open func open() {
        let baseURL = APIConfig.spot.wsBaseURL
        let url = "\(baseURL)/\(symbol)@depth20@100ms"
        ws.url = URL(string: url)
        ws.open()
    }
    
    var lastUpdateId: Int?
    
    open var bids = [DepthPrice]()
    open var asks = [DepthPrice]()
    
    open func loadDepth() {
        let path = "/api/v3/depth?symbol=\(symbol.uppercased())&limit=1000"
        Task {
            let res = try await RestAPI.get(path: path)
            if let json = res.res.bodyJson as? [String: Any] {
                updateBook(with: json)
            }
        }
    }
    
    open func updateBook(with json: [String: Any]) {
        lastUpdateId = json.intFor("lastUpdateId")
        
        if let bids = json.arrayFor("bids") {
            var models = [DepthPrice]()
            bids.forEach { arr in
                if let arr = arr as? [String] {
                    models.append(DepthPrice(arr: arr))
                }
            }
            self.bids = models
        }
        
        if let asks = json.arrayFor("asks") {
            var models = [DepthPrice]()
            asks.forEach { arr in
                if let arr = arr as? [String] {
                    models.append(DepthPrice(arr: arr))
                }
            }
            self.asks = models
        }
        
        logOrderBook()
    }
    
    open func logOrderBook() {
        logPrice(arr: asks, index: 4)
        logPrice(arr: asks, index: 3)
        logPrice(arr: asks, index: 2)
        logPrice(arr: asks, index: 1)
        logPrice(arr: asks, index: 0)
        print("------")
        logPrice(arr: bids, index: 0)
        logPrice(arr: bids, index: 1)
        logPrice(arr: bids, index: 2)
        logPrice(arr: bids, index: 3)
        logPrice(arr: bids, index: 4)
    }
    
    open func logPrice(arr: [DepthPrice], index: Int) {
        if arr.count > index {
            let price = arr[index]
            print("\(price.price) \(price.volume)")
        }
    }
}
