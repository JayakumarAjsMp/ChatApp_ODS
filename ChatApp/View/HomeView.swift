//
//  HomeView.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var alertObserver: AlertObservable
    @EnvironmentObject var naviObserver: NavigationObservable
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    @EnvironmentObject var messagesViewModel: MessagesViewModel
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    LazyVStack {
                        HStack {
                            Spacer()
                            Menu {
                                Button("Logout", action: {
                                    UserDefaults.standard.setValue(false, forKey: "isLogin")
                                    naviObserver.setMainScreen(.login)
                                })
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                            }
                            .frame(width: 20, height: 20)
                        }
                        ForEach(friendsViewModel.friends ?? [], id: \.id) { friend in
                            NavigationLink(destination: ChatView(fromUser: friend) // Navigate to ChatView
                                .environmentObject(alertObserver)
                                .environmentObject(userViewModel)
                                .environmentObject(friendsViewModel)
                                .environmentObject(messagesViewModel), label: {
                                    FriendView(currentFriend: friend) // List of user
                                })
                        }
                    }
                }
            }
        }
        .onAppear() {
            if let username = userViewModel.user?.username, let password = userViewModel.user?.password {
                friendsViewModel.getFriends(username: username, password: password)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AlertObservable.shared)
        .environmentObject(NavigationObservable())
        .environmentObject(UserViewModel())
        .environmentObject(MessagesViewModel())
        .environmentObject(FriendsViewModel())
}
