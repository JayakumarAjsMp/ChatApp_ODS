//
//  UserAPIService.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation
import Combine

/// UserFetchService to retrive User from network call
protocol UserFetchService: NetworkFetchService {
    
    /// Retrive list of Users from network call
    /// - Parameters:
    ///   - username: username of the user that to retrive
    ///   - password: password of the user that to retrive
    ///   - completion: return list of users if success or else return error
    func fetchUser(username: String, password: String, completion: @escaping (User?, Error?) -> Void)
}

/// UserFetchAPIService to retrive User from servers
final class UserFetchAPIService: UserFetchService {
    
    /// Retrive list of Users from server
    /// - Parameters:
    ///   - username: username of the user that to retrive
    ///   - password: password of the user that to retrive
    ///   - completion: return list of users if success or else return error
    func fetchUser(username: String, password: String, completion: @escaping (User?, (any Error)?) -> Void) {
        fetchData() { data, error in
            if let error = error {
                completion(nil, error)
            } else {
                do {
                    if let data = data {
                        let users = try Users(data: data)
                        if let user = users.first(where: { $0.username == username && $0.password == password }) {
                            completion(user, nil)
                        } else {
                            completion(nil, NetworkingError.dataNotFound)
                        }
                    } else {
                        completion(nil, NetworkingError.emptyResponse)
                    }
                } catch (let err) {
                    completion(nil, err)
                }
            }
        }
    }
    
    /// Retrive User from server
    /// - Parameter completion: return user data if success or else return error
    func fetchData(completion: @escaping (Data?, (any Error)?) -> Void) {
        let apiServiceManager = APIServiceManager(host: CONSTANT.API, path: CONSTANT.FETCH_USER, header: APIRequestManager.getRequestHeader())
        apiServiceManager.info()
        apiServiceManager.getData() { apiResponse, httpResponse, error in
            completion(apiResponse, error)
        }
    }
    
}

/// FriendsFetchService to fetch list of users from network call
protocol FriendsFetchService: NetworkFetchService {
    
    /// Retrive list of Users from network call
    /// - Parameters:
    ///   - username: username of the user that to retrive
    ///   - password: password of the user that to retrive
    ///   - completion: return list of users if success or else return error
    func fetchFriends(username: String, password: String, completion: @escaping (Users?, Error?) -> Void)
    
}

final class FriendsFetchAPIService: FriendsFetchService {
    
    /// Retrive list of Users from server
    /// - Parameters:
    ///   - username: username of the user that to retrive
    ///   - password: password of the user that to retrive
    ///   - completion: return list of users if success or else return error
    func fetchFriends(username: String, password: String, completion: @escaping (Users?, (any Error)?) -> Void) {
        fetchData() { data, error in
            if let error = error {
                completion(nil, error)
            } else {
                do {
                    if let data = data {
                        var users = try Users(data: data)
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
    
    /// Retrive User from server
    /// - Parameter completion: return list of users data if success or else return error
    func fetchData(completion: @escaping (Data?, (any Error)?) -> Void) {
        let apiServiceManager = APIServiceManager(host: CONSTANT.API, path: CONSTANT.FETCH_USER, header: APIRequestManager.getRequestHeader())
        apiServiceManager.info()
        apiServiceManager.getData() { apiResponse, httpResponse, error in
            completion(apiResponse, error)
        }
    }
    
}
