import Foundation

public struct Request {
    public typealias Result = Swift.Result<Response, NSError>
    
    enum Method: String {
        case post = "POST"
        case get = "GET"
    }
    
    public struct Response {
        let data: Data?
        var text: String? {
            guard let data = data else { return nil }
            return String(data: data, encoding: .utf8)
        }
        let response: URLResponse?
    }
    
    public static func get(_ urlString: String, headerFields: [String: String] = [:]) -> Result? {
        _request(method: .get, urlString: urlString, headerFields: headerFields)
    }
    
    public static func post(_ urlString: String, headerFields: [String: String] = [:], body: [String: String] = [:]) -> Result? {
        _request(method: .post, urlString: urlString, headerFields: headerFields, body: body)
    }
    
    public static func download() {
        fatalError("TODO：")
    }
    
    static func _request(method: Method = .get, urlString: String,
                         headerFields: [String: String] = [:],
                         body: [String: String]? = nil) -> Result? {
        
        if method == .get && body != nil {
            fatalError("get 请求不支持 body")
        }
        
        if urlString.isEmpty { fatalError("urlString is nil") }
        
        let url: URL?
        if urlString.hasPrefix("/") {
            url = URL(fileURLWithPath: urlString)
        }else {
            url = URL(string: urlString)
        }
        
        guard let aURL = url else { fatalError("url is nil") }
        
        var req = URLRequest(url: aURL)
        req.allHTTPHeaderFields = headerFields
        req.httpMethod = method.rawValue

        if let body = body {
            let data = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            req.httpBody = data
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: Result!
        let task = URLSession.shared.dataTask(with: req) {
            if let error = $2 as NSError? {
                print(error.localizedDescription)
                result = .failure(error)
            }else {
                result = .success(.init(data: $0, response: $1))
            }
            semaphore.signal()
        }
        task.resume()
        
        switch semaphore.wait(timeout: .distantFuture) {
        case .success: break
        case .timedOut: print("timed out")
        }
        
        return result
    }
}



extension String {
    public var urlEncoding: String {
        addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? self
    }
}
