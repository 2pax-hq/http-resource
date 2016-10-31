import Foundation

public typealias JSONDictionary = AnyObject

public enum ParseError: Error {
    case invalidJSON
    case custom(Error?)
}

public struct HTTPResource<T> {
    public let URL: Foundation.URL
    public let method: HTTPMethod<Data>
    public let parse: (Data) throws -> T
    public let headers: [String:String]
}

public extension HTTPResource {
    public init(URL: Foundation.URL,
         method: HTTPMethod<JSONDictionary> = .get,
         parseJSON: @escaping (JSONDictionary) throws -> T,
         headers: [String:String] = [:])
    {
        self.URL = URL
        self.headers = headers
        self.method = method.map { json in
            try! JSONSerialization.data(withJSONObject: json, options: [])
        }
        self.parse = { data in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) else {
                throw ParseError.invalidJSON
            }
            return try parseJSON(json as JSONDictionary)
        }
    }

    public init(URL: Foundation.URL,
                method: HTTPMethod<JSONDictionary> = .get,
                parseJSONCollection: @escaping ([JSONDictionary]) throws -> T,
                headers: [String:String] = [:])
    {
        self.URL = URL
        self.headers = headers
        self.method = method.map { json in
            try! JSONSerialization.data(withJSONObject: json, options: [])
        }
        self.parse = { data in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()),
            let jsonColllection = json as? [JSONDictionary] else {
                throw ParseError.invalidJSON
            }

            return try parseJSONCollection(jsonColllection)
        }
    }

    public func request() -> URLRequest {
        return requestFromResource(self)
    }

}

func requestFromResource<T>(_ resource: HTTPResource<T>) -> URLRequest {
    let request = NSMutableURLRequest(url: resource.URL)
    request.httpMethod = resource.method.name
    request.allHTTPHeaderFields = resource.headers
    if case let .post(data) = resource.method {
        request.httpBody = data
    }
    if case let .put(data) = resource.method {
        request.httpBody = data
    }
    if case let .patch(data) = resource.method {
        request.httpBody = data
    }
    return request as URLRequest
}
