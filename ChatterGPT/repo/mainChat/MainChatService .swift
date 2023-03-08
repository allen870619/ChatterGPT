//
//  MainChatService .swift
//  ChatGPT
//
//  Created by Lee Yen Lin on 2023/3/8.
//

import Alamofire
import Foundation

protocol MainChatService {
    func sendRequest(currentMessage: String, history: [Message], completion: @escaping (ChatResponseResult) -> Void) -> Task<Void, Never>?
}

class MainChatRemoteService: MainChatService {
    func sendRequest(currentMessage _: String, history: [Message], completion: @escaping (ChatResponseResult) -> Void) -> Task<Void, Never>? {
        // TODO: Mock
        let token = ""

        var tmpHeader = HTTPHeaders.default
        tmpHeader.add(.init(name: "Content-Type", value: "application/json"))
        tmpHeader.add(.init(name: "Authorization", value: "Bearer \(token)"))
        let header = tmpHeader

        let message = history.map {
            ["role": $0.role, "content": $0.content]
        }
        let params: [String: Any] = ["model": "gpt-3.5-turbo",
                                     "max_tokens": 1024,
                                     "messages": message]

        return Task {
            let response = await ApiRequest.shared.execute(url: "https://api.openai.com/v1/chat/completions",
                                                           method: .post,
                                                           headers: header,
                                                           params: params,
                                                           entity: ChatCompletion.self)
            completion(response)
        }
    }
}
