//
//  AlertObservable.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation

class AlertObservable: ObservableObject {
    
    static let shared = AlertObservable()
    
    /// Toast message to show to user
    @Published var toastItem: ToastItem?
    func setToastItem(_ toast: ToastItem? = nil) {
        toastItem = toast
    }
    
    /// Show Loader or not while retrive
    @Published var isLoading = false
    /// Show Loader while retrive
    func showLoader() {
        isLoading = true
    }
    
    /// Hide Loader 
    func hideLoader() {
        isLoading = false
    }
    
}
