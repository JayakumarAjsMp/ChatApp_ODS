//
//  MessagesAPIService.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation

/// MessagesFetchService retrive messages from network call
protocol MessagesFetchService: NetworkFetchService {
    
    /// Retrive list of messages from network call
    /// - Parameters:
    ///   - username: username of current user that mesages to be retrive
    ///   - fromUser: username of other user that messages to be retrive
    ///   - completion: return list of messages for user from other user if success or else return error
    func fetchMessages(username: String, fromUser: String, completion: @escaping (Messages?, Error?) -> Void)
}

/// MessagesFetchAPIService retrive list of messages from server
final class MessagesFetchAPIService: MessagesFetchService {
    
    /// Retrive list of messages from server
    /// - Parameters:
    ///   - username: username of current user that mesages to be retrive
    ///   - fromUser: username of other user that messages to be retrive
    ///   - completion: return list of messages for user from other user if success or else return error
    func fetchMessages(username: String, fromUser: String, completion: @escaping (Messages?, (any Error)?) -> Void) {
        fetchData() { data, error in
            if let error = error {
                completion(nil, error)
            } else {
                do {
                    if let data = data {
                        let allMessages = try Messages(data: data)
                        let messages = allMessages.filter({ ($0.fromUser == username && $0.toUser == fromUser) || ($0.toUser == username && $0.fromUser == fromUser) })
                        completion(messages, nil)
                    } else {
                        completion(nil, NetworkingError.emptyResponse)
                    }
                } catch (let err) {
                    completion(nil, err)
                }
            }
        }
    }
    
    /// Retrive messages data from local JSON file for mock data
    /// - Parameter completion: return user data if success or else return error
    func fetchData(completion: @escaping (Data?, (any Error)?) -> Void) {
        let apiServiceManager = APIServiceManager(host: CONSTANT.API, path: CONSTANT.FETCH_MESSAGE, header: APIRequestManager.getRequestHeader())
        apiServiceManager.info()
        apiServiceManager.getData() { apiResponse, httpResponse, error in
            completion(apiResponse, error)
        }
    }
    
}

/// MessagesStoreService to store message in network call
protocol MessagesStoreService: NetworkStoreService {
    
    /// Store message to network call
    /// - Parameter completion: return message data if success or else return error
    func storeMessage(username: String, message: [String : Any], completion: @escaping (Bool, Error?) -> Void)
    
}

/// MessagesStoreAPIService to store message in server
final class MessagesStoreAPIService: MessagesStoreService {
    
    /// Store list of messages to server
    /// - Parameters:
    ///   - username: username of current user
    ///   - message: message that send to ther server
    ///   - completion: return true if storing success or else return error
    func storeMessage(username: String, message: [String : Any], completion: @escaping (Bool, (any Error)?) -> Void) {
        storeData(message: message) { data, error in
            if let error = error {
                completion(false, error)
            } else {
                do {
                    if data != nil {
                        /*if let allMessages = try? Messages(data: data) {
                            let messages = allMessages.filter({ $0.fromUser == username || $0.toUser == username })
                            print(allMessages)
                            print(messages)
                        }*/
                        completion(true, nil)
                    } else {
                        completion(false, NetworkingError.emptyResponse)
                    }
                }
            }
        }
    }
    
    /// Store message to server
    /// - Parameter completion: return message data if success or else return error
    func storeData(message: [String : Any], completion: @escaping (Data?, (any Error)?) -> Void) {
        let apiServiceManager = APIServiceManager(host: CONSTANT.API, path: CONSTANT.FETCH_MESSAGE, header: APIRequestManager.getRequestHeader(), body: message)
        apiServiceManager.info()
        apiServiceManager.dataPost() { apiResponse, httpResponse, error in
            completion(apiResponse, error)
        }
    }
    
}
