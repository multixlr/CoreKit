import Foundation

extension Core {
    public struct Event {
        public let event: String
        public let source: Source
        public let recorded: Time
        
        public init(event: String, source: Source, date: Foundation.Date = Foundation.Date()) {
            self.event = event
            self.source = source
            self.recorded = Time(with: date)
        }
        
        public enum Source {
            case system
            case user
            case audio
            case images
            case player
            case storage
            case metrics
            case network
            case firebase
            
            public var description: String {
                switch self {
                case .system  : return "System"
                case .user    : return "User"
                case .audio   : return "Audio"
                case .images  : return "Images"
                case .player  : return "Player"
                case .storage : return "Storage"
                case .metrics : return "Metrics"
                case .network : return "Network"
                case .firebase: return "Firebase"
                }
            }
        }
    }
}
