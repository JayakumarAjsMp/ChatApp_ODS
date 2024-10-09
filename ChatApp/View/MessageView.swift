//
//  MessageView.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI

struct MessageView : View {
    
    var currentMessage: Message
    var user: User?
    var fromUser: User?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if currentMessage.toUser == user?.username {
                Group {
                    if let userAvatar = fromUser?.avatar {
                        AsyncImage(url: URL(string: userAvatar)!,
                                   placeholder: { Image(systemName: "person.circle.fill").resizable() },
                                   image: { Image(uiImage: $0).resizable() })
                    } else {
                        Image(systemName: "person.circle.fill").resizable()
                    }
                }
                .padding(3)
                .background(
                    Circle()
                        .fill(Color.white)
                )
                .frame(width: 40, height: 40, alignment: .center)
                .cornerRadius(20)
                .shadow(radius: 3)
            } else {
                Spacer()
            }
            MessageCellView(contentMessage: currentMessage.message,
                            isCurrentUser: currentMessage.fromUser == user?.username)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(2)
    }
}


#Preview {
    MessageView(currentMessage: Message(id: "1", toUser: "AjsH", message: "This is a single message cell with avatar. If user is current user, we won't display the avatar.", fromUser: "Ajs", createdAt:" Date()"))
}
