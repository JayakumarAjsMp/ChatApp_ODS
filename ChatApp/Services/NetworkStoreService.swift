//
//  NetworkStoreService.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation
import Combine

/// Network Store service to store data in network call
protocol NetworkStoreService {
    
    /// Store data in network call
    /// - Parameter completion: return data if success or else return error
    func storeData(message: [String: Any], completion: @escaping (Data?, Error?) -> Void)
}
