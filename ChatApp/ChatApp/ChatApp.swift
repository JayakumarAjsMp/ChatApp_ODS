//
//  ChatApp.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI

@main
/// ChatApp is entry point for App
struct ChatApp: App {
    
    let persistenceController = PersistenceController.shared
    
    @StateObject var alertObserver = AlertObservable.shared
    @StateObject var naviObserver = NavigationObservable()
    
    @StateObject var userViewModel = UserViewModel()
    @StateObject var friendsViewModel = FriendsViewModel()
    @StateObject var messagesViewModel = MessagesViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(alertObserver)
                .environmentObject(naviObserver)
                .environmentObject(userViewModel)
                .environmentObject(friendsViewModel)
                .environmentObject(messagesViewModel)
        }
    }
    
}
