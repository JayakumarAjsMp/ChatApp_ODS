//
//  APIServiceManganer.swift
//  ChatApp
//
//  Created by Jayakumar Arasan on 08/10/24.
//

import Foundation

class APIServiceManager: NSObject {
    
    public var host: String
    public var path: String
    public var query: String
    
    public var body: [String: Any]?
    public var header: [String: String]?
    
    public init(host: String, path: String = "", query: String = "", header: [String: String]? = nil, body: [String: Any]? = nil) {
        self.host = host
        self.path = path
        self.query = query
        self.body = body
        self.header = header
    }
    
    var desc: String {
        get {
            var description = ""
            if !host.isEmpty {
                description = description + "Host - \(host)\n"
            }
            if !path.isEmpty {
                description = description + "Path - \(path)\n"
            }
            if !query.isEmpty {
                description = description + "Query - \(query)\n"
            }
            if let header = header?.jsonString {
                description = description + "Header - \(header)\n"
            }
            if let body = body?.jsonString {
                description = description + "Body - \(body)\n"
            }
            return description
        }
    }
    
    public func info() {
        print(desc)
    }
    
    func getData(withAuth auth: Bool = false, cachePolicy: NSURLRequest.CachePolicy? = nil, timeout: TimeInterval = 30.0, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var header = [String: String]()
        header = header.merged(withUpdate: self.header)
        let requestManager = APIRequestManager()
        requestManager.get(host: host, path: path, query: query, header: header, body: body, cachePolicy: cachePolicy, timeout: timeout) { (data, response, error) in
            if let error = error {  // Handle network error
                print(error)
                completion(data, response, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {    // Handle invalid response
                completion(data, response, NetworkingError.invalidResponse)
                return
            }
            if httpResponse.statusCode == 200 {
                if let data = data {// If success, return data
                    completion( data, response, error)
                } else {    // Handle empty response
                    completion(data, response, error)
                }
            } else {    // Handle other error cases
                completion(data, response, error)
            }
        }
    }
    
    func dataPost(withAuth auth: Bool = false, cachePolicy: NSURLRequest.CachePolicy? = nil, timeout: TimeInterval = 30.0, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var header = [String: String]()
        header = header.merged(withUpdate: self.header)
        let requestManager = APIRequestManager()
        requestManager.post(host: host, path: path, query: query, header: header, body: body, cachePolicy: cachePolicy, timeout: timeout) { (data, response, error) in
            if let error = error {  // Handle network error
                print(error)
                completion(data, response, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {    // Handle invalid response
                completion(data, response, NetworkingError.invalidResponse)
                return
            }
            if httpResponse.statusCode == 200 {
                if let data = data {// If success, return data
                    completion( data, response, error)
                } else {    // Handle empty response
                    completion(data, response, error)
                }
            } else {    // Handle other error cases
                completion(data, response, error)
            }
        }
    }
    
    func postMultipart(withAuth auth: Bool = true, fileName: String = "imageFile.png", body: Data?, cachePolicy: NSURLRequest.CachePolicy? = nil, timeout: TimeInterval = 30.0, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var header = [String: String]()
        header = header.merged(withUpdate: self.header)
        let requestManager = APIRequestManager()
        requestManager.postMultipart(host: host, path: path, query: query, fileName: fileName, body: body, cachePolicy: cachePolicy, timeout: timeout) { (data, response, error) in
            if let error = error {  // Handle network error
                print(error)
                completion(nil, response, error)
                return
            }
            guard response is HTTPURLResponse else {    // Handle invalid response
                completion(data, response, NetworkingError.invalidResponse)
                return
            }
            completion(data, response, error)
        }
    }
    
}

fileprivate let dohURLs = [DoHConfigurarion.google, DoHConfigurarion.cloudflare]

class APIRequestManager: NSObject {
    
    var completion: ((Data?, URLResponse?, Error?) -> Void)?
    
    func post(host: String, path: String = "", query: String = "", header: [String: String]? = nil, body: [String: Any]? = nil, cachePolicy: NSURLRequest.CachePolicy? = nil, timeout: TimeInterval = 30.0,  completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.completion = completion
        var urlStr = "\(host)\(path)".removeSpace()
        if !query.isEmpty {
            urlStr = "\(urlStr)?\(query)"
        }
        print("url \(urlStr) \n request data : \(body?.jsonString ?? "")")
        var request: URLRequest? = nil
        if let url = URL(string: urlStr) {
            request = URLRequest(url: url)
        }
        if var request = request {
            request.httpMethod = "POST"
            request.httpShouldHandleCookies = false
            request.allHTTPHeaderFields = header
            
            
            let postData: Data? = body?.dataObject
            request.httpBody = postData
            print("request -> \(request.allHTTPHeaderFields ?? [:])")
            
            let configuration = URLSessionConfiguration.default
            if let cachePolicy = cachePolicy {
                configuration.requestCachePolicy = cachePolicy
                let urlCache = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "myCacheDirectory")
                URLCache.shared = urlCache
            }
            if #available(iOS 14.0, *) {
                if let doh = dohURLs.randomElement() {
                    NWParameters.PrivacyContext.default.requireEncryptedNameResolution(true, fallbackResolver: .https(doh.httpsURL, serverAddresses: doh.serverAddresses))
                } else {
                    let cloudflare = DoHConfigurarion.cloudflare
                    NWParameters.PrivacyContext.default.requireEncryptedNameResolution(true, fallbackResolver: .https(cloudflare.httpsURL, serverAddresses: cloudflare.serverAddresses))
                }
            } else {
                let dohProtocolClasses = [DOHURLProtocol.self]
                configuration.protocolClasses = dohProtocolClasses
            }
            if(timeout > 0.0) {
                configuration.timeoutIntervalForRequest = timeout
                configuration.timeoutIntervalForResource = timeout + 2.0
            }
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            let postDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
                print(request)
                DispatchQueue.main.async {
                    completion(data, response, error)
                }
            })
            postDataTask.resume()
        }
    }
    
    func get(host: String, path: String = "", query: String = "", header: [String: String]? = nil, body: [String: Any]? = nil, cachePolicy: NSURLRequest.CachePolicy? = nil, timeout: TimeInterval = 30.0, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.completion = completion
        var urlStr = "\(host)\(path)".removeSpace()
        if !query.isEmpty {
            urlStr = "\(urlStr)?\(query)"
        }
        print("url \(urlStr) \n request data : \(body?.jsonString ?? "")")
        var request: URLRequest? = nil
        if let url = URL(string: urlStr) {
            request = URLRequest(url: url)
        }
        if var request = request {
            request.httpShouldHandleCookies = false
            request.allHTTPHeaderFields = header
            let configuration = URLSessionConfiguration.default
            if let cachePolicy = cachePolicy {
                configuration.requestCachePolicy = cachePolicy
                let urlCache = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "myCacheDirectory")
                URLCache.shared = urlCache
            }
            if timeout > 0.0 {
                configuration.timeoutIntervalForRequest = timeout
                configuration.timeoutIntervalForResource = timeout + 2.0
            }
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            let getDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
                print("response -> \(response?.description ?? "")")
                DispatchQueue.main.async {
                    completion(data, response, error)
                }
            })
            getDataTask.resume()
        }
    }
    
    func postMultipart(host: String, path: String = "", header: [String: String]? = nil, query: String = "", fileName: String = "imageFile.png", body: Data? = nil, cachePolicy: NSURLRequest.CachePolicy? = nil, timeout: TimeInterval = 30.0,  completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var urlStr = "\(host)\(path)".removeSpace()
        if !query.isEmpty {
            urlStr = "\(urlStr)?\(query)"
        }
        var request: URLRequest? = nil
        if let url = URL(string: urlStr) {
            request = URLRequest(url: url)
        }
        
        if var request = request {
            request.allHTTPHeaderFields = header
            // generate boundary string using a unique per-app string
            let boundary = UUID().uuidString
            request.httpMethod = "POST"
            // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
            // And the boundary is also set here
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var bodyData = Data()
            // Add the image data to the raw http request data
            bodyData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"imageFile\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            if let body = body {
                bodyData.append(body)
            }
            bodyData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            let configuration = URLSessionConfiguration.default
            if let cachePolicy = cachePolicy {
                configuration.requestCachePolicy = cachePolicy
                let urlCache = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "myCacheDirectory")
                URLCache.shared = urlCache
            }
            if(timeout > 0.0) {
                configuration.timeoutIntervalForRequest = timeout
                configuration.timeoutIntervalForResource = timeout + 2.0
            }
            request.httpBody = bodyData
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            // Send a POST request to the URL, with the data we created earlier
            let postDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
                print(request)
                DispatchQueue.main.async {
                    completion(data, response, error)
                }
            })
            postDataTask.resume()
        }
    }
    
}

extension APIRequestManager: URLSessionDelegate {
    
    public func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print("Connection failed: \(error)")
        completion?(nil, nil, error)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            //if challenge.protectionSpace.host == "mydomain.com" {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
            //}
        }
    }
    
}

import UIKit
extension APIRequestManager {
    
    public static func getRequestHeader() -> [String: String] {
        var header = [String: String]()
        header["Cache-Control"] = "no-cache"
        header["Content-Type"] = "application/json"
        return header
    }
    
}

import Network

enum DoHConfigurarion: Hashable {
    case cloudflare
    case google
    
    var httpsURL: URL {
        switch self {
        case .cloudflare:
            return URL(string: "https://cloudflare-dns.com/dns-query")!
        case .google:
            return URL(string: "https://dns.google/dns-query")!
        }
    }
    
    var serverAddresses: [NWEndpoint] {
        switch self {
        case .cloudflare:
            return [
                NWEndpoint.hostPort(host: "1.1.1.1", port: 443),
                NWEndpoint.hostPort(host: "1.0.0.1", port: 443),
                NWEndpoint.hostPort(host: "2606:4700:4700::1111", port: 443),
                NWEndpoint.hostPort(host: "2606:4700:4700::1001", port: 443)
            ]
        case .google:
            return [
                NWEndpoint.hostPort(host: "8.8.8.8", port: 443),
                NWEndpoint.hostPort(host: "8.8.4.4", port: 443),
                NWEndpoint.hostPort(host: "2001:4860:4860::8888", port: 443),
                NWEndpoint.hostPort(host: "2001:4860:4860::8844", port: 443)
            ]
        }
    }
}

class DOHURLProtocol: URLProtocol {
    
    var delegate: URLSessionDelegate?
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url, url.scheme == "http" || url.scheme == "https" else { return false }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let dohURL =  dohURLs.randomElement()?.httpsURL else { return }
        guard let originalRequest = self.request as? NSMutableURLRequest else { return }
        
        let name = originalRequest.url?.host ?? ""
        let queryItems = [URLQueryItem(name: "name", value: name), URLQueryItem(name: "type", value: "A")]
        var urlComponents = URLComponents(url: dohURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let dohRequestURL = urlComponents?.url else { return }
        var dohRequest = URLRequest(url: dohRequestURL)
        dohRequest.setValue("application/dns-json", forHTTPHeaderField: "Accept")
        let dohSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        let dohTask = dohSession.dataTask(with: dohRequest) { (data, response, error) in
            guard let responseData = data else {
                self.client?.urlProtocol(self, didFailWithError: error ?? NSError(domain: "DOHURLProtocol", code: 1, userInfo: nil))
                return
            }
            
            guard let dohResponse = try? JSONDecoder().decode(DOHResponse.self, from: responseData) else {
                self.client?.urlProtocol(self, didFailWithError: NSError(domain: "DOHURLProtocol", code: 2, userInfo: nil))
                return
            }
            
            let ip = dohResponse.answer?.first?.data ?? ""
            guard let newURL = originalRequest.url?.absoluteString.replacingOccurrences(of: name, with: ip), let resolvedURL = URL(string: newURL) else {
                self.client?.urlProtocol(self, didFailWithError: NSError(domain: "DOHURLProtocol", code: 3, userInfo: nil))
                return
            }
            
            var newRequest = URLRequest(url: resolvedURL)
            newRequest.httpMethod = originalRequest.httpMethod
            newRequest.httpBody = originalRequest.httpBody
            newRequest.allHTTPHeaderFields = originalRequest.allHTTPHeaderFields
            newRequest.setValue(ip, forHTTPHeaderField: "Host")
            let newSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            let newTask = newSession.dataTask(with: newRequest) { (data, response, error) in
                self.client?.urlProtocol(self, didLoad: data ?? Data())
                self.client?.urlProtocol(self, didReceive: response ?? URLResponse(), cacheStoragePolicy: .allowed)
                self.client?.urlProtocolDidFinishLoading(self)
            }
            newTask.resume()
        }
        dohTask.resume()
    }
    
    override func stopLoading() {}
    
}

extension DOHURLProtocol: URLSessionDelegate {
    
    public func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print("Connection failed: \(error)")
        self.client?.urlProtocol(self, didFailWithError: error)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            //if challenge.protectionSpace.host == "mydomain.com" {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
            //}
        }
    }
    
}

import Foundation

// MARK: - DOHResponse
struct DOHResponse: Codable {
    var status: Int?
    var tc, rd, ra, ad: Bool?
    var cd: Bool?
    var question: [Question]?
    var answer: [Answer]?
    var comment: String?
    
    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case tc = "TC"
        case rd = "RD"
        case ra = "RA"
        case ad = "AD"
        case cd = "CD"
        case question = "Question"
        case answer = "Answer"
        case comment = "Comment"
    }
}

// MARK: - Answer
struct Answer: Codable {
    var name: String?
    var type, ttl: Int?
    var data: String?
    
    enum CodingKeys: String, CodingKey {
        case name, type
        case ttl = "TTL"
        case data
    }
}

// MARK: - Question
struct Question: Codable {
    var name: String?
    var type: Int?
}

extension String {
    
    func removeSpace() -> String {
        let resultString = components(separatedBy: " ").joined(separator: "")
        return resultString
    }
    
}
