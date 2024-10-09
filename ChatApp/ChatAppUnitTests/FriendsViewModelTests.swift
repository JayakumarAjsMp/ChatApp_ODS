//
//  FriendsViewModelTests.swift
//  ChatAppUnitTests
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import XCTest

@testable import ChatApp


final class FriendsViewModelTests: XCTestCase {
    
    var decoder = JSONDecoder()
    
    override class func setUp() {
    }
    
    /// Testing sucessful retriving of list of users and remove current user
    func testFetchFriendsSuccess() {
        let username = "Ajs"
        let password = "S@thish25"
        let service = MockFriendsFetchAPIService(isSuccessful: true, jsonDecoder: decoder) // Mock service for testing
        let viewModel = FriendsViewModel(apiService: service)
        let fetchExpectation = expectation(description: "Fetch Friend Successfully")
        viewModel.getFriends(username: username, password: password)
        _ = XCTWaiter.wait(for: [fetchExpectation], timeout: 1)
        XCTAssertNil(viewModel.viewError)
        XCTAssertNotNil(viewModel.friends)
        XCTAssertGreaterThan(viewModel.friends?.count ?? -1, 0)
    }
    
    /// Testing bad response while retriving of list of users
    func testBadResponse() {
        let username = "Ajs"
        let password = "S@thish25"
        let service = MockFriendsFetchAPIService(contentFile: "friends-sample-bad-data", isSuccessful: true, jsonDecoder: self.decoder) // Mock service for testing
        let viewModel = FriendsViewModel(apiService: service)
        let fetchExpectation = expectation(description: "Fetch Friends Failed")
        viewModel.getFriends(username: username, password: password)
        _ = XCTWaiter.wait(for: [fetchExpectation], timeout: 1)
        XCTAssertNotNil(viewModel.viewError)
        XCTAssertNil(viewModel.friends)
    }
    
    /// Testing empty response while retriving of list of users
    func testEmptyResponse() {
        let username = "Ajs"
        let password = "S@thish25"
        let service = MockFriendsFetchAPIService(contentFile: "friends-sample-no-data", isSuccessful: true, jsonDecoder: self.decoder) // Mock service for testing
        let viewModel = FriendsViewModel(apiService: service)
        let fetchExpectation = expectation(description: "Fetch Friends Empty")
        viewModel.getFriends(username: username, password: password)
        _ = XCTWaiter.wait(for: [fetchExpectation], timeout: 1)
        XCTAssertNil(viewModel.viewError)
        XCTAssertNotNil(viewModel.friends)
        XCTAssertEqual(viewModel.friends?.count ?? -1, 0)
    }
    
}
