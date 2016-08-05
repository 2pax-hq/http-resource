import Foundation
import Result

public typealias JSONDictionary = AnyObject

public enum ParseError: ErrorType {
    case InvalidJSON
    case Custom(ErrorType?)
}

public struct HTTPResource<T> {
    public let URL: NSURL
    public let method: HTTPMethod<NSData>
    public let parse: (NSData) -> Result<T,ParseError>
    public let headers: [(String,String)]
}

public extension HTTPResource {
    public init(URL: NSURL,
         method: HTTPMethod<JSONDictionary> = .GET,
         parseJSON: (JSONDictionary) -> Result<T,ParseError>,
         headers: [(String,String)] = [])
    {
        self.URL = URL
        self.headers = headers
        self.method = method.map { json in
            try! NSJSONSerialization.dataWithJSONObject(json, options: [])
        }
        self.parse = { data in
            guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) else {
                return .Failure(.InvalidJSON)
            }
            return parseJSON(json)
        }
    }

    public func request() -> NSURLRequest {
        return requestFromResource(self)
    }

}

func requestFromResource<T>(resource: HTTPResource<T>) -> NSURLRequest {
    let request = NSMutableURLRequest(URL: resource.URL)
    request.HTTPMethod = resource.method.name
    if case let .POST(data) = resource.method {
        request.HTTPBody = data
    }
    return request
}
