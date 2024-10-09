//
//  MockReader.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation

struct MockReader {
    
    /// Read the content of the file
    /// - Parameter filename: name of the file that to be retrive
    /// - Returns: return of that file if read success or else return error
    static func readJson(_ filename: String) throws -> Data? {
        do {
            if let filePath = Bundle.main.path(forResource: filename, ofType: "json"), !filename.isEmpty {
                let fileUrl = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: fileUrl)
                return data
            } else {
                throw FileError.notFound
            }
        } catch {
            throw FileError.reading(error)
        }
    }
    
    /// Write the content to the file
    /// - Parameters:
    ///   - filename: name of the file that to be write
    ///   - data: data need to be written to file
    static func saveToJsonFile(_ filename: String, _ data: Data?) throws {
        do {
            guard let data = data else {
                throw FileError.emptyData
            }
            if let filePath = Bundle.main.path(forResource: filename, ofType: "json"), !filename.isEmpty {
                let fileUrl = URL(fileURLWithPath: filePath)
                try data.write(to: fileUrl, options: [])
            } else {
                throw FileError.notFound
            }
        } catch {
            print(error)
            throw FileError.write(error)
        }
    }
    
}
