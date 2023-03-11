//
//  ChatGPTTests.swift
//  ChatGPTTests
//
//  Created by Lee Yen Lin on 2023/3/8.
//

import Alamofire
@testable import ChatGPT
import XCTest

final class ChatGPTTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testApiExecute() throws {
        let api = ApiRequest.shared
        let exp = XCTestExpectation(description: "Api connectionTest")

        Task {
            guard let plistPath = Bundle.main.path(forResource: "token", ofType: "plist"),
                  let plistData = FileManager.default.contents(atPath: plistPath),
                  let plistDictionary = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any]
            else {
                print("Failed to load plist file")
                return
            }
            guard let token = plistDictionary["tokenId"] as? String else {
                throw NSError(domain: "Token Error", code: 1)
            }

            var header = HTTPHeaders.default
            header.add(.init(name: "Content-Type", value: "application/json"))
            header.add(.init(name: "Authorization", value: "Bearer \(token)"))

            let test = [Message(role: "user", content: "Hello")]
            var params = [String: Any]()
            params["model"] = "gpt-3.5-turbo"
            params["messages"] = test.map {
                ["role": $0.role, "content": $0.content]
            }

            let result = await api.execute(url: "https://api.openai.com/v1/chat/completions",
                                           method: .post, headers: header, params: params, entity: ChatCompletion.self)

            do {
                let data = try result.get()
                print(data)
            } catch {}
            exp.fulfill()
        }

        wait(for: [exp], timeout: 15)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
