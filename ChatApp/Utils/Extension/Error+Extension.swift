//
//  Error+Extension.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation

enum FileError: Error, CustomStringConvertible, LocalizedError {
    case notFound
    case badData
    case emptyData
    case reading (Error)
    case write (Error)
    
    var description: String {
        switch self {
        case .notFound:
            return "File not found"
        case .badData:
            return "Bad data in reading/writing file"
        case .emptyData:
            return "Empty data in reading/writing file"
        case .reading(let error):
            return "File reading error: \(error.localizedDescription)"
        case .write(let error):
            return "File writing error: \(error.localizedDescription)"
        }
    }
    
    var errorDescription: String? {
        return NSLocalizedString(self.description, comment: self.description)
    }
}

enum NetworkingError: Error, CustomStringConvertible, LocalizedError {
    case invalidURL
    case invalidResponse
    case testing
    case emptyResponse
    case dataNotFound
    case network(Error)
    case parsing(Error)
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "The response is invalid."
        case .emptyResponse:
            return "The response is empty."
        case .dataNotFound:
            return "The response is data not found."
        case .testing:
            return "Testing failed "
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .parsing(let error):
            return "Parsing error: \(error.localizedDescription)"
        }
    }
    
    var errorDescription: String? {
        return NSLocalizedString(self.description, comment: self.description)
    }

}
