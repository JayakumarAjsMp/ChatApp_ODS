//
//  ChatAppUnitTests.swift
//  ChatAppUnitTests
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import XCTest
import Combine

@testable import ChatApp

final class UserViewModelTests: XCTestCase {
    
    var decoder = JSONDecoder()
    
    override class func setUp() {
    }
    
    /// Testing successful login
    func testLoginSuccess() {
        let username = "Ajs"
        let password = "S@thish25"
        let service = MockUserFetchAPIService(isSuccessful: true, jsonDecoder: decoder) // Mock service for testing
        let viewModel = UserViewModel(apiService: service)
        let fetchExpectation = expectation(description: "User Login Successfully")
        viewModel.login(username: username, password: password) { isLogin in
            XCTAssertTrue(isLogin)
            XCTAssertNil(viewModel.viewError)
            XCTAssertNotNil(viewModel.user)
            XCTAssertEqual(viewModel.user?.username ?? "", username)
            XCTAssertEqual(viewModel.user?.password ?? "", password)
            fetchExpectation.fulfill()
        }
        wait(for: [fetchExpectation], timeout: 1)
    }
    
    /// Testing Failed login if user not found or empty from server
    func testLoginFailedOrNoData() {
        let username = "Ajs"
        let password = "S@thish"
        let service = MockUserFetchAPIService(isSuccessful: true, jsonDecoder: decoder) // Mock service for testing
        let viewModel = UserViewModel(apiService: service)
        let fetchExpectation = expectation(description: "User Login Failed")
        viewModel.login(username: username, password: password) { isLogin in
            XCTAssertFalse(isLogin)
            XCTAssertNotNil(viewModel.viewError)
            XCTAssertNil(viewModel.user)
            XCTAssertEqual((viewModel.viewError as? NetworkingError)?.description, NetworkingError.dataNotFound.description)
            fetchExpectation.fulfill()
        }
        wait(for: [fetchExpectation], timeout: 1)
    }
    
    /// Testing bad JSON reponse from server
    func testBadResponse() {
        let username = "Ajs"
        let password = "S@thish25"
        let service = MockUserFetchAPIService(contentFile: "users-sample-bad-data", isSuccessful: true, jsonDecoder: self.decoder) // Mock service for testing
        let viewModel = UserViewModel(apiService: service)
        let fetchExpectation = expectation(description: "User Login Failed")
        viewModel.login(username: username, password: password) { isLogin in
            XCTAssertFalse(isLogin)
            XCTAssertNotNil(viewModel.viewError)
            XCTAssertNil(viewModel.user)
            fetchExpectation.fulfill()
        }
        wait(for: [fetchExpectation], timeout: 1)
    }
    
    /// Testing successful login with user stored in coredata and retrive stored user and check
    func testStoreFetchUserCoreData() {
        let username = "Ajs"
        let password = "S@thish25"
        let service = MockUserFetchAPIService(isSuccessful: true, jsonDecoder: decoder)// Mock service for testing
        let viewModel = UserViewModel(apiService: service)
        let fetchExpectation = expectation(description: "User Login Successfully")
        viewModel.login(username: username, password: password) { isLogin in
            XCTAssertTrue(isLogin)
            XCTAssertNil(viewModel.viewError)
            XCTAssertNotNil(viewModel.user)
            XCTAssertEqual(viewModel.user?.username ?? "", username)
            XCTAssertEqual(viewModel.user?.password ?? "", password)
            fetchExpectation.fulfill()
        }
        wait(for: [fetchExpectation], timeout: 1)
        let storedUsers = viewModel.fetchStoredUsers()
        XCTAssertNotNil(storedUsers)
        XCTAssertEqual(storedUsers?.count ?? 0, 1)
        let storedUser = storedUsers?.first
        XCTAssertEqual(storedUser?.username, username)
        XCTAssertEqual(storedUser?.password, password)
    }
    
}
