//
//  MockMessagesAPIService.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation

/// Mock class for Message Fetch API Service for mock data
final class MockMessagesFetchAPIService: MessagesFetchService {
    
    
    /// Sample Data file name that to retrive
    private let contentFile: String
    /// To run code successfully or to return error
    private var isSuccessful: Bool
    /// Decoder object to decode JSON data from file
    private let jsonDecoder: JSONDecoder
    
    /// Initize MockMessagesFetchAPIService Object
    /// - Parameters:
    ///   - contentFile: Sample Data file name that to retrive
    ///   - isSuccessful: To run code successfully or to return error
    ///   - jsonDecoder: Decoder object to decode JSON data from file
    init(contentFile: String = "messages-sample-data", isSuccessful: Bool = true, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.contentFile = contentFile
        self.isSuccessful = isSuccessful
        self.jsonDecoder = jsonDecoder
    }
    
    /// Retrive list of messages from local json file for mock data
    /// - Parameters:
    ///   - username: username of current user that mesages to be retrive
    ///   - fromUser: username of other user that messages to be retrive
    ///   - completion: return list of messages for user from other user if success or else return error
    func fetchMessages(username: String, fromUser: String, completion: @escaping (Messages?, (any Error)?) -> Void) {
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
                        let allMessages = try self.jsonDecoder.decode(Messages.self, from: data)
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
        do {
            let data = try MockReader.readJson(self.contentFile)
            completion(data, nil)
        } catch {
            completion(nil, error)
        }
    }
    
}

/// Mock class for Message Store API Service for mock data
final class MockMessagesStoreAPIService: MessagesStoreService {
    
    private let contentFile: String
    private var isSuccessful: Bool
    
    init(contentFile: String = "messages-sample-write-data",
         isSuccessful: Bool = true) {
        self.contentFile = contentFile
        self.isSuccessful = isSuccessful
    }
    
    /// Store list of messages to local json file for mock data
    /// - Parameters:
    ///   - username: username of current user
    ///   - message: message that send to ther server
    ///   - completion: return true if storing success or else return error
    func storeMessage(username: String, message: [String : Any], completion: @escaping (Bool, (any Error)?) -> Void) {
        guard isSuccessful else {
            completion(false, NetworkingError.testing)
            return
        }
        storeData(message: message) { data, error in
            if let error = error {
                completion(false, error)
            } else {
                do {
                    try MockReader.saveToJsonFile(self.contentFile, data)
                    completion(true, nil)
                } catch let err {
                    completion(false, err)
                }
            }
        }
    }
    
    /// Store message to local JSON file for mock data
    /// - Parameter completion: return message data if success or else return error
    func storeData(message: [String : Any], completion: @escaping (Data?, (any Error)?) -> Void) {
        do {
            let messages = [message]
            let jsonData = try JSONSerialization.data(withJSONObject: messages as Any, options: [.prettyPrinted])
            completion(jsonData, nil)
        } catch let error {
            completion(nil, error)
        }
    }
    
}
