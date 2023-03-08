//
//  MainChatTests.swift
//  ChatGPTTests
//
//  Created by Lee Yen Lin on 2023/3/8.
//

@testable import ChatGPT
import XCTest

final class MainChatTests: XCTestCase {
    let viewModel = MainChatViewModel()

    override func setUpWithError() throws {
        viewModel.service = MockMainChatService()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSendMessage() throws {
        XCTAssertTrue(viewModel.messageList.isEmpty)
        let expectation = XCTestExpectation()

        viewModel.sendMessage(message: "Hello")
        XCTAssertEqual(viewModel.messageList[0].content, "Hello")

        _ = Task {
            try await viewModel.task?.result.get()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(viewModel.messageList[1].content, "Hello there, how may I assist you today?")
    }
}

class MockMainChatService: MainChatService {
    func sendRequest(currentMessage _: String, history _: [Message], completion: @escaping (ChatResponseResult) -> Void) -> Task<Void, Never>? {
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            let mockMessage = Message(role: "assistant", content: "Hello there, how may I assist you today?")
            let mockChoice = Choice(index: 0, message: mockMessage, finishReason: "stop")
            let mockUsage = Usage(promptTokens: 9, completionTokens: 12, totalTokens: 21)
            let mockChatCompletion = ChatCompletion(id: "chatcmpl-123", object: "chat.completion", created: 1_677_652_288, choices: [mockChoice], usage: mockUsage)
            completion(.success(mockChatCompletion))
        }
    }
}
