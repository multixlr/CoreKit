import Foundation

public protocol Router: AnyObject {
    func process(route: Route)
}
public protocol Reachable {
    var destination: Route.Destination { get }
    var origin: String? { get }
}
extension Route.Destination: Reachable {
    public var destination: Route.Destination { return self }
    public var origin: String? { return nil }
}
extension URL: Reachable {
    public var destination: Route.Destination { return Route.Destination(from: string) }
    public var origin: String? { return string }
}
extension String: Reachable {
    public var destination: Route.Destination { return Route.Destination(from: self) }
    public var origin: String? { return self }
}
extension Optional: Reachable where Wrapped == String {
    public var destination: Route.Destination { return Route.Destination(from: self) }
    public var origin: String? { return self }
}
extension Router {
    public func route(to destination: Route.Destination) {
        process(route: Route(to: destination))
    }
}

public struct Route: Codable, Reachable {
    public let destination: Destination
    public let origin: String?
    
    public init(with reachable: Reachable) {
        self.destination = reachable.destination
        self.origin = reachable.origin
    }
    public init(to destination: Destination) {
        self.init(with: destination)
    }
}
extension Route: Hashable, Equatable {
    public static func == (lhs: Route, rhs: Route) -> Bool {
        return lhs.destination == rhs.destination
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(destination)
    }
}
extension Route {
    public enum Destination: Codable, Hashable, Equatable {
        case unknown(Unknown)
    }
}
extension Route.Destination {
    public init(from source: String? = nil) {
        guard let source = source?.lowercased(), let host = Core.shared.network?.host else {
            self = .unknown(.internal())
            return
        }
        guard source.contains(host) else {
            self = .unknown(.external(url: source.url))
            return
        }
        guard let path = source.components(separatedBy: host).last?.components(separatedBy: "?").first else {
            self = .unknown(.internal(url: source.url))
            return
        }
        var components = path.components(separatedBy: "/")
        components.removeAll(where: {$0.empty})
        guard let route = components.first else {
            self = .unknown(.internal(url: source.url))
            return
        }
        switch route {
        default:
            self = .unknown(.internal(url: source.url))
        }
    }
}

extension Route {
    public enum Unknown: Codable, Hashable {
        case external(url: URL? = nil)
        case `internal`(url: URL? = nil)
        public var url: URL? {
            switch self {
            case .external(let url), .internal(let url):
                return url
            }
        }
    }
}
extension Route {
    public static var none: Route {
        return Route(to: .unknown(.internal()))
    }
}
