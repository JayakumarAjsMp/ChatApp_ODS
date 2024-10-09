//
//  MockUserAPIService.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation
import Combine

/// Mock class for User Fetch API Service
final class MockUserFetchAPIService: UserFetchService {
    
    /// Sample Data file name that to retrive
    private let contentFile: String
    /// To run code successfully or to return error
    private var isSuccessful: Bool
    /// Decoder object to decode JSON data from file
    private let jsonDecoder: JSONDecoder
    
    /// Initize MockUserFetchAPIService Object
    /// - Parameters:
    ///   - contentFile: Sample Data file name that to retrive
    ///   - isSuccessful: To run code successfully or to return error
    ///   - jsonDecoder: Decoder object to decode JSON data from file
    init(contentFile: String = "users-sample-data", isSuccessful: Bool = true, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.contentFile = contentFile
        self.isSuccessful = isSuccessful
        self.jsonDecoder = jsonDecoder
    }
    
    /// Retrive User from local JSON file
    /// - Parameters:
    ///   - username: username of the user that to retrive
    ///   - password: password of the user that to retrive
    ///   - completion: return user if success or else return error
    func fetchUser(username: String, password: String, completion: @escaping (User?, (any Error)?) -> Void) {
        guard isSuccessful else {
            completion(nil, NetworkingError.testing)
            return
        }
        fetchData() { data, error in
            if let error = error {
                completion(nil, error)
            } else {
                do {
                    if let data = data {
                        let users = try self.jsonDecoder.decode(Users.self, from: data)
                        if let user = users.first(where: { $0.username == username && $0.password == password }) {
                            completion(user, nil)
                        } else {
                            completion(nil, NetworkingError.dataNotFound)
                        }
                    } else {
                        completion(nil, NetworkingError.emptyResponse)
                    }
                } catch let err {
                    completion(nil, err)
                }
            }
        }
    }
    
    /// Retrive User from local JSON file
    /// - Parameter completion: return user data if success or else return error
    func fetchData(completion: @escaping (Data?, (any Error)?) -> Void) {
        do {
            let data = try MockReader.readJson(self.contentFile)
            completion(data, nil)
        } catch {
            completion(nil, error)
        }
    }
    
}

/// Mock class for Friends Fetch API Service
final class MockFriendsFetchAPIService: FriendsFetchService {
    
    /// Sample Data file name that to retrive for mock data
    private let contentFile: String
    /// To run code successfully or to return error for mock data
    private var isSuccessful: Bool
    /// Decoder object to decode JSON data from file for mock data
    private let jsonDecoder: JSONDecoder
    
    /// Initize MockFriendsFetchAPIService Object for mock data
    /// - Parameters:
    ///   - contentFile: Sample Data file name that to retrive
    ///   - isSuccessful: To run code successfully or to return error
    ///   - jsonDecoder: Decoder object to decode JSON data from file
    init(contentFile: String = "friends-sample-data", isSuccessful: Bool = true, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.contentFile = contentFile
        self.isSuccessful = isSuccessful
        self.jsonDecoder = jsonDecoder
    }
    
    /// Retrive list of Users from local JSON file for mock data
    /// - Parameters:
    ///   - username: username of the user that to retrive
    ///   - password: password of the user that to retrive
    ///   - completion: return list of users if success or else return error
    func fetchFriends(username: String, password: String, completion: @escaping (Users?, (any Error)?) -> Void) {
        guard isSuccessful else {
            completion(nil, NetworkingError.testing)
            return
        }
        fetchData() { data, error in
            if let error = error {
                completion(nil, error)
            } else {
                do {
                    if let data = data {
                        var users = try self.jsonDecoder.decode(Users.self, from: data)
                        if let index = users.firstIndex(where: { $0.username == username && $0.password == password }) {
                            users.remove(at: index)
                        }
                        completion(users, nil)
                    } else {
                        completion(nil, NetworkingError.emptyResponse)
                    }
                } catch (let err) {
                    completion(nil, err)
                }
            }
        }
    }
    
    /// Retrive User from local JSON file for mock data
    /// - Parameter completion: return list of users data if success or else return error
    func fetchData(completion: @escaping (Data?, (any Error)?) -> Void) {
        do {
            let data = try MockReader.readJson(self.contentFile)
            completion(data, nil)
        } catch {
            completion(nil, error)
        }
    }
    
}
