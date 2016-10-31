import Foundation

public enum HTTPMethod<Body> {
    case get
    case post(Body)
    case put(Body)
    case patch(Body)
    case delete

    public var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        }
    }

    public func map<U>(_ f: (Body) -> U) -> HTTPMethod<U> {
        switch self {
        case .post(let body):
            return .post(f(body))
        case .put(let body):
            return .put(f(body))
        case .patch(let body):
            return .patch(f(body))
        case .get:
            return .get
        case .delete:
            return .delete
        }
    }
}
