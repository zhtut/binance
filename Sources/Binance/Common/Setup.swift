import Foundation
import UtilCore

public class Setup {

    public static var shared = Setup()

    private init() {
    }
    
    public func setup(_ configURL: URL) async throws {
        // 读取配置，如果读取失败，则无法启动程序
        try APIConfig.readConfig(configURL)
        // 激活账号和订单的websocket
        let _ = AccountWebSocket.shared
        // 请求symbols
        try await Setup.shared.loadSymbols()
    }

    public var symbols: [Symbol] = []

    public func loadSymbols() async throws {
        // https://api.binance.com/api/v1/exchangeInfo
        let path = "GET /api/v1/exchangeInfo"
        let response = await RestAPI.send(path: path, dataKey: "symbols")
        if response.succeed {
            guard let dicArr = response.data as? [[String: Any]] else {
                throw CommonError(message: "exchangeInfo接口data字段返回格式有问题")
            }
            fSymbols = dicArr.map { Symbol(dic: $0) }
            print("symbol请求成功，总共请求到\(fSymbols.count)个symbol")
        } else if let msg = response.errMsg {
            throw CommonError(message: msg)
        }
    }

    public var fSymbols: [Symbol] = []

    public func fLoadSymbols() async throws {
        let path = "GET /fapi/v1/exchangeInfo"
        let response = await RestAPI.send(path: path, dataKey: "symbols")
        if response.succeed {
            guard let dicArr = response.data as? [[String: Any]] else {
                throw CommonError(message: "exchangeInfo接口data字段返回格式有问题")
            }
            fSymbols = dicArr.map { Symbol(dic: $0) }
            print("symbol请求成功，总共请求到\(fSymbols.count)个symbol")
        } else if let msg = response.errMsg {
            throw CommonError(message: msg)
        }
    }
}
