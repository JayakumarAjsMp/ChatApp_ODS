//
//  UserViewModel.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI
import CoreData

class UserViewModel: ObservableObject {
    
    @Published private (set) var user: User?
    @Published private (set) var viewError: Error?
    
    private let apiService: UserFetchService
    private let viewContext: NSManagedObjectContext
    @ObservedObject private var alertObserver: AlertObservable

    // MARK: - Public Methods
    init(apiService: UserFetchService = UserFetchAPIService(), alertObserver: AlertObservable = .shared, viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.apiService = apiService
        self.alertObserver = alertObserver
        self.viewContext = viewContext
    }
    
    /// Fetch all user from server and find current login user and stored in local coredata database
    /// - Parameters:
    ///   - username: username of user that want to be login
    ///   - password: passsword of user that want to be login
    ///   - completion: return true if find user with same surename and password or else return error
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        apiService.fetchUser(username: username, password: password) { [self] fetchedUser, error in
            guard let fetchedUser = fetchedUser else {
                guard let error = error else {
                    print("Failed to retrieve user")
                    alertObserver.setToastItem(ToastItem(value: "Failed to retrieve user"))
                    return
                }
                viewError = error
                print(error.localizedDescription)
                alertObserver.setToastItem(ToastItem(value: error.localizedDescription))
                completion(false)
                return
            }
            self.user = fetchedUser
            store(user: fetchedUser)
            completion(true)
        }
    }
    
    /// Store user in CoreData
    /// - Parameter user: user that want to store
    func store(user: User) {
        // to ensure single user deleting already exsisting user from coredata
        deleteAllStoredUsers()
        let storedUser = StoredUser(context: viewContext)
        storedUser.id = user.id
        storedUser.username = user.username
        storedUser.password = user.password
        storedUser.name = user.name
        storedUser.uuid = user.uuid
        storedUser.avatar = user.avatar
        storedUser.createdAt = user.createdAt
        do {
            // trying to save change in coredata
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    /// Fetch user from Coredata
    func fetchStoredUsers() -> [StoredUser]? {
        let request: NSFetchRequest<StoredUser> = StoredUser.fetchRequest()
        let storedUsers = try? viewContext.fetch(request)
        return storedUsers
    }
    
    /// Delete all users from Coredata
    func deleteAllStoredUsers() {
        if let storedUsers = fetchStoredUsers() {
            for storedUser in storedUsers {
                viewContext.delete(storedUser)
            }
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    /// Delete single User from Coredata by using user
    /// - Parameter user: user that want to delete
    func deleteStoredUser(user: User) {
        if let storedUser = fetchStoredUsers()?.first(where: { $0.username == user.username && $0.password == user.password && $0.uuid == user.uuid }) {
            viewContext.delete(storedUser)
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func setUser(storedUser: StoredUser) {
        if let id = storedUser.id, let username = storedUser.username, let password = storedUser.password, let name = storedUser.name, let avatar = storedUser.avatar, let uuid = storedUser.uuid, let createdAt = storedUser.createdAt {
            user = User(id: id, username: username, password: password, name: name, avatar: avatar, uuid: uuid, createdAt: createdAt)
        }
    }
    
}
