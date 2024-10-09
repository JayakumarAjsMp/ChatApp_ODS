//
//  MessagesViewModel.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI
import CoreData

final class MessagesViewModel: ObservableObject {
    
    @Published private (set) var messages: Messages?
    @Published private (set) var viewError: Error?
    
    private let fetchAPIService: MessagesFetchService
    private let storeAPIService: MessagesStoreService
    @ObservedObject private var alertObserver: AlertObservable

    // MARK: - Public Methods
    init(fetchAPIService: MessagesFetchService = MessagesFetchAPIService(), storeAPIService: MessagesStoreService = MessagesStoreAPIService(), alertObserver: AlertObservable = .shared) {
        self.fetchAPIService = fetchAPIService
        self.storeAPIService = storeAPIService
        self.alertObserver = alertObserver
    }
    
    /// Gets all messages from server and remove all user message
    /// - Parameters:
    ///   - username: username of user that messages want to be retrive
    ///   - fromUser: username of other user that messages want to be retrive
    func getMessages(username: String, fromUser: String) {
        fetchAPIService.fetchMessages(username: username, fromUser: fromUser) { [self] fetchedMessages, error in
            guard let fetchedMessages = fetchedMessages else {
                guard let error = error else {
                    print("Failed to retrieve messages")
                    alertObserver.setToastItem(ToastItem(value: "Failed to retrieve messages"))
                    return
                }
                viewError = error
                print(error.localizedDescription)
                alertObserver.setToastItem(ToastItem(value: error.localizedDescription))
                return
            }
            setMessages(fetchedMessages)
        }
    }
    
    /// Store message to server from current user who call it
    /// - Parameters:
    ///   - username: username of user that messages want to be retrive
    ///   - fromUser: username of other user that messages want to be retrive
    func sendMessage(username: String, fromUser: String, message: [String: Any]) {
        storeAPIService.storeMessage(username: username, message: message) { [self] isSucess, error in
            guard let error = error else {
                if isSucess {
                    print("Message stored success")
                    getMessages(username: username, fromUser: fromUser)
                } else {
                    print("Message stored failed")
                    alertObserver.setToastItem(ToastItem(value: "Failed to send message"))
                }
                return
            }
            viewError = error
            print(error.localizedDescription)
            alertObserver.setToastItem(ToastItem(value: error.localizedDescription))
        }
    }
    
    func setMessages(_ list: Messages? = nil) {
        messages = list
    }
    
}
