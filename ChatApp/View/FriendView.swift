//
//  FriendView.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI

struct FriendView: View {
    
    var currentFriend: User
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Group {
                if let url = URL(string: currentFriend.avatar) {
                    AsyncImage(url: url,
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
            FriendCellView(friendName: currentFriend.username)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(2)
    }
}

#Preview {
    FriendView(currentFriend: User())
}
