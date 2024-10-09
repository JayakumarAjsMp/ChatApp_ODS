//
//  ContentView.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI
import SimpleToast
import ActivityIndicatorView

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoredUser.name, ascending: true)],
        animation: .default)
    private var storedUsers: FetchedResults<StoredUser>
    
    @EnvironmentObject var alertObserver: AlertObservable
    @EnvironmentObject var naviObserver: NavigationObservable
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    @EnvironmentObject var messagesViewModel: MessagesViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Text(" ")
                    .font(.system(size: 1))
                    .frame(height: 1)
                if naviObserver.mainScreen == .login || storedUsers.count == 0 || !UserDefaults.standard.bool(forKey: "isLogin") {
                    LoginView() // Login screen
                        .environmentObject(userViewModel)
                        .environmentObject(alertObserver)
                        .environmentObject(naviObserver)
                } else {
                    HomeView() // Home screen
                        .environmentObject(userViewModel)
                        .environmentObject(alertObserver)
                        .environmentObject(naviObserver)
                        .environmentObject(friendsViewModel)
                        .environmentObject(messagesViewModel)
                }
            }
            .padding(.horizontal, 5)
            if alertObserver.isLoading {
                ZStack {
                    Color.gray.opacity(0.2)
                    ActivityIndicatorView(isVisible: $alertObserver.isLoading, type: .default(count: 5)).frame(width: 25, height: 25)
                        .foregroundColor(.blue) // Loader
                }
            }
        }
        .onAppear() {
            if let storedUser = storedUsers.first {
                userViewModel.setUser(storedUser: storedUser)
                naviObserver.setMainScreen(.home)
            }
        }
        .simpleToast(item: $alertObserver.toastItem, options: SimpleToastOptions(alignment: .bottom, hideAfter: 2, animation: .easeInOut, modifierType: .scale)) { // Showing toast message to user
            HStack {
                if let value = alertObserver.toastItem?.value {
                    Spacer()
                    Text(value) // toast message
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                                .shadow(color: Color.gray, radius: 1, x: 0, y: 0)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    Spacer()
                }
            }
            .padding(10)
        }
    }
    
}

#Preview {
    ContentView()
        .environmentObject(NavigationObservable())
        .environmentObject(AlertObservable.shared)
        .environmentObject(UserViewModel())
        .environmentObject(FriendsViewModel())
        .environmentObject(MessagesViewModel())
}
