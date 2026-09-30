import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import TelegramUIPreferences
import ItemListUI
import PresentationDataUtils
import AccountContext
import UndoUI

private final class ChekushkagramSettingsArguments {
    let updateAntiDelete: (Bool) -> Void
    let updateShowDeletedBadge: (Bool) -> Void
    let updateEditHistory: (Bool) -> Void
    let updateViewOnceBypass: (Bool) -> Void
    let updateAllowScreenshots: (Bool) -> Void
    let updateGhostMode: (Bool) -> Void
    let updateAnonymousStories: (Bool) -> Void
    let updateFakeOffline: (Bool) -> Void
    let updateHideTyping: (Bool) -> Void
    let updateGhostRead: (Bool) -> Void
    let updateChatTrollPanel: (Bool) -> Void
    let updateCustomVodkaTheme: (Bool) -> Void
    let openThemeSettings: () -> Void
    let openAppIconSettings: () -> Void
    let resetTrollTemplates: () -> Void
    
    init(
        updateAntiDelete: @escaping (Bool) -> Void,
        updateShowDeletedBadge: @escaping (Bool) -> Void,
        updateEditHistory: @escaping (Bool) -> Void,
        updateViewOnceBypass: @escaping (Bool) -> Void,
        updateAllowScreenshots: @escaping (Bool) -> Void,
        updateGhostMode: @escaping (Bool) -> Void,
        updateAnonymousStories: @escaping (Bool) -> Void,
        updateFakeOffline: @escaping (Bool) -> Void,
        updateHideTyping: @escaping (Bool) -> Void,
        updateGhostRead: @escaping (Bool) -> Void,
        updateChatTrollPanel: @escaping (Bool) -> Void,
        updateCustomVodkaTheme: @escaping (Bool) -> Void,
        openThemeSettings: @escaping () -> Void,
        openAppIconSettings: @escaping () -> Void,
        resetTrollTemplates: @escaping () -> Void
    ) {
        self.updateAntiDelete = updateAntiDelete
        self.updateShowDeletedBadge = updateShowDeletedBadge
        self.updateEditHistory = updateEditHistory
        self.updateViewOnceBypass = updateViewOnceBypass
        self.updateAllowScreenshots = updateAllowScreenshots
        self.updateGhostMode = updateGhostMode
        self.updateAnonymousStories = updateAnonymousStories
        self.updateFakeOffline = updateFakeOffline
        self.updateHideTyping = updateHideTyping
        self.updateGhostRead = updateGhostRead
        self.updateChatTrollPanel = updateChatTrollPanel
        self.updateCustomVodkaTheme = updateCustomVodkaTheme
        self.openThemeSettings = openThemeSettings
        self.openAppIconSettings = openAppIconSettings
        self.resetTrollTemplates = resetTrollTemplates
    }
}

private enum ChekushkagramSettingsSection: Int32 {
    case ghost
    case privacy
    case chat
    case appearance
    case about
}

private enum ChekushkagramSettingsEntry: ItemListNodeEntry {
    case ghostHeader
    case ghostMode(Bool)
    case anonymousStories(Bool)
    case fakeOffline(Bool)
    case hideTyping(Bool)
    case ghostRead(Bool)
    case ghostFooter
    
    case privacyHeader
    case antiDelete(Bool)
    case showDeletedBadge(Bool)
    case editHistory(Bool)
    case viewOnceBypass(Bool)
    case allowScreenshots(Bool)
    case privacyFooter
    
    case chatHeader
    case chatTrollPanel(Bool)
    case resetTemplates
    case chatFooter
    
    case appearanceHeader
    case chooseAppIcon
    case customVodkaTheme(Bool)
    case openThemeSettings
    case appearanceFooter
    
    case aboutHeader
    case aboutInfo
    case aboutFooter
    
    var section: ItemListSectionId {
        switch self {
        case .ghostHeader, .ghostMode, .anonymousStories, .fakeOffline, .hideTyping, .ghostRead, .ghostFooter:
            return ChekushkagramSettingsSection.ghost.rawValue
        case .privacyHeader, .antiDelete, .showDeletedBadge, .editHistory, .viewOnceBypass, .allowScreenshots, .privacyFooter:
            return ChekushkagramSettingsSection.privacy.rawValue
        case .chatHeader, .chatTrollPanel, .resetTemplates, .chatFooter:
            return ChekushkagramSettingsSection.chat.rawValue
        case .appearanceHeader, .chooseAppIcon, .customVodkaTheme, .openThemeSettings, .appearanceFooter:
            return ChekushkagramSettingsSection.appearance.rawValue
        case .aboutHeader, .aboutInfo, .aboutFooter:
            return ChekushkagramSettingsSection.about.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        case .ghostHeader: return 0
        case .ghostMode: return 1
        case .anonymousStories: return 2
        case .fakeOffline: return 3
        case .hideTyping: return 4
        case .ghostRead: return 5
        case .ghostFooter: return 6
            
        case .privacyHeader: return 10
        case .antiDelete: return 11
        case .showDeletedBadge: return 12
        case .editHistory: return 13
        case .viewOnceBypass: return 14
        case .allowScreenshots: return 15
        case .privacyFooter: return 16
            
        case .chatHeader: return 20
        case .chatTrollPanel: return 21
        case .resetTemplates: return 22
        case .chatFooter: return 23
            
        case .appearanceHeader: return 30
        case .chooseAppIcon: return 31
        case .customVodkaTheme: return 32
        case .openThemeSettings: return 33
        case .appearanceFooter: return 34
            
        case .aboutHeader: return 40
        case .aboutInfo: return 41
        case .aboutFooter: return 42
        }
    }
    
    static func <(lhs: ChekushkagramSettingsEntry, rhs: ChekushkagramSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! ChekushkagramSettingsArguments
        switch self {
        case .ghostHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "РЕЖИМ ПРИЗРАКА (ФАНТОМ) 👻", sectionId: self.section)
        case let .ghostMode(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Режим призрака (Мастер)", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostMode(value)
            })
        case let .anonymousStories(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Анонимный просмотр историй", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateAnonymousStories(value)
            })
        case let .fakeOffline(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Вечный оффлайн (не в сети)", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateFakeOffline(value)
            })
        case let .hideTyping(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Скрывать «печатает...»", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateHideTyping(value)
            })
        case let .ghostRead(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Скрытное чтение сообщений", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateGhostRead(value)
            })
        case .ghostFooter:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Вы остаётесь полностью скрыты: статус «в сети» не отправляется серверам, просмотр историй не оставляет следа в зрителях, а собеседник не видит факт набора текста и прочтения сообщений."), sectionId: self.section)
            
        case .privacyHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "ПРИВАТНОСТЬ И ПЕРЕХВАТ 🛡️", sectionId: self.section)
        case let .antiDelete(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Анти-удаление сообщений", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateAntiDelete(value)
            })
        case let .showDeletedBadge(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Помечать удалённые бейджем", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateShowDeletedBadge(value)
            })
        case let .editHistory(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Сохранять историю изменений", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateEditHistory(value)
            })
        case let .viewOnceBypass(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Бесконечные 1-view медиа", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateViewOnceBypass(value)
            })
        case let .allowScreenshots(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Разрешить запись и скриншоты", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateAllowScreenshots(value)
            })
        case .privacyFooter:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Удалённые собеседником сообщения остаются в вашей ленте. Отредактированные сообщения хранят полный список прошлых версий."), sectionId: self.section)
            
        case .chatHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "РЕЙД И ТРОЛЛИНГ В ЧАТАХ 💣", sectionId: self.section)
        case let .chatTrollPanel(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Кнопка рейд-панели в чате", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateChatTrollPanel(value)
            })
        case .resetTemplates:
            return ItemListActionItem(presentationData: presentationData, title: "Сбросить шаблоны троллинга", kind: .neutral, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.resetTrollTemplates()
            })
        case .chatFooter:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Возле поля ввода каждого чата находится кнопка 🍺 для мгновенного запуска комбо-рейдов, Zalgo-мутаций текста и водочного спама."), sectionId: self.section)
            
        case .appearanceHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "ОФОРМЛЕНИЕ И ТЕМЫ 🎨", sectionId: self.section)
        case .chooseAppIcon:
            return ItemListActionItem(presentationData: presentationData, title: "Иконка приложения Chekushkagram", kind: .neutral, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.openAppIconSettings()
            })
        case let .customVodkaTheme(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Тема Chekushkagram Vodka Dark", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.updateCustomVodkaTheme(value)
            })
        case .openThemeSettings:
            return ItemListActionItem(presentationData: presentationData, title: "Палитра, обои и цвета сообщений", kind: .neutral, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.openThemeSettings()
            })
        case .appearanceFooter:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Все 12 альтернативных иконок заменены на Chekushkagram (разблокированы бесплатно). Доступна полная кастомизация неоновых палитр."), sectionId: self.section)
            
        case .aboutHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "CHEKUSHKAGRAM 🍾", sectionId: self.section)
        case .aboutInfo:
            return ItemListActionItem(presentationData: presentationData, title: "Версия форка: 1.0.0 (Release Pro)", kind: .neutral, alignment: .natural, sectionId: self.section, style: .blocks, action: {})
        case .aboutFooter:
            return ItemListTextItem(presentationData: presentationData, text: .plain("Собрано эксклюзивно для dj. Все права на чекушку защищены."), sectionId: self.section)
        }
    }
}

private func chekushkagramSettingsEntries(presentationData: PresentationData, settings: ChekushkagramSettings) -> [ChekushkagramSettingsEntry] {
    var entries: [ChekushkagramSettingsEntry] = []
    
    entries.append(.ghostHeader)
    entries.append(.ghostMode(settings.ghostModeEnabled))
    if settings.ghostModeEnabled {
        entries.append(.anonymousStories(settings.anonymousStories))
        entries.append(.fakeOffline(settings.fakeOffline))
        entries.append(.hideTyping(settings.hideTyping))
        entries.append(.ghostRead(settings.ghostRead))
    }
    entries.append(.ghostFooter)
    
    entries.append(.privacyHeader)
    entries.append(.antiDelete(settings.antiDeleteEnabled))
    entries.append(.showDeletedBadge(settings.showDeletedBadge))
    entries.append(.editHistory(settings.editHistoryEnabled))
    entries.append(.viewOnceBypass(settings.viewOnceBypassEnabled))
    entries.append(.allowScreenshots(settings.allowScreenshots))
    entries.append(.privacyFooter)
    
    entries.append(.chatHeader)
    entries.append(.chatTrollPanel(settings.chatTrollPanelEnabled))
    entries.append(.resetTemplates)
    entries.append(.chatFooter)
    
    entries.append(.appearanceHeader)
    entries.append(.chooseAppIcon)
    entries.append(.customVodkaTheme(settings.customVodkaThemeEnabled))
    entries.append(.openThemeSettings)
    entries.append(.appearanceFooter)
    
    entries.append(.aboutHeader)
    entries.append(.aboutInfo)
    entries.append(.aboutFooter)
    
    return entries
}

public func chekushkagramSettingsController(context: AccountContext) -> ViewController {
    let presentationData = context.sharedContext.currentPresentationData.with { $0 }
    
    var pushControllerImpl: ((ViewController) -> Void)?
    
    let arguments = ChekushkagramSettingsArguments(
        updateAntiDelete: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.antiDeleteEnabled = value
                return updated
            }).startStandalone()
        },
        updateShowDeletedBadge: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.showDeletedBadge = value
                return updated
            }).startStandalone()
        },
        updateEditHistory: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.editHistoryEnabled = value
                return updated
            }).startStandalone()
        },
        updateViewOnceBypass: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.viewOnceBypassEnabled = value
                return updated
            }).startStandalone()
        },
        updateAllowScreenshots: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.allowScreenshots = value
                return updated
            }).startStandalone()
        },
        updateGhostMode: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.ghostModeEnabled = value
                return updated
            }).startStandalone()
        },
        updateAnonymousStories: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.anonymousStories = value
                return updated
            }).startStandalone()
        },
        updateFakeOffline: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.fakeOffline = value
                return updated
            }).startStandalone()
        },
        updateHideTyping: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.hideTyping = value
                return updated
            }).startStandalone()
        },
        updateGhostRead: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.ghostRead = value
                return updated
            }).startStandalone()
        },
        updateChatTrollPanel: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.chatTrollPanelEnabled = value
                return updated
            }).startStandalone()
        },
        updateCustomVodkaTheme: { value in
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.customVodkaThemeEnabled = value
                return updated
            }).startStandalone()
            
            let _ = updatePresentationThemeSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                if value {
                    updated.theme = .builtin(.night)
                }
                return updated
            }).startStandalone()
        },
        openThemeSettings: {
            pushControllerImpl?(themeSettingsController(context: context))
        },
        openAppIconSettings: {
            pushControllerImpl?(themeSettingsController(context: context, focusOnItemTag: .appIcon))
        },
        resetTrollTemplates: {
            let _ = updateChekushkagramSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
                var updated = current
                updated.trollTemplates = ChekushkagramSettings.defaultTemplates
                return updated
            }).startStandalone()
        }
    )
    
    let signal = combineLatest(queue: .mainQueue(),
        context.sharedContext.presentationData,
        chekushkagramSettings(accountManager: context.sharedContext.accountManager)
    )
    |> map { presentationData, settings -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Chekushkagram"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: chekushkagramSettingsEntries(presentationData: presentationData, settings: settings), style: .blocks)
        return (controllerState, (listState, arguments))
    }
    
    let controller = ItemListController(context: context, state: signal)
    pushControllerImpl = { [weak controller] c in
        controller?.push(c)
    }
    return controller
}
