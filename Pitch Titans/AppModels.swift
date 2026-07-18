import UIKit

enum LaunchRoute {
    case game
    case external(address: String, shouldAskForRating: Bool)
}

struct GameLevel: Codable, Equatable {
    let id: Int
    let title: String
    let themeName: String
    let backgroundTop: RGBColor
    let backgroundBottom: RGBColor
    let defenders: Int
    let parShots: Int
    let obstacleSpeed: CGFloat
    let description: String
}

struct RGBColor: Codable, Equatable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat

    var color: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}

struct LevelStatistics: Codable, Equatable {
    let levelID: Int
    var attempts: Int
    var wins: Int
    var bestShots: Int
    var bestTime: TimeInterval
    var defendersKnocked: Int
    var lastScore: Int

    var completionRate: Double {
        guard attempts > 0 else { return 0 }
        return Double(wins) / Double(attempts)
    }
}

struct Achievement: Equatable {
    let title: String
    let description: String
    let isUnlocked: Bool
}

struct ShopItem: Equatable {
    let id: String
    let title: String
    let detail: String
    let price: Int
    let category: String
    let accent: RGBColor
}

enum ShopCatalog {
    static let items: [ShopItem] = [
        ShopItem(id: "ball_classic", title: "Classic Ball", detail: "The standard match ball.", price: 0, category: "Ball Skin", accent: RGBColor(red: 0.9, green: 0.9, blue: 0.92)),
        ShopItem(id: "ball_inferno", title: "Inferno Ball", detail: "A blazing orange match ball.", price: 250, category: "Ball Skin", accent: RGBColor(red: 0.95, green: 0.41, blue: 0.12)),
        ShopItem(id: "ball_frost", title: "Frost Ball", detail: "An icy blue match ball.", price: 250, category: "Ball Skin", accent: RGBColor(red: 0.32, green: 0.71, blue: 0.95)),
        ShopItem(id: "trail_comet", title: "Comet Trail", detail: "A glowing tail behind every shot.", price: 400, category: "Trail Effect", accent: RGBColor(red: 0.55, green: 0.85, blue: 1.0)),
        ShopItem(id: "trail_neon", title: "Neon Trail", detail: "A vivid magenta strike trail.", price: 450, category: "Trail Effect", accent: RGBColor(red: 0.82, green: 0.2, blue: 0.7)),
        ShopItem(id: "celebration_fireworks", title: "Fireworks", detail: "A burst of color on every goal.", price: 600, category: "Celebration", accent: RGBColor(red: 0.98, green: 0.78, blue: 0.2)),
        ShopItem(id: "pins_royal", title: "Royal Pins", detail: "Golden defender pins.", price: 350, category: "Defender Pins", accent: RGBColor(red: 0.86, green: 0.68, blue: 0.16)),
        ShopItem(id: "pins_carbon", title: "Carbon Pins", detail: "Sleek dark defender pins.", price: 350, category: "Defender Pins", accent: RGBColor(red: 0.35, green: 0.37, blue: 0.42))
    ]
}

enum DemoLevels {
    static let all: [GameLevel] = [
        GameLevel(
            id: 1,
            title: "Training Alley",
            themeName: "Emerald Pitch",
            backgroundTop: RGBColor(red: 0.07, green: 0.35, blue: 0.24),
            backgroundBottom: RGBColor(red: 0.02, green: 0.12, blue: 0.08),
            defenders: 5,
            parShots: 3,
            obstacleSpeed: 0,
            description: "A clean opening puzzle with a compact defender wall."
        ),
        GameLevel(
            id: 2,
            title: "Sunset Curve",
            themeName: "Orange Arena",
            backgroundTop: RGBColor(red: 0.79, green: 0.32, blue: 0.12),
            backgroundBottom: RGBColor(red: 0.27, green: 0.08, blue: 0.2),
            defenders: 7,
            parShots: 4,
            obstacleSpeed: 0.6,
            description: "Use a wider arc to clear side blockers and roll into the goal."
        ),
        GameLevel(
            id: 3,
            title: "Neon Split",
            themeName: "Violet Night",
            backgroundTop: RGBColor(red: 0.19, green: 0.08, blue: 0.44),
            backgroundBottom: RGBColor(red: 0.02, green: 0.01, blue: 0.14),
            defenders: 9,
            parShots: 5,
            obstacleSpeed: 1.0,
            description: "Defenders leave a thin lane that rewards a precise curved shot."
        ),
        GameLevel(
            id: 4,
            title: "Ice Box",
            themeName: "Frozen Blue",
            backgroundTop: RGBColor(red: 0.08, green: 0.45, blue: 0.72),
            backgroundBottom: RGBColor(red: 0.01, green: 0.09, blue: 0.2),
            defenders: 10,
            parShots: 5,
            obstacleSpeed: 1.3,
            description: "A fast final setup with staggered defenders and a narrow finish."
        ),
        GameLevel(
            id: 5,
            title: "Royal Lane",
            themeName: "Golden Stadium",
            backgroundTop: RGBColor(red: 0.72, green: 0.52, blue: 0.12),
            backgroundBottom: RGBColor(red: 0.13, green: 0.08, blue: 0.02),
            defenders: 11,
            parShots: 5,
            obstacleSpeed: 1.4,
            description: "A golden arena with a dense middle wall and a tempting side route."
        ),
        GameLevel(
            id: 6,
            title: "Crimson Wall",
            themeName: "Red Derby",
            backgroundTop: RGBColor(red: 0.62, green: 0.06, blue: 0.1),
            backgroundBottom: RGBColor(red: 0.12, green: 0.01, blue: 0.03),
            defenders: 12,
            parShots: 6,
            obstacleSpeed: 1.5,
            description: "A heavy defender block that needs a late bending strike."
        ),
        GameLevel(
            id: 7,
            title: "Lagoon Switch",
            themeName: "Aqua Dome",
            backgroundTop: RGBColor(red: 0.02, green: 0.58, blue: 0.63),
            backgroundBottom: RGBColor(red: 0.0, green: 0.11, blue: 0.16),
            defenders: 13,
            parShots: 6,
            obstacleSpeed: 1.7,
            description: "Wide spacing invites a smooth S-curve through the defender lanes."
        ),
        GameLevel(
            id: 8,
            title: "Midnight Press",
            themeName: "Blacklight Pitch",
            backgroundTop: RGBColor(red: 0.08, green: 0.08, blue: 0.18),
            backgroundBottom: RGBColor(red: 0.0, green: 0.0, blue: 0.04),
            defenders: 14,
            parShots: 6,
            obstacleSpeed: 1.9,
            description: "A dark challenge with defenders stacked near the scoring lane."
        ),
        GameLevel(
            id: 9,
            title: "Pink Spiral",
            themeName: "Magenta Club",
            backgroundTop: RGBColor(red: 0.72, green: 0.12, blue: 0.54),
            backgroundBottom: RGBColor(red: 0.12, green: 0.01, blue: 0.14),
            defenders: 15,
            parShots: 7,
            obstacleSpeed: 2.0,
            description: "The clean route begins wide, then curls sharply into the goal."
        ),
        GameLevel(
            id: 10,
            title: "Final Whistle",
            themeName: "Champion Green",
            backgroundTop: RGBColor(red: 0.0, green: 0.5, blue: 0.18),
            backgroundBottom: RGBColor(red: 0.01, green: 0.06, blue: 0.02),
            defenders: 16,
            parShots: 7,
            obstacleSpeed: 2.2,
            description: "The championship puzzle with the tallest wall and smallest margin."
        )
    ]
}
