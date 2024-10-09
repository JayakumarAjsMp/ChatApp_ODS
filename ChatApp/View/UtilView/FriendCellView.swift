//
//  FriendCellView.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI

struct FriendCellView: View {
    
    var friendName: String
    var isCurrentUser: Bool = false
    
    var body: some View {
        Text(friendName)
            .padding(10)
            .foregroundColor(isCurrentUser ? Color.white : Color.black)
            //.background(isCurrentUser ? Color.blue : Color.gray)
            .cornerRadius(10)
    }
    
}

#Preview {
    FriendCellView(friendName: "Name list")
}
