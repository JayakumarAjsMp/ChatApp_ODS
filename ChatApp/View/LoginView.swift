//
//  LoginView.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var alertObserver: AlertObservable
    @EnvironmentObject var naviObserver: NavigationObservable
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text("Login")
                .font(.largeTitle)
                .bold()
            HStack {
                TextField("username", text: $username)
                    .textFieldStyle(.roundedBorder)
                Image(systemName: "person.circle")
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle())
            )
            .padding(.horizontal)
            
            HStack {
                TextField("password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                Image(systemName: "eye.circle")
            }
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle())
            )
            .padding(.horizontal)
            
            Button(action: login) {
                HStack {
                    Image(systemName: "paperplane")
                    Text("Login")
                        .bold()
                }
                .foregroundColor(.white)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.blue)
                )
            }
            .padding()
            Spacer()
        }
    }
    
    /// Login with username and password
    func login() {
        if username.isEmpty {
            alertObserver.setToastItem(ToastItem(value: "Please enter username!"))
            return
        }
        if password.isEmpty {
            alertObserver.setToastItem(ToastItem(value: "Please enter pasword!"))
            return
        }
        alertObserver.showLoader()
        userViewModel.login(username: username, password: password) { islogin in
            UserDefaults.standard.setValue(islogin, forKey: "isLogin")
            if islogin {
                naviObserver.setMainScreen(.home)
            }
            alertObserver.hideLoader()
        }
    }
    
}

#Preview {
    LoginView()
}
