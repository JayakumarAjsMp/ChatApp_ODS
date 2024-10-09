//
//  Message.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation

/// Message object
class Message: Codable, Hashable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return (lhs.toUser == rhs.toUser) && (lhs.fromUser == rhs.fromUser) && (lhs.message == rhs.message) && (lhs.id == rhs.id)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(fromUser)
        hasher.combine(toUser)
        hasher.combine(createdAt)
        hasher.combine(message)
    }
    
    var id: String
    var toUser: String
    var message: String
    var fromUser: String
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, toUser, fromUser, toUserAvatar, fromUserAvatar, uuid, createdAt, message
    }
    
    init(id: String, toUser: String, message: String, fromUser: String, createdAt: String) {
        self.id = id
        self.toUser = toUser
        self.message = message
        self.fromUser = fromUser
        self.createdAt = createdAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        toUser = try container.decode(String.self, forKey: .toUser)
        message = try container.decode(String.self, forKey: .message)
        fromUser = try container.decode(String.self, forKey: .fromUser)
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(toUser, forKey: .toUser)
        try? container.encode(message, forKey: .message)
        try? container.encode(fromUser, forKey: .fromUser)
        try? container.encode(createdAt, forKey: .createdAt)
    }
    
}

// MARK: Message convenience initializers and mutators
extension Message {
    
    convenience init?(data: Data?) throws {
        if let data = data {
            let me = try newJSONDecoder().decode(Message.self, from: data)
            self.init(id: me.id, toUser: me.toUser, message: me.message, fromUser: me.fromUser, createdAt: me.createdAt)
         } else {
            return nil
        }
    }
    
    convenience init?(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init?(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    convenience init?(_ dict: Dictionary<AnyHashable, Any>) {
        if let id = dict["id"] as? String,
           let toUser = dict["toUser"] as? String,
           let message = dict["message"] as? String,
           let fromUser = dict["fromUser"] as? String,
           let create = dict["createdAt"] as? String {
            self.init(id: id, toUser: toUser, message: message, fromUser: fromUser, createdAt: create)
        } else {
            return nil
        }
    }
    
    func with(
        id: String? = nil,
        toUser: String? = nil,
        message: String? = nil,
        fromUser: String? = nil,
        createdAt: String? = nil
    ) -> Message {
        return Message(
            id: id ?? self.id,
            toUser: toUser ?? self.toUser,
            message: message ?? self.message,
            fromUser: fromUser ?? self.fromUser,
            createdAt: createdAt ?? self.createdAt
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
    
}

//MARK: - [Message] to Messages
typealias Messages = [Message]
extension Array where Element == Messages.Element {
    
    init(_ dict: [AnyObject]) {
        self.init()
        for item in dict {
            if let dict = item as? [String: Any] {
                if let message = Message(dict) {
                    self.append(message)
                }
            }
        }
    }
    
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Messages.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
    
}
 
// MARK: - URLSession response handlers
extension URLSession {
    
    func messageTask(with url: URL, completionHandler: @escaping (Message?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
    
}
