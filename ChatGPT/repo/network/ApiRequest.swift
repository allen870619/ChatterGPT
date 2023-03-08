//
//  ApiRequest.swift
//  ChatGPT
//
//  Created by Lee Yen Lin on 2023/3/8.
//

import Alamofire
import Foundation
import SwiftyJSON

final class ApiRequest {
    // debug config
    private let devMode = true
    private let enableRequest = true
    private let enableResponseJson = true

    // singleton
    static let shared = ApiRequest()

    private init() {}

    /// Main api executor
    /// - Parameters:
    ///   - url: Url String
    ///   - method: Http Method
    ///   - headers: Custom header, default is HTTPHeaders.default
    ///   - params: body parameters, default is nil
    ///   - entity: Parse target Entity
    /// - Returns: Result of callback type
    func execute<T: Decodable>(url: String,
                               method _: HTTPMethod,
                               headers: HTTPHeaders = HTTPHeaders.default,
                               params: Parameters? = nil,
                               entity _: T.Type) async -> Result<T, Error>
    {
        let url = URL(string: url)!
        let request = AF.request(url,
                                 method: .post,
                                 parameters: params,
                                 encoding: JSONEncoding.default,
                                 headers: headers)
        if devMode, enableRequest {
            printRequest(request)
        }
        do {
            let rawdata = try await request.serializingData(automaticallyCancelling: true).value

            // json for debug
            if devMode, enableResponseJson {
                printResponseJson(rawdata)
            }

            let data = try JSONDecoder().decode(T.self, from: rawdata)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }

    /// Utils
    /// - Parameter request: send Request
    private func printRequest(_ request: DataRequest) {
        let urlRequest = request.convertible.urlRequest
        print("------Request------")
        let method = urlRequest?.method?.rawValue ?? "Unknown"
        let url = urlRequest?.url?.absoluteString ?? "Unknown"
        print("\(method) \(url)")
        print(urlRequest?.headers as Any)
        if let data = urlRequest?.httpBody,
           let body = try? JSONDecoder().decode(JSON.self, from: data)
        {
            print(body)
        }
        print("------End Request------\n")
    }

    private func printResponseJson(_ data: Data) {
        if let json = try? JSONDecoder().decode(JSON.self, from: data) {
            print("------Response------")
            print(json)
            print("------End Response------\n")
        }
    }
}
