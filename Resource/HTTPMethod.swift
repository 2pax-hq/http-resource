import Foundation

public enum HTTPMethod<Body> {
    case GET
    case POST(Body)
    case PUT(Body)
    case PATCH(Body)
    case DELETE

    public var name: String {
        switch self {
        case .GET: return "GET"
        case .POST: return "POST"
        case .PUT: return "PUT"
        case .PATCH: return "PATCH"
        case .DELETE: return "DELETE"
        }
    }

    public func map<U>(f: Body -> U) -> HTTPMethod<U> {
        switch self {
        case .POST(let body):
            return .POST(f(body))
        case .PUT(let body):
            return .PUT(f(body))
        case .PATCH(let body):
            return .PATCH(f(body))
        case .GET:
            return .GET
        case .DELETE:
            return .DELETE
        }
    }
}
