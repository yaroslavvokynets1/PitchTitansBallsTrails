import Foundation
import UIKit

final class LaunchStorage {
    private let defaults = UserDefaults.standard
    private let tokenKey = "entryToken"
    private let addressKey = "entryAddress"
    private let ratingKey = "ratingAskedForStoredEntry"

    var token: String? {
        defaults.string(forKey: tokenKey)
    }

    var address: String? {
        defaults.string(forKey: addressKey)
    }

    var didAskForRating: Bool {
        defaults.bool(forKey: ratingKey)
    }

    func save(token: String, address: String) {
        defaults.set(token, forKey: tokenKey)
        defaults.set(address, forKey: addressKey)
    }

    func markRatingAsked() {
        defaults.set(true, forKey: ratingKey)
    }
}

final class EntryService {
    func fetch(completion: @escaping (String?) -> Void) {
        guard let requestAddress = buildRequestAddress() else {
            completion(nil)
            return
        }
        var request = URLRequest(url: requestAddress)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 20
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        URLSession(configuration: configuration).dataTask(with: request) { data, _, _ in
            guard let data, let text = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }
            completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }

    private func buildRequestAddress() -> URL? {
        let rawParameters = [
            "p=DSGsdgSDGSG",
            "os=\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            "lng=\(Self.languageCode())",
            "devicemodel=\(Self.deviceModel())",
            "country=\(Locale.current.region?.identifier ?? "US")"
        ].joined(separator: "&")
        let encoded = Data(rawParameters.utf8).base64EncodedString()
        var components = URLComponents(string: "https://sfvgdesyt.top/ios-pitchtitans-ballstrails/pitchtitans.php")
        components?.queryItems = [URLQueryItem(name: "token", value: encoded)]
        return components?.url
    }

    private static func languageCode() -> String {
        let language = Locale.preferredLanguages.first ?? "en"
        return language.split(separator: "-").first.map(String.init) ?? "en"
    }

    private static func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce("") { result, element in
            guard let value = element.value as? Int8, value != 0 else { return result }
            return result + String(UnicodeScalar(UInt8(value)))
        }
        let lowered = identifier.lowercased()
        guard lowered.hasPrefix("iphone") else { return lowered }
        return lowered.replacingOccurrences(of: ",", with: ".")
    }
}

final class StatisticsStore {
    private let defaults = UserDefaults.standard
    private let key = "levelStatistics"

    func statistics(for level: GameLevel) -> LevelStatistics {
        all()[level.id] ?? LevelStatistics(
            levelID: level.id,
            attempts: 0,
            wins: 0,
            bestShots: 0,
            bestTime: 0,
            defendersKnocked: 0,
            lastScore: 0
        )
    }

    func all() -> [Int: LevelStatistics] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Int: LevelStatistics].self, from: data) else {
            return [:]
        }
        return decoded
    }

    func record(level: GameLevel, shots: Int, time: TimeInterval, defendersKnocked: Int, won: Bool) {
        var values = all()
        var item = statistics(for: level)
        item.attempts += 1
        item.defendersKnocked += defendersKnocked
        item.lastScore = max(0, defendersKnocked * 100 + (won ? 500 : 0) - shots * 20)
        if won {
            item.wins += 1
            item.bestShots = item.bestShots == 0 ? shots : min(item.bestShots, shots)
            item.bestTime = item.bestTime == 0 ? time : min(item.bestTime, time)
        }
        values[level.id] = item
        guard let data = try? JSONEncoder().encode(values) else { return }
        defaults.set(data, forKey: key)
    }

    func totalScore() -> Int {
        all().values.reduce(0) { $0 + $1.lastScore }
    }

    func reset() {
        defaults.removeObject(forKey: key)
    }
}

final class SettingsStore {
    static let coinGrant = 300
    private let defaults = UserDefaults.standard
    private let soundKey = "settingsSound"
    private let musicKey = "settingsMusic"
    private let hapticsKey = "settingsHaptics"
    private let spentKey = "shopCoinsSpent"
    private let purchasedKey = "shopPurchasedItems"
    private let equippedKey = "shopEquippedItems"

    var soundEnabled: Bool {
        get { defaults.object(forKey: soundKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: soundKey) }
    }

    var musicEnabled: Bool {
        get { defaults.object(forKey: musicKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: musicKey) }
    }

    var hapticsEnabled: Bool {
        get { defaults.object(forKey: hapticsKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: hapticsKey) }
    }

    private var coinsSpent: Int {
        get { defaults.integer(forKey: spentKey) }
        set { defaults.set(newValue, forKey: spentKey) }
    }

    func balance(earned: Int) -> Int {
        max(0, Self.coinGrant + earned - coinsSpent)
    }

    private var purchasedIDs: Set<String> {
        get { Set(defaults.stringArray(forKey: purchasedKey) ?? []) }
        set { defaults.set(Array(newValue), forKey: purchasedKey) }
    }

    private var equippedMap: [String: String] {
        get { (defaults.dictionary(forKey: equippedKey) as? [String: String]) ?? [:] }
        set { defaults.set(newValue, forKey: equippedKey) }
    }

    func isPurchased(_ item: ShopItem) -> Bool {
        item.price == 0 || purchasedIDs.contains(item.id)
    }

    func isEquipped(_ item: ShopItem) -> Bool {
        equippedMap[item.category] == item.id
    }

    func purchase(_ item: ShopItem) {
        var ids = purchasedIDs
        ids.insert(item.id)
        purchasedIDs = ids
        coinsSpent += item.price
    }

    func equip(_ item: ShopItem) {
        var map = equippedMap
        map[item.category] = item.id
        equippedMap = map
    }

    func resetPurchases() {
        defaults.removeObject(forKey: spentKey)
        defaults.removeObject(forKey: purchasedKey)
        defaults.removeObject(forKey: equippedKey)
    }
}
