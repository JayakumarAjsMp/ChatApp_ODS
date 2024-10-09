//
//  User.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation

// MARK: - Helper functions for creating encoders and decoders
public func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

public func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

class User: Codable {
    
    let id: String
    let username: String
    let password: String
    let name: String
    let avatar: String
    let uuid: UUID
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, username, password, name, avatar, uuid, createdAt
    }
    
    init(id: String, username: String, password: String, name: String, avatar: String, uuid: UUID, createdAt: String) {
        self.id = id
        self.username = username
        self.password = password
        self.name = name
        self.avatar = avatar
        self.uuid = uuid
        self.createdAt = createdAt
    }
    
    init() {
        self.id = "1"
        self.username = "username"
        self.password = "password"
        self.name = "name"
        self.avatar = "avatar"
        self.uuid = UUID()
        self.createdAt = "createdAt"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        password = try container.decode(String.self, forKey: .password)
        name = try container.decode(String.self, forKey: .name)
        avatar = try container.decode(String.self, forKey: .avatar)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(username, forKey: .username)
        try? container.encode(password, forKey: .password)
        try? container.encode(name, forKey: .name)
        try? container.encode(avatar, forKey: .avatar)
        try? container.encode(uuid, forKey: .uuid)
        try? container.encode(createdAt, forKey: .createdAt)
    }
    
}

// MARK: User convenience initializers and mutators
extension User {
    
    convenience init?(data: Data?) throws {
        if let data = data {
            let me = try newJSONDecoder().decode(User.self, from: data)
            self.init(id: me.id, username: me.username, password: me.password, name: me.name, avatar: me.avatar, uuid: me.uuid, createdAt: me.createdAt)
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
           let username = dict["username"] as? String,
           let password = dict["password"] as? String,
           let name = dict["firstname"] as? String,
           let avatar = dict["avatar"] as? String,
           let uuid = dict["uuid"] as? UUID,
           let create = dict["createdAt"] as? String {
            self.init(id: id, username: username, password: password, name: name, avatar: avatar, uuid: uuid, createdAt: create)
        } else {
            return nil
        }
    }
    
    func with(
        id: String? = nil,
        username: String? = nil,
        password: String? = nil,
        name: String? = nil,
        avatar: String? = nil,
        uuid: UUID? = nil,
        createdAt: String? = nil
    ) -> User {
        return User(
            id: id ?? self.id,
            username: username ?? self.username,
            password: password ?? self.password,
            name: name ?? self.name,
            avatar: avatar ?? self.avatar,
            uuid: uuid ?? self.uuid,
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

//MARK: - [User] to Users
typealias Users = [User]
extension Array where Element == Users.Element {
    
    init(_ dict: [AnyObject]) {
        self.init()
        for item in dict {
            if let dict = item as? [String: Any] {
                if let user = User(dict) {
                    self.append(user)
                }
            }
        }
    }
    
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Users.self, from: data)
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
    
    func userTask(with url: URL, completionHandler: @escaping (User?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
    
    public func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }
    
}
