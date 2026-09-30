import Foundation
import Postbox

public final class ChekushkagramGhostState {
    public static let shared = ChekushkagramGhostState()
    
    private let lock = NSLock()
    private var _anonymousStories: Bool = true
    private var _fakeOffline: Bool = true
    private var _hideTyping: Bool = true
    private var _ghostRead: Bool = true
    private var _unlimitedViewOnce: Bool = true
    
    public var anonymousStories: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _anonymousStories }
        set { lock.lock(); defer { lock.unlock() }; _anonymousStories = newValue }
    }
    
    public var fakeOffline: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _fakeOffline }
        set { lock.lock(); defer { lock.unlock() }; _fakeOffline = newValue }
    }
    
    public var hideTyping: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _hideTyping }
        set { lock.lock(); defer { lock.unlock() }; _hideTyping = newValue }
    }
    
    public var ghostRead: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _ghostRead }
        set { lock.lock(); defer { lock.unlock() }; _ghostRead = newValue }
    }
    
    public var unlimitedViewOnce: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _unlimitedViewOnce }
        set { lock.lock(); defer { lock.unlock() }; _unlimitedViewOnce = newValue }
    }
}

public class ChekushkagramDeletedMessageAttribute: MessageAttribute {
    public let deletedAt: Int32
    
    public init(deletedAt: Int32) {
        self.deletedAt = deletedAt
    }
    
    required public init(decoder: PostboxDecoder) {
        self.deletedAt = decoder.decodeInt32ForKey("d", orElse: 0)
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.deletedAt, forKey: "d")
    }
}

public struct ChekushkagramEditHistoryEntry: PostboxCoding, Equatable {
    public let date: Int32
    public let text: String
    
    public init(date: Int32, text: String) {
        self.date = date
        self.text = text
    }
    
    public init(decoder: PostboxDecoder) {
        self.date = decoder.decodeInt32ForKey("d", orElse: 0)
        self.text = decoder.decodeStringForKey("t", orElse: "")
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.date, forKey: "d")
        encoder.encodeString(self.text, forKey: "t")
    }
}

public class ChekushkagramEditHistoryAttribute: MessageAttribute {
    public let entries: [ChekushkagramEditHistoryEntry]
    
    public init(entries: [ChekushkagramEditHistoryEntry]) {
        self.entries = entries
    }
    
    required public init(decoder: PostboxDecoder) {
        self.entries = decoder.decodeObjectArrayWithDecoderForKey("e")
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeObjectArray(self.entries, forKey: "e")
    }
}

public extension Message {
    var isChekushkagramDeleted: Bool {
        for attribute in self.attributes {
            if attribute is ChekushkagramDeletedMessageAttribute {
                return true
            }
        }
        return false
    }
    
    var chekushkagramDeletedTime: Int32? {
        for attribute in self.attributes {
            if let attribute = attribute as? ChekushkagramDeletedMessageAttribute {
                return attribute.deletedAt
            }
        }
        return nil
    }
    
    var chekushkagramEditHistory: [ChekushkagramEditHistoryEntry] {
        for attribute in self.attributes {
            if let attribute = attribute as? ChekushkagramEditHistoryAttribute {
                return attribute.entries
            }
        }
        return []
    }
    
    func toStoreMessage() -> StoreMessage {
        var storeFlags: StoreMessageFlags = []
        if self.flags.contains(.Incoming) {
            storeFlags.insert(.Incoming)
        }
        return StoreMessage(
            id: self.id,
            customStableId: nil,
            globallyUniqueId: self.globallyUniqueId,
            groupingKey: self.groupingKey,
            threadId: self.threadId,
            timestamp: self.timestamp,
            flags: storeFlags,
            tags: self.tags,
            globalTags: self.globalTags,
            localTags: self.localTags,
            forwardInfo: self.forwardInfo.flatMap { StoreMessageForwardInfo(authorId: $0.author?.id, sourceId: $0.source?.id, sourceMessageId: $0.sourceMessageId, date: $0.date, authorSignature: $0.authorSignature, psaType: $0.psaType, flags: $0.flags) },
            authorId: self.author?.id,
            text: self.text,
            attributes: self.attributes,
            media: self.media
        )
    }
}
