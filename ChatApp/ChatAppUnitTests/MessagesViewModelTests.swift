//
//  MessagesViewModelTests.swift
//  ChatAppUnitTests
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import XCTest

@testable import ChatApp

final class MessagesViewModelTests: XCTestCase {
    
    var decoder = JSONDecoder()
    
    override class func setUp() {
    }
    
    /// Testing sucessful retriving of list of messages of  current user
    func testFetchMessagesSuccess() {
        let username = "Ajs"
        let fromUser = "A_JS_H"
        let service = MockMessagesFetchAPIService(isSuccessful: true, jsonDecoder: decoder) // Mock service for testing
        let viewModel = MessagesViewModel(fetchAPIService: service)
        let fetchExpectation = expectation(description: "Fetch Friend Successfully")
        viewModel.getMessages(username: username, fromUser: fromUser)
        _ = XCTWaiter.wait(for: [fetchExpectation], timeout: 1)
        XCTAssertNil(viewModel.viewError)
        XCTAssertNotNil(viewModel.messages)
        XCTAssertGreaterThan(viewModel.messages?.count ?? -1, 0)
    }
    
    /// Testing bad response while retriving of list of messages
    func testBadResponse() {
        let username = "Ajs"
        let fromUser = "A_JS_H"
        let service = MockMessagesFetchAPIService(contentFile: "messages-sample-bad-data", isSuccessful: true, jsonDecoder: self.decoder) // Mock service for testing
        let viewModel = MessagesViewModel(fetchAPIService: service)
        let fetchExpectation = expectation(description: "Fetch Friends Failed")
        viewModel.getMessages(username: username, fromUser: fromUser)
        _ = XCTWaiter.wait(for: [fetchExpectation], timeout: 1)
        XCTAssertNotNil(viewModel.viewError)
        XCTAssertNil(viewModel.messages)
        XCTAssertEqual(viewModel.viewError?.localizedDescription ?? "", "The data couldn’t be read because it is missing.")
    }
    
    /// Testing empty response while retriving of list of messages
    func testEmptyResponse() {
        let username = "Ajs"
        let fromUser = "A_JS_H"
        let service = MockMessagesFetchAPIService(contentFile: "messages-sample-no-data", isSuccessful: true, jsonDecoder: self.decoder) // Mock service for testing
        let viewModel = MessagesViewModel(fetchAPIService: service)
        let fetchExpectation = expectation(description: "Fetch Friends Empty")
        viewModel.getMessages(username: username, fromUser: fromUser)
        _ = XCTWaiter.wait(for: [fetchExpectation], timeout: 1)
        XCTAssertNil(viewModel.viewError)
        XCTAssertNotNil(viewModel.messages)
        XCTAssertEqual(viewModel.messages?.count ?? -1, 0)
    }
    
    /// Testing send message to user
    func testSendMessage() {
        let username = "Ajs"
        let fromUser = "A_JS_H"
        let newMessage = "Test messes wrtie"
        let fetchService = MockMessagesFetchAPIService(contentFile: "messages-sample-write-data", isSuccessful: true, jsonDecoder: self.decoder) // Mock service for testing
        let storeService = MockMessagesStoreAPIService(contentFile: "messages-sample-write-data", isSuccessful: true) // Mock service for testing
        let viewModel = MessagesViewModel(fetchAPIService: fetchService, storeAPIService: storeService)
        let mesage = [
            "id": "1",
            "toUser": fromUser,
            "message": newMessage,
            "fromUser": username,
            "createdAt": "2024-10-09 04:16:53.338"
        ]
        let fetchExpectation = expectation(description: "Write Friends Success")
        viewModel.sendMessage(username: username, fromUser: fromUser, message: mesage)
        _ = XCTWaiter.wait(for: [fetchExpectation], timeout: 2)
        XCTAssertNil(viewModel.viewError)
        XCTAssertNotNil(viewModel.messages)
        XCTAssertEqual(viewModel.messages?.count ?? -1, 1)
    }
    
}
