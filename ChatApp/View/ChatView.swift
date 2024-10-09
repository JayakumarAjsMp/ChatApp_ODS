//
//  ChatView.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI
import Combine

struct ChatView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var messagesViewModel: MessagesViewModel
    
    @State var newMessage: String = ""
    
    var fromUser: User
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(messagesViewModel.messages ?? [], id: \.id) { message in
                            MessageView(currentMessage: message, user: userViewModel.user, fromUser: fromUser) // List of messages from both users
                                .id(message)
                        }
                    }
                    .onReceive(Just(messagesViewModel.messages)) { _ in
                        withAnimation {
                            proxy.scrollTo(messagesViewModel.messages?.last, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(messagesViewModel.messages?.last, anchor: .bottom)
                        }
                    }
                }
                // send new message
                HStack {
                    TextField("Send a message", text: $newMessage)
                        .textFieldStyle(.roundedBorder) // Message want to send
                    Button(action: sendMessage)   {
                        Image(systemName: "paperplane")
                    }
                }
                .padding()
                .shadow(radius: 2)
            }
        }
        .navigationTitle(fromUser.username)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    messagesViewModel.setMessages()
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
        .onAppear() {
            messagesViewModel.getMessages(username: userViewModel.user?.username ?? "", fromUser: fromUser.username)
        }
    }
    
    /// Send message to server action
    func sendMessage() {
        if !newMessage.isEmpty {
            let message = [
                "toUser": fromUser.username,
                "message": newMessage,
                "fromUser": userViewModel.user?.username
            ]
            messagesViewModel.sendMessage(username: userViewModel.user?.username ?? "", fromUser: fromUser.username, message: message as [String : Any])
            newMessage = ""
        }
    }
}
