//
//  MessageCellView.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI

struct MessageCellView: View {
    
    var contentMessage: String
    var isCurrentUser: Bool
    
    var body: some View {
        Text(contentMessage)
            .padding(10)
            .foregroundColor(Color.white)
            .background(isCurrentUser ? Color.green : Color.blue)
            .cornerRadius(10)
    }
    
}

#Preview {
    MessageCellView(contentMessage: "Tis is testing message", isCurrentUser: false)
}
