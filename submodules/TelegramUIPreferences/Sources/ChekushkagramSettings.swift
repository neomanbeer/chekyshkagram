import Foundation
import TelegramCore
import SwiftSignalKit
import Postbox

public struct ChekushkagramSettings: Codable, Equatable {
    public var antiDeleteEnabled: Bool
    public var showDeletedBadge: Bool
    public var editHistoryEnabled: Bool
    public var viewOnceBypassEnabled: Bool
    public var allowScreenshots: Bool
    public var chatTrollPanelEnabled: Bool
    public var customVodkaThemeEnabled: Bool
    public var ghostModeEnabled: Bool
    public var anonymousStories: Bool
    public var fakeOffline: Bool
    public var hideTyping: Bool
    public var ghostRead: Bool
    public var trollTemplates: [String]
    public var defaultRepeatCount: Int32
    public var repeatDelayMs: Int32
    
    public static var defaultTemplates: [String] {
        return [
            "ЧЕКУШКАГРАМ НА БАЗЕ! 🍺",
            "ВЫ ПРИЗВАНЫ НА ПЕРЕМЫТИЕ КОСТЕЙ 💀",
            "РАЗЪЁБ В ЭФИРЕ, ПРИСТЕГНУЛИСЬ! 🚀",
            "ЧЕКУШКА В РУКЕ — СУДЬБА В КАРМАНЕ 🍾",
            "ПЕНА ДНЕЙ И ВОДКА СТОЛИЧНАЯ 🧊",
            "СПАМ-АТАКА ИМЕНИ ЧЕКУШКИ! ⚡",
            "ЗДЕСЬ БЫЛ ЧЕКУШКАГРАМ 💥",
            "ТИШЕ ЕДЕШЬ — ЧЕКУШКУ ПЬЁШЬ! 🍶",
            "ГДЕ МОЯ ЧЕКУШКА, ЛЕБОВСКИ?! 🕵️‍♂️",
            "ЧЕКУШКА ВХОДИТ В ЧАТ С ДВУХ НОГ 🚪💥"
        ]
    }
    
    public static var defaultSettings: ChekushkagramSettings {
        return ChekushkagramSettings(
            antiDeleteEnabled: true,
            showDeletedBadge: true,
            editHistoryEnabled: true,
            viewOnceBypassEnabled: true,
            allowScreenshots: true,
            chatTrollPanelEnabled: true,
            customVodkaThemeEnabled: true,
            ghostModeEnabled: true,
            anonymousStories: true,
            fakeOffline: true,
            hideTyping: true,
            ghostRead: true,
            trollTemplates: ChekushkagramSettings.defaultTemplates,
            defaultRepeatCount: 5,
            repeatDelayMs: 400
        )
    }
    
    public init(
        antiDeleteEnabled: Bool,
        showDeletedBadge: Bool,
        editHistoryEnabled: Bool,
        viewOnceBypassEnabled: Bool,
        allowScreenshots: Bool,
        chatTrollPanelEnabled: Bool,
        customVodkaThemeEnabled: Bool,
        ghostModeEnabled: Bool,
        anonymousStories: Bool,
        fakeOffline: Bool,
        hideTyping: Bool,
        ghostRead: Bool,
        trollTemplates: [String],
        defaultRepeatCount: Int32,
        repeatDelayMs: Int32
    ) {
        self.antiDeleteEnabled = antiDeleteEnabled
        self.showDeletedBadge = showDeletedBadge
        self.editHistoryEnabled = editHistoryEnabled
        self.viewOnceBypassEnabled = viewOnceBypassEnabled
        self.allowScreenshots = allowScreenshots
        self.chatTrollPanelEnabled = chatTrollPanelEnabled
        self.customVodkaThemeEnabled = customVodkaThemeEnabled
        self.ghostModeEnabled = ghostModeEnabled
        self.anonymousStories = anonymousStories
        self.fakeOffline = fakeOffline
        self.hideTyping = hideTyping
        self.ghostRead = ghostRead
        self.trollTemplates = trollTemplates
        self.defaultRepeatCount = defaultRepeatCount
        self.repeatDelayMs = repeatDelayMs
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)
        self.antiDeleteEnabled = (try? container.decode(Bool.self, forKey: "antiDeleteEnabled")) ?? true
        self.showDeletedBadge = (try? container.decode(Bool.self, forKey: "showDeletedBadge")) ?? true
        self.editHistoryEnabled = (try? container.decode(Bool.self, forKey: "editHistoryEnabled")) ?? true
        self.viewOnceBypassEnabled = (try? container.decode(Bool.self, forKey: "viewOnceBypassEnabled")) ?? true
        self.allowScreenshots = (try? container.decode(Bool.self, forKey: "allowScreenshots")) ?? true
        self.chatTrollPanelEnabled = (try? container.decode(Bool.self, forKey: "chatTrollPanelEnabled")) ?? true
        self.customVodkaThemeEnabled = (try? container.decode(Bool.self, forKey: "customVodkaThemeEnabled")) ?? true
        self.ghostModeEnabled = (try? container.decode(Bool.self, forKey: "ghostModeEnabled")) ?? true
        self.anonymousStories = (try? container.decode(Bool.self, forKey: "anonymousStories")) ?? true
        self.fakeOffline = (try? container.decode(Bool.self, forKey: "fakeOffline")) ?? true
        self.hideTyping = (try? container.decode(Bool.self, forKey: "hideTyping")) ?? true
        self.ghostRead = (try? container.decode(Bool.self, forKey: "ghostRead")) ?? true
        self.trollTemplates = (try? container.decode([String].self, forKey: "trollTemplates")) ?? ChekushkagramSettings.defaultTemplates
        self.defaultRepeatCount = (try? container.decode(Int32.self, forKey: "defaultRepeatCount")) ?? 5
        self.repeatDelayMs = (try? container.decode(Int32.self, forKey: "repeatDelayMs")) ?? 400
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        try container.encode(self.antiDeleteEnabled, forKey: "antiDeleteEnabled")
        try container.encode(self.showDeletedBadge, forKey: "showDeletedBadge")
        try container.encode(self.editHistoryEnabled, forKey: "editHistoryEnabled")
        try container.encode(self.viewOnceBypassEnabled, forKey: "viewOnceBypassEnabled")
        try container.encode(self.allowScreenshots, forKey: "allowScreenshots")
        try container.encode(self.chatTrollPanelEnabled, forKey: "chatTrollPanelEnabled")
        try container.encode(self.customVodkaThemeEnabled, forKey: "customVodkaThemeEnabled")
        try container.encode(self.ghostModeEnabled, forKey: "ghostModeEnabled")
        try container.encode(self.anonymousStories, forKey: "anonymousStories")
        try container.encode(self.fakeOffline, forKey: "fakeOffline")
        try container.encode(self.hideTyping, forKey: "hideTyping")
        try container.encode(self.ghostRead, forKey: "ghostRead")
        try container.encode(self.trollTemplates, forKey: "trollTemplates")
        try container.encode(self.defaultRepeatCount, forKey: "defaultRepeatCount")
        try container.encode(self.repeatDelayMs, forKey: "repeatDelayMs")
    }
}

private let chekushkagramSettingsLock = NSLock()
private var currentChekushkagramSettings: ChekushkagramSettings = .defaultSettings

public extension ChekushkagramSettings {
    static var current: ChekushkagramSettings {
        get {
            chekushkagramSettingsLock.lock()
            defer { chekushkagramSettingsLock.unlock() }
            return currentChekushkagramSettings
        }
        set {
            chekushkagramSettingsLock.lock()
            currentChekushkagramSettings = newValue
            chekushkagramSettingsLock.unlock()
            
            let ghost = ChekushkagramGhostState.shared
            ghost.anonymousStories = newValue.ghostModeEnabled && newValue.anonymousStories
            ghost.fakeOffline = newValue.ghostModeEnabled && newValue.fakeOffline
            ghost.hideTyping = newValue.ghostModeEnabled && newValue.hideTyping
            ghost.ghostRead = newValue.ghostModeEnabled && newValue.ghostRead
            ghost.unlimitedViewOnce = newValue.viewOnceBypassEnabled
        }
    }
}

public func chekushkagramSettings(accountManager: AccountManager<TelegramAccountManagerTypes>) -> Signal<ChekushkagramSettings, NoError> {
    return accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.chekushkagramSettings])
    |> map { sharedData -> ChekushkagramSettings in
        if let entry = sharedData.entries[ApplicationSpecificSharedDataKeys.chekushkagramSettings], let value = entry.get(ChekushkagramSettings.self) {
            ChekushkagramSettings.current = value
            return value
        } else {
            let defaultVal = ChekushkagramSettings.defaultSettings
            ChekushkagramSettings.current = defaultVal
            return defaultVal
        }
    }
}

public func updateChekushkagramSettingsInteractively(accountManager: AccountManager<TelegramAccountManagerTypes>, _ f: @escaping (ChekushkagramSettings) -> ChekushkagramSettings) -> Signal<Void, NoError> {
    return accountManager.transaction { transaction -> Void in
        transaction.updateSharedData(ApplicationSpecificSharedDataKeys.chekushkagramSettings, { entry in
            let current: ChekushkagramSettings
            if let entry = entry, let value = entry.get(ChekushkagramSettings.self) {
                current = value
            } else {
                current = .defaultSettings
            }
            let updated = f(current)
            ChekushkagramSettings.current = updated
            return PreferencesEntry(updated)
        })
    }
}
