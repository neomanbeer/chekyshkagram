import Foundation
import UIKit
import AsyncDisplayKit
import Display
import Postbox
import TelegramCore
import TelegramPresentationData
import AccountContext
import SwiftSignalKit

public final class ChekushkagramRaidManager {
    public static let shared = ChekushkagramRaidManager()
    
    private var timer: SwiftSignalKit.Timer?
    private(set) public var isRunning: Bool = false
    private(set) public var currentCount: Int = 0
    private(set) public var totalCount: Int = 0
    private(set) public var currentPhrases: [String] = []
    private(set) public var currentPeerId: EnginePeer.Id?
    
    public var onProgressUpdate: ((Int, Int) -> Void)?
    
    private init() {}
    
    public func startRaid(
        account: Account,
        peerId: EnginePeer.Id,
        phrases: [String],
        count: Int,
        interval: Double,
        onComplete: (() -> Void)? = nil
    ) {
        self.stopRaid()
        guard !phrases.isEmpty else { return }
        
        self.isRunning = true
        self.currentCount = 0
        self.totalCount = count
        self.currentPhrases = phrases
        self.currentPeerId = peerId
        
        let timer = SwiftSignalKit.Timer(timeout: interval, repeat: true, completion: { [weak self] in
            guard let strongSelf = self, strongSelf.isRunning else {
                return
            }
            if strongSelf.currentCount >= strongSelf.totalCount {
                strongSelf.stopRaid()
                onComplete?()
                return
            }
            
            let textToSend = strongSelf.currentPhrases[strongSelf.currentCount % strongSelf.currentPhrases.count]
            strongSelf.currentCount += 1
            strongSelf.onProgressUpdate?(strongSelf.currentCount, strongSelf.totalCount)
            
            let message = EnqueueMessage.message(
                text: textToSend,
                attributes: [],
                inlineStickers: [:],
                mediaReference: nil,
                threadId: nil,
                replyToMessageId: nil,
                replyToStoryId: nil,
                localGroupingKey: nil,
                correlationId: nil,
                bubbleUpEmojiOrStickersets: []
            )
            let _ = enqueueMessages(account: account, peerId: peerId, messages: [message]).startStandalone()
        }, queue: Queue.mainQueue())
        
        self.timer = timer
        timer.start()
    }
    
    public func stopRaid() {
        self.timer?.invalidate()
        self.timer = nil
        self.isRunning = false
        self.currentPeerId = nil
        self.currentPhrases = []
    }
}

public enum ChekushkagramTextMutator {
    public static func apply(text: String, mode: Int) -> String {
        switch mode {
        case 1: // UPPERCASE
            return text.uppercased()
        case 2: // S p a c e d
            return text.map { "\($0)" }.joined(separator: " ")
        case 3: // sPoNgEbOb
            var res = ""
            var upper = false
            for c in text {
                res.append(upper ? c.uppercased() : c.lowercased())
                upper.toggle()
            }
            return res
        case 4: // Glitch / Zalgo
            let zalgoMarks: [Character] = ["\u{0300}", "\u{0301}", "\u{0302}", "\u{0303}", "\u{0304}", "\u{0305}", "\u{0306}", "\u{0307}"]
            var res = ""
            for (idx, c) in text.enumerated() {
                res.append(c)
                res.append(zalgoMarks[idx % zalgoMarks.count])
            }
            return res
        default:
            return text
        }
    }
}

public func openChekushkagramTrollPanel(
    context: AccountContext,
    peerId: EnginePeer.Id,
    theme: PresentationTheme?,
    strings: PresentationStrings?,
    present: @escaping (ViewController) -> Void
) {
    let actionSheetTheme: ActionSheetControllerTheme
    if let theme = theme {
        actionSheetTheme = ActionSheetControllerTheme(presentationTheme: theme, fontSize: .regular)
    } else {
        actionSheetTheme = ActionSheetControllerTheme(presentationData: context.sharedContext.currentPresentationData.with { $0 })
    }
    
    let actionSheet = ActionSheetController(theme: actionSheetTheme)
    
    if ChekushkagramRaidManager.shared.isRunning {
        var items: [ActionSheetItem] = []
        items.append(ActionSheetTextItem(title: "🚨 CHEKUSHKAGRAM — ИДЁТ АКТИВНЫЙ РЕЙД!"))
        items.append(ActionSheetTextItem(title: "Отправлено: \(ChekushkagramRaidManager.shared.currentCount) из \(ChekushkagramRaidManager.shared.totalCount)"))
        items.append(ActionSheetButtonItem(title: "🛑 ОСТАНОВИТЬ РЕЙД (СТОП)", color: .destructive, action: { [weak actionSheet] in
            actionSheet?.dismissAnimated()
            ChekushkagramRaidManager.shared.stopRaid()
        }))
        
        actionSheet.setItemGroups([
            ActionSheetItemGroup(items: items),
            ActionSheetItemGroup(items: [
                ActionSheetButtonItem(title: strings?.Common_Close ?? "Закрыть панель", color: .accent, font: .bold, action: { [weak actionSheet] in
                    actionSheet?.dismissAnimated()
                })
            ])
        ])
        present(actionSheet)
        return
    }
    
    let launchRaidConfiguration: ([String]) -> Void = { targetPhrases in
        let configSheet = ActionSheetController(theme: actionSheetTheme)
        var configItems: [ActionSheetItem] = []
        
        let preview = targetPhrases.first ?? "Спам"
        configItems.append(ActionSheetTextItem(title: "⚙️ ПАРАМЕТРЫ РЕЙДА:\n\"\(preview)\""))
        
        let presets: [(String, Int, Double)] = [
            ("⚡️ 5 сообщений (быстро, 0.25с)", 5, 0.25),
            ("💥 10 сообщений (0.3с)", 10, 0.3),
            ("🌪 25 сообщений (Рейд, 0.35с)", 25, 0.35),
            ("💣 50 сообщений (Ультра, 0.4с)", 50, 0.4),
            ("🚀 100 сообщений (Турбо, 0.5с)", 100, 0.5),
            ("👑 200 сообщений (Тотал, 0.6с)", 200, 0.6)
        ]
        
        for (label, count, interval) in presets {
            configItems.append(ActionSheetButtonItem(title: label, color: .accent, action: { [weak configSheet] in
                configSheet?.dismissAnimated()
                ChekushkagramRaidManager.shared.startRaid(
                    account: context.account,
                    peerId: peerId,
                    phrases: targetPhrases,
                    count: count,
                    interval: interval
                )
            }))
        }
        
        configSheet.setItemGroups([
            ActionSheetItemGroup(items: configItems),
            ActionSheetItemGroup(items: [
                ActionSheetButtonItem(title: strings?.Common_Cancel ?? "Отмена", color: .accent, font: .bold, action: { [weak configSheet] in
                    configSheet?.dismissAnimated()
                })
            ])
        ])
        present(configSheet)
    }
    
    var mainItems: [ActionSheetItem] = []
    mainItems.append(ActionSheetTextItem(title: "🍺 CHEKUSHKAGRAM — РЕЙД & ТРОЛЛИНГ ПАНЕЛЬ"))
    
    // Combo Raids
    mainItems.append(ActionSheetButtonItem(title: "🔥 Комбо: Водочный Разъёб (цикл 4 фраз)", color: .accent, action: { [weak actionSheet] in
        actionSheet?.dismissAnimated()
        launchRaidConfiguration([
            "🍻 ЧЕКУШКА ПОШЛА В ХОД!",
            "🍾 ЗА ЗДОРОВЬЕ ЧЕКУШЕЧНИКОВ!",
            "🥃 НАКАТИМ ЗА СУЕТУ В ЭТОМ ЧАТЕ!",
            "🔥 40 ГРАДУСОВ ЧИСТОЙ ЯРОСТИ!"
        ])
    }))
    
    mainItems.append(ActionSheetButtonItem(title: "🐗 Комбо: Операция «Кабанчик» (рандом бег)", color: .accent, action: { [weak actionSheet] in
        actionSheet?.dismissAnimated()
        launchRaidConfiguration([
            "🏃‍♂️💨 Кабанчик №1 метнулся за чекушкой!",
            "🐗💨 Кабанчик №2 на подхвате!",
            "⚡️💨 Кабанчик №3 пробил оборону чата!",
            "🍾💨 Кабанчики захватили этот тред!"
        ])
    }))
    
    mainItems.append(ActionSheetButtonItem(title: "🚨 Комбо: Облава Чекушки («Менты в чате!»)", color: .accent, action: { [weak actionSheet] in
        actionSheet?.dismissAnimated()
        launchRaidConfiguration([
            "🚨 АЛО МЕНТЫ! ТУТ ЧЕКУШКУ ПЬЮТ БЕЗ НАС!",
            "🚔 ВСЕМ ОСТАВАТЬСЯ НА МЕСТАХ, РАБОТАЕТ ЧЕКУШКАГРАМ!",
            "👮‍♂️ ПАСПОРТА В РУКИ, ЧЕКУШКИ НА СТОЛ!",
            "💥 ПРИСТЕГНУЛИСЬ, ЭТО ОБЛАВА!"
        ])
    }))
    
    mainItems.append(ActionSheetButtonItem(title: "🍺 Эмодзи-флуд: Пиво & Чекушка 🍺🍾", color: .accent, action: { [weak actionSheet] in
        actionSheet?.dismissAnimated()
        launchRaidConfiguration([
            "🍺 🍺 🍺 🍾 🍾 🍾",
            "🍾 🍾 🍾 🍺 🍺 🍺",
            "🍻 🍻 🍻 🥃 🥃 🥃",
            "🍾 🍺 🍾 🍺 🍾 🍺"
        ])
    }))
    
    mainItems.append(ActionSheetButtonItem(title: "💣 Эмодзи-флуд: Бомбы & Пламя 💣💥", color: .accent, action: { [weak actionSheet] in
        actionSheet?.dismissAnimated()
        launchRaidConfiguration([
            "💣 💥 💣 💥 💣 💥",
            "🔥 🚨 🔥 🚨 🔥 🚨",
            "💥 💥 💥 💣 💣 💣"
        ])
    }))
    
    // Single Templates
    let singleTemplates = [
        "🍻 Чекушка за вас, пацаны!",
        "🏃‍♂️💨 Кабанчиком за чекушкой метнулся, быстро!",
        "🍾 Ты чё такой дерзкий? Чекушку выпей и успокойся",
        "💣💥 Рейд Чекушки объявляется открытым!",
        "👑 Чекушкагрэм доминирует этот чат!",
        "🚨 АЛО БРАТВА ТУТ СУЕТА НАВОДИТСЯ",
        "🔥 Кто тронет Чекушку — получит по шапке!"
    ]
    
    for template in singleTemplates {
        mainItems.append(ActionSheetButtonItem(title: template, color: .accent, action: { [weak actionSheet] in
            actionSheet?.dismissAnimated()
            launchRaidConfiguration([template])
        }))
    }
    
    // Custom Text with Mutator selection
    mainItems.append(ActionSheetButtonItem(title: "✍️ [Ввести свой текст + Мутатор...]", color: .accent, font: .bold, action: { [weak actionSheet] in
        actionSheet?.dismissAnimated()
        
        let alert = UIAlertController(title: "🍺 Свой текст для рейда", message: "Введите фразу для спама:", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Например: Всем стоять, работает Чекушка!"
        }
        alert.addAction(UIAlertAction(title: strings?.Common_Cancel ?? "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Обычный текст", style: .default, handler: { [weak alert] _ in
            let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !text.isEmpty {
                launchRaidConfiguration([text])
            }
        }))
        alert.addAction(UIAlertAction(title: "📢 ОРУЩИЙ КАПС", style: .default, handler: { [weak alert] _ in
            let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !text.isEmpty {
                launchRaidConfiguration([ChekushkagramTextMutator.apply(text: text, mode: 1)])
            }
        }))
        alert.addAction(UIAlertAction(title: "🔤 Р а з р я д к а", style: .default, handler: { [weak alert] _ in
            let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !text.isEmpty {
                launchRaidConfiguration([ChekushkagramTextMutator.apply(text: text, mode: 2)])
            }
        }))
        alert.addAction(UIAlertAction(title: "🔀 ПрОвОкАцИя", style: .default, handler: { [weak alert] _ in
            let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !text.isEmpty {
                launchRaidConfiguration([ChekushkagramTextMutator.apply(text: text, mode: 3)])
            }
        }))
        alert.addAction(UIAlertAction(title: "🪓 Glitch / Zalgo", style: .default, handler: { [weak alert] _ in
            let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !text.isEmpty {
                launchRaidConfiguration([ChekushkagramTextMutator.apply(text: text, mode: 4)])
            }
        }))
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            var top = window.rootViewController
            while let presented = top?.presentedViewController {
                top = presented
            }
            top?.present(alert, animated: true)
        }
    }))
    
    actionSheet.setItemGroups([
        ActionSheetItemGroup(items: mainItems),
        ActionSheetItemGroup(items: [
            ActionSheetButtonItem(title: strings?.Common_Cancel ?? "Отмена", color: .accent, font: .bold, action: { [weak actionSheet] in
                actionSheet?.dismissAnimated()
            })
        ])
    ])
    
    present(actionSheet)
}
