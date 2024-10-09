//
//  Dictionary+Extension.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation

// MARK: - Dictionary Extension
public extension Dictionary {
    
    func merged(withUpdate dict: Dictionary?) -> Dictionary {
        var result = self
        if let dict = dict {
            for entry in dict {
                result[entry.key] = entry.value
            }
        }
        return result
    }
    
    func merged(withoutUpdate dict: Dictionary?) -> Dictionary {
        var result = self
        if let dict = dict {
            for entry in dict {
                if result[entry.key] != nil {
                    // now val is not nil and the Optional has been unwrapped, so use it
                } else {
                    result[entry.key] = entry.value
                }
            }
        }
        return result
    }
    
    var dataObject: Data? {
        if let theJSONData = try? JSONSerialization.data(withJSONObject: self, options: []) {
            return theJSONData
        }
        return nil
    }
    
    var jsonData: Data? {
        if let theJSONData = try? JSONSerialization.data(withJSONObject: self as Any, options:[.prettyPrinted]) {
            return theJSONData
        }
        return nil
    }
    
    var jsonString: String {
        if let jsonData = jsonData, let theJSONText = String(data: jsonData, encoding: .utf8) {
            return theJSONText
        }
        return self.description
    }
    
    var json: Any? {
        if let jsonData = jsonData {
            let decoded = try? JSONSerialization.jsonObject(with: jsonData, options:[])
            return decoded
        }
        return nil
    }
    
}
