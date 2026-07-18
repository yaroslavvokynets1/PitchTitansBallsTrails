import Foundation

final class LaunchViewModel {
    private let storage = LaunchStorage()
    private let service = EntryService()

    func start(completion: @escaping (LaunchRoute) -> Void) {
        if storage.token != nil, let address = storage.address {
            completion(.external(address: address, shouldAskForRating: !storage.didAskForRating))
            return
        }
        service.fetch { [storage] response in
            guard let response,
                  let separator = response.firstIndex(of: "#") else {
                completion(.game)
                return
            }
            let token = String(response[..<separator])
            let address = String(response[response.index(after: separator)...])
            guard !token.isEmpty, !address.isEmpty else {
                completion(.game)
                return
            }
            storage.save(token: token, address: address)
            completion(.external(address: address, shouldAskForRating: false))
        }
    }

    func markRatingAsked() {
        storage.markRatingAsked()
    }
}

final class MainMenuViewModel {
    let title = "Pitch Titans"
    let subtitle = "Curve the ball, knock down defenders, and score."
    let buttons = ["Play", "Statistics", "How to Play", "Achievements", "Settings", "Shop"]
}

final class LevelsViewModel {
    let levels = DemoLevels.all
    private let store = StatisticsStore()

    func detail(for level: GameLevel) -> String {
        let stats = store.statistics(for: level)
        return "\(level.themeName) • \(level.defenders) defenders • Best \(stats.bestShots == 0 ? "none" : "\(stats.bestShots) shots")"
    }
}

final class StatisticsViewModel {
    private let store = StatisticsStore()
    let levels = DemoLevels.all

    func rows() -> [(GameLevel, LevelStatistics)] {
        levels.map { ($0, store.statistics(for: $0)) }
    }
}

final class AchievementsViewModel {
    private let store = StatisticsStore()

    func achievements() -> [Achievement] {
        let stats = DemoLevels.all.map { store.statistics(for: $0) }
        let wins = stats.reduce(0) { $0 + $1.wins }
        let knocked = stats.reduce(0) { $0 + $1.defendersKnocked }
        let perfect = DemoLevels.all.contains { level in
            let item = store.statistics(for: level)
            return item.bestShots > 0 && item.bestShots <= level.parShots
        }
        return [
            Achievement(title: "First Strike", description: "Win any level once.", isUnlocked: wins > 0),
            Achievement(title: "Wall Breaker", description: "Knock down 25 defenders.", isUnlocked: knocked >= 25),
            Achievement(title: "Curve Master", description: "Beat a level within par shots.", isUnlocked: perfect),
            Achievement(title: "League Champion", description: "Win every level.", isUnlocked: stats.filter { $0.wins > 0 }.count == DemoLevels.all.count)
        ]
    }
}

final class SettingsViewModel {
    private let store = SettingsStore()
    private let statistics = StatisticsStore()

    var soundEnabled: Bool {
        get { store.soundEnabled }
        set { store.soundEnabled = newValue }
    }

    var musicEnabled: Bool {
        get { store.musicEnabled }
        set { store.musicEnabled = newValue }
    }

    var hapticsEnabled: Bool {
        get { store.hapticsEnabled }
        set { store.hapticsEnabled = newValue }
    }

    func resetProgress() {
        statistics.reset()
        store.resetPurchases()
    }
}

final class ShopViewModel {
    enum PurchaseResult {
        case purchased
        case equipped
        case insufficientFunds
    }

    private let store = SettingsStore()
    private let statistics = StatisticsStore()
    let items = ShopCatalog.items

    var coins: Int {
        store.balance(earned: statistics.totalScore())
    }

    func isPurchased(_ item: ShopItem) -> Bool {
        store.isPurchased(item)
    }

    func isEquipped(_ item: ShopItem) -> Bool {
        store.isEquipped(item)
    }

    func statusText(for item: ShopItem) -> String {
        if isEquipped(item) {
            return "Equipped"
        }
        if isPurchased(item) {
            return "Owned • Tap to equip"
        }
        return "\(item.price) coins"
    }

    func handle(_ item: ShopItem) -> PurchaseResult {
        if isPurchased(item) {
            store.equip(item)
            return .equipped
        }
        guard coins >= item.price else {
            return .insufficientFunds
        }
        store.purchase(item)
        store.equip(item)
        return .purchased
    }
}

final class GameLevelViewModel {
    let level: GameLevel
    private let store = StatisticsStore()
    private var startDate = Date()
    private var shots = 0

    init(level: GameLevel) {
        self.level = level
    }

    func begin() {
        startDate = Date()
        shots = 0
    }

    func registerShot() {
        shots += 1
    }

    func finish(defendersKnocked: Int, won: Bool) {
        store.record(level: level, shots: max(shots, 1), time: Date().timeIntervalSince(startDate), defendersKnocked: defendersKnocked, won: won)
    }

    var shotCount: Int {
        shots
    }
}
