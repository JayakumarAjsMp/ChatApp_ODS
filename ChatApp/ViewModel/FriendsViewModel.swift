//
//  FriendsViewModel.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI
import CoreData

final class FriendsViewModel: ObservableObject {
    
    @Published private (set) var friends: Users?
    @Published private (set) var viewError: Error?
    
    private let apiService: FriendsFetchService
    @ObservedObject private var alertObserver: AlertObservable

    // MARK: - Public Methods
    init(apiService: FriendsFetchService = FriendsFetchAPIService(), alertObserver: AlertObservable = .shared) {
        self.apiService = apiService
        self.alertObserver = alertObserver
    }
    
    /// Gets all user from server and remove current user who call it
    /// - Parameters:
    ///   - username: username of user that want
    ///   - password: password of user that want
    func getFriends(username: String, password: String) {
        apiService.fetchFriends(username: username, password: password) { [self] fetchedFriends, error in
            guard let fetchedFriends = fetchedFriends else {
                guard let error = error else {
                    print("Failed to retrieve friends")
                    alertObserver.setToastItem(ToastItem(value: "Failed to retrieve friends"))
                    return
                }
                viewError = error
                print(error.localizedDescription)
                alertObserver.setToastItem(ToastItem(value: error.localizedDescription))
                return
            }
            self.friends = fetchedFriends
        }
    }
    
}
