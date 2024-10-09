//
//  NetworkFetchService.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation
import Combine

/// Network Fetch service to fetch data from network call
protocol NetworkFetchService {
    
    //// Retrive Data from network call
    /// - Parameter completion: return user data if success or else return error
    func fetchData(completion: @escaping (Data?, Error?) -> Void)
    
}
