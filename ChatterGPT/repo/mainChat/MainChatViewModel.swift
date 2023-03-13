//
//  MainChatViewModel.swift
//  ChatGPT
//
//  Created by Lee Yen Lin on 2023/3/8.
//

import Foundation
import RxSwift

typealias ChatResponseResult = Result<ChatCompletion, Error>

class MainChatViewModel {
    var messageList = [Message]()

    var service: MainChatService?
    private(set) var task: Task<Void, Never>?

    init() {
//        service = MainChatRemoteService()
        service = MockMainChatService()
    }

    deinit {
        task?.cancel()
    }

    func sendMessage(message: String) {
        messageList.append(.init(role: "user", content: message))
        task = service?.sendRequest(currentMessage: message, history: messageList) { [weak self] data in
            // update viewModel data
            do {
                let message = try data.get().choices.first?.message
                if let message {
                    self?.messageList.append(message)
                } else {
                    throw NSError(domain: "Empty Data", code: 999)
                }
            } catch {
                self?.messageList.append(.init(role: "system", content: error.localizedDescription))
            }
        }
    }

    func sendMessageRx(message: String = Date().toDateTimeString()) -> Observable<Message> {
        Observable<Message>.create { [weak self] observer in
            guard let self else {
                return Disposables.create()
            }
            self.messageList.append(.init(role: "user", content: message))
            observer.onNext(.init(role: "user", content: message))

            let task = self.service?.sendRequest(currentMessage: message, history: self.messageList) { data in
                do {
                    let message = try data.get().choices.first?.message
                    if let message {
                        self.messageList.append(message)
                        observer.onNext(message)
                    } else {
                        throw NSError(domain: "Empty Data", code: 999)
                    }
                } catch {
                    let msg: Message = .init(role: "system", content: error.localizedDescription)
                    self.messageList.append(msg)
                    observer.onNext(msg)
                }
                observer.onCompleted()
            }

            return Disposables.create {
                task?.cancel()
            }
        }
    }
}

class MockMainChatService: MainChatService {
    func sendRequest(currentMessage _: String, history _: [Message], completion: @escaping (ChatResponseResult) -> Void) -> Task<Void, Never>? {
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            let mockMessage = Message(role: "assistant", content: "Hello there, how may I assist you today?")
            let mockChoice = Choice(index: 0, message: mockMessage, finishReason: "stop")
            let mockUsage = Usage(promptTokens: 9, completionTokens: 12, totalTokens: 21)
            let mockChatCompletion = ChatCompletion(id: "chatcmpl-123", object: "chat.completion", created: 1_677_652_288, choices: [mockChoice], usage: mockUsage)
            completion(.success(mockChatCompletion))
        }
    }
}
