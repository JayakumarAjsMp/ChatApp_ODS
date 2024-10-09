//
//  NavigationObservable.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation

enum MainScreen {
    
    case login
    case home
    
}

/// Navigation through app screen
class NavigationObservable: ObservableObject {
    
    @Published var mainScreen: MainScreen = .login
    /// Navigation through app screen
    /// - Parameter screen: screen that need to show
    func setMainScreen(_ screen: MainScreen = .login) {
        mainScreen = screen
    }
    
}
