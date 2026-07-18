import UIKit

final class MainMenuViewController: PortraitViewController {
    private let viewModel: MainMenuViewModel

    init(viewModel: MainMenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientBackground(top: UIColor(red: 0.03, green: 0.28, blue: 0.28, alpha: 1), bottom: UIColor(red: 0.0, green: 0.03, blue: 0.08, alpha: 1))
        buildDecorations()
        let panel = GlassPanelView()
        panel.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.text = viewModel.title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 48, weight: .black)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.35
        titleLabel.layer.shadowRadius = 10
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 6)
        let subtitleLabel = UILabel()
        subtitleLabel.text = viewModel.subtitle
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        let badge = SoccerBallBadgeView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        let modeLabel = UILabel()
        modeLabel.text = "PHYSICS PUZZLE"
        modeLabel.textColor = UIColor(red: 0.55, green: 1.0, blue: 0.72, alpha: 1)
        modeLabel.font = .systemFont(ofSize: 13, weight: .black)
        modeLabel.textAlignment = .center
        modeLabel.letterSpacing(text: modeLabel.text ?? "", spacing: 1.6)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 28, left: 22, bottom: 24, right: 22)
        stack.addArrangedSubview(badge)
        stack.setCustomSpacing(18, after: badge)
        stack.addArrangedSubview(modeLabel)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        stack.setCustomSpacing(24, after: subtitleLabel)
        viewModel.buttons.enumerated().forEach { index, title in
            let button = MenuActionButton(title: title.uppercased(), primary: index == 0)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
        panel.addSubview(stack)
        view.addSubview(panel)
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            panel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -22),
            panel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            badge.heightAnchor.constraint(equalToConstant: 86),
            stack.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            stack.topAnchor.constraint(equalTo: panel.topAnchor),
            stack.bottomAnchor.constraint(equalTo: panel.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func buildDecorations() {
        let glow = UIView()
        glow.translatesAutoresizingMaskIntoConstraints = false
        glow.backgroundColor = UIColor(red: 0.12, green: 0.9, blue: 0.56, alpha: 0.22)
        glow.layer.cornerRadius = 120
        glow.layer.shadowColor = UIColor(red: 0.12, green: 0.9, blue: 0.56, alpha: 1).cgColor
        glow.layer.shadowOpacity = 0.6
        glow.layer.shadowRadius = 60
        glow.layer.shadowOffset = .zero
        let stripe = UIView()
        stripe.translatesAutoresizingMaskIntoConstraints = false
        stripe.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        stripe.transform = CGAffineTransform(rotationAngle: -0.22)
        stripe.layer.cornerRadius = 18
        view.addSubview(glow)
        view.addSubview(stripe)
        NSLayoutConstraint.activate([
            glow.widthAnchor.constraint(equalToConstant: 240),
            glow.heightAnchor.constraint(equalToConstant: 240),
            glow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 70),
            glow.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stripe.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.25),
            stripe.heightAnchor.constraint(equalToConstant: 42),
            stripe.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -40),
            stripe.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28)
        ])
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            navigationController?.pushViewController(LevelsViewController(viewModel: LevelsViewModel()), animated: true)
        case 1:
            navigationController?.pushViewController(StatisticsViewController(viewModel: StatisticsViewModel()), animated: true)
        case 2:
            navigationController?.pushViewController(HowToPlayViewController(), animated: true)
        case 3:
            navigationController?.pushViewController(AchievementsViewController(viewModel: AchievementsViewModel()), animated: true)
        case 4:
            navigationController?.pushViewController(SettingsViewController(viewModel: SettingsViewModel()), animated: true)
        default:
            navigationController?.pushViewController(ShopViewController(viewModel: ShopViewModel()), animated: true)
        }
    }
}

final class LevelsViewController: PortraitViewController, UITableViewDataSource, UITableViewDelegate {
    private let viewModel: LevelsViewModel
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(viewModel: LevelsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Play"
        addGradientBackground(top: UIColor(red: 0.04, green: 0.16, blue: 0.2, alpha: 1), bottom: UIColor(red: 0.01, green: 0.02, blue: 0.07, alpha: 1))
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 112
        tableView.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: 22, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.levels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let level = viewModel.levels[indexPath.row]
        cell.textLabel?.text = "  \(level.title)"
        cell.detailTextLabel?.text = "  \(viewModel.detail(for: level))"
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = level.backgroundTop.color.withAlphaComponent(0.38)
        cell.layer.cornerRadius = 22
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.26
        cell.layer.shadowRadius = 14
        cell.layer.shadowOffset = CGSize(width: 0, height: 8)
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 20, weight: .black)
        cell.detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.72)
        cell.detailTextLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let level = viewModel.levels[indexPath.row]
        navigationController?.pushViewController(FootbowlingGameViewController(viewModel: GameLevelViewModel(level: level)), animated: true)
    }
}

final class StatisticsViewController: PortraitViewController {
    private let viewModel: StatisticsViewModel
    private let stack = UIStackView()

    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Statistics"
        addGradientBackground(top: UIColor(red: 0.08, green: 0.14, blue: 0.28, alpha: 1), bottom: UIColor(red: 0.01, green: 0.03, blue: 0.08, alpha: 1))
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
        reload()
    }

    private func reload() {
        viewModel.rows().forEach { level, stats in
            let label = UILabel()
            label.numberOfLines = 0
            label.textColor = .white
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.backgroundColor = UIColor.white.withAlphaComponent(0.12)
            label.layer.cornerRadius = 18
            label.layer.masksToBounds = true
            let rate = Int(stats.completionRate * 100)
            let bestShots = stats.bestShots == 0 ? "Not cleared" : "\(stats.bestShots)"
            let bestTime = stats.bestTime == 0 ? "Not cleared" : String(format: "%.1fs", stats.bestTime)
            label.text = "\n  \(level.title)\n  Theme: \(level.themeName)\n  Attempts: \(stats.attempts) • Wins: \(stats.wins) • Completion: \(rate)%\n  Best shots: \(bestShots) • Best time: \(bestTime)\n  Defenders knocked: \(stats.defendersKnocked) • Last score: \(stats.lastScore)\n"
            stack.addArrangedSubview(label)
        }
    }
}

final class HowToPlayViewController: PortraitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "How to Play"
        addGradientBackground(top: UIColor(red: 0.13, green: 0.33, blue: 0.24, alpha: 1), bottom: UIColor(red: 0.02, green: 0.07, blue: 0.06, alpha: 1))
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = "Drag from the ball to draw a curved strike path.\n\nRelease to shoot. The ball follows your arc, knocks down defender pins, and must finish inside the goal.\n\nTips:\n• Shorter drags are easier to control.\n• Aim around the wall, not straight through it.\n• Each level has a par shot target in its details."
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

final class AchievementsViewController: PortraitViewController {
    private let viewModel: AchievementsViewModel

    init(viewModel: AchievementsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Achievements"
        addGradientBackground(top: UIColor(red: 0.26, green: 0.12, blue: 0.4, alpha: 1), bottom: UIColor(red: 0.04, green: 0.02, blue: 0.08, alpha: 1))
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        viewModel.achievements().forEach { achievement in
            let label = UILabel()
            label.numberOfLines = 0
            label.textColor = .white
            label.font = .systemFont(ofSize: 17, weight: .semibold)
            label.backgroundColor = achievement.isUnlocked ? UIColor.systemGreen.withAlphaComponent(0.28) : UIColor.white.withAlphaComponent(0.12)
            label.layer.cornerRadius = 16
            label.layer.masksToBounds = true
            label.text = "\n  \(achievement.isUnlocked ? "Unlocked" : "Locked"): \(achievement.title)\n  \(achievement.description)\n"
            stack.addArrangedSubview(label)
        }
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

final class SettingsViewController: PortraitViewController {
    private let viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        addGradientBackground(top: UIColor(red: 0.1, green: 0.17, blue: 0.22, alpha: 1), bottom: UIColor(red: 0.01, green: 0.03, blue: 0.05, alpha: 1))

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(makeSectionLabel("AUDIO & FEEDBACK"))
        stack.addArrangedSubview(makeToggleCard(title: "Sound Effects", subtitle: "Whistles, hits, and goals.", isOn: viewModel.soundEnabled, action: #selector(soundChanged(_:))))
        stack.addArrangedSubview(makeToggleCard(title: "Music", subtitle: "Background stadium track.", isOn: viewModel.musicEnabled, action: #selector(musicChanged(_:))))
        stack.addArrangedSubview(makeToggleCard(title: "Haptics", subtitle: "Vibration on impacts.", isOn: viewModel.hapticsEnabled, action: #selector(hapticsChanged(_:))))

        stack.addArrangedSubview(makeSectionLabel("DATA"))
        let resetButton = MenuActionButton(title: "RESET PROGRESS")
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        stack.addArrangedSubview(resetButton)

        scrollView.addSubview(stack)
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 18),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(red: 0.55, green: 0.85, blue: 0.95, alpha: 1)
        label.font = .systemFont(ofSize: 13, weight: .black)
        label.letterSpacing(text: text, spacing: 1.4)
        return label
    }

    private func makeCardContainer() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        return card
    }

    private func makeToggleCard(title: String, subtitle: String, isOn: Bool, action: Selector) -> UIView {
        let card = makeCardContainer()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.66)
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.numberOfLines = 0
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.translatesAutoresizingMaskIntoConstraints = false
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.onTintColor = UIColor(red: 0.18, green: 0.92, blue: 0.54, alpha: 1)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: action, for: .valueChanged)
        card.addSubview(textStack)
        card.addSubview(toggle)
        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            textStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -12),
            toggle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        return card
    }

    @objc private func soundChanged(_ sender: UISwitch) {
        viewModel.soundEnabled = sender.isOn
    }

    @objc private func musicChanged(_ sender: UISwitch) {
        viewModel.musicEnabled = sender.isOn
    }

    @objc private func hapticsChanged(_ sender: UISwitch) {
        viewModel.hapticsEnabled = sender.isOn
    }

    @objc private func resetTapped() {
        let controller = UIAlertController(title: "Reset Progress", message: "This clears level statistics and shop purchases. This cannot be undone.", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.viewModel.resetProgress()
            self?.presentInfo(title: "Done", message: "Your progress has been reset.")
        })
        present(controller, animated: true)
    }
}

final class ShopViewController: PortraitViewController {
    private let viewModel: ShopViewModel
    private let coinsLabel = UILabel()
    private let stack = UIStackView()

    init(viewModel: ShopViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Shop"
        addGradientBackground(top: UIColor(red: 0.38, green: 0.24, blue: 0.06, alpha: 1), bottom: UIColor(red: 0.08, green: 0.04, blue: 0.01, alpha: 1))

        let balanceCard = makeBalanceCard()
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stack)
        view.addSubview(balanceCard)
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            balanceCard.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            balanceCard.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            balanceCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: balanceCard.bottomAnchor, constant: 14),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
        reload()
    }

    private func makeBalanceCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        let caption = UILabel()
        caption.text = "YOUR BALANCE"
        caption.textColor = UIColor.white.withAlphaComponent(0.7)
        caption.font = .systemFont(ofSize: 12, weight: .black)
        caption.letterSpacing(text: "YOUR BALANCE", spacing: 1.2)
        caption.translatesAutoresizingMaskIntoConstraints = false
        coinsLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.3, alpha: 1)
        coinsLabel.font = .systemFont(ofSize: 26, weight: .black)
        coinsLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(caption)
        card.addSubview(coinsLabel)
        NSLayoutConstraint.activate([
            caption.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            caption.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            coinsLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            coinsLabel.topAnchor.constraint(equalTo: caption.bottomAnchor, constant: 4),
            coinsLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }

    private func reload() {
        coinsLabel.text = "\(viewModel.coins) coins"
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        var lastCategory = ""
        viewModel.items.forEach { item in
            if item.category != lastCategory {
                lastCategory = item.category
                let header = UILabel()
                header.text = item.category.uppercased()
                header.textColor = UIColor(red: 1.0, green: 0.82, blue: 0.4, alpha: 1)
                header.font = .systemFont(ofSize: 13, weight: .black)
                header.letterSpacing(text: item.category.uppercased(), spacing: 1.3)
                stack.addArrangedSubview(header)
            }
            stack.addArrangedSubview(makeItemCard(for: item))
        }
    }

    private func makeItemCard(for item: ShopItem) -> UIView {
        let card = UIControl()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        card.layer.cornerRadius = 18
        card.layer.borderWidth = viewModel.isEquipped(item) ? 2 : 1
        card.layer.borderColor = viewModel.isEquipped(item)
            ? UIColor(red: 0.18, green: 0.92, blue: 0.54, alpha: 1).cgColor
            : UIColor.white.withAlphaComponent(0.16).cgColor

        let swatch = UIView()
        swatch.translatesAutoresizingMaskIntoConstraints = false
        swatch.backgroundColor = item.accent.color
        swatch.layer.cornerRadius = 14

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        let detailLabel = UILabel()
        detailLabel.text = item.detail
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.66)
        detailLabel.font = .systemFont(ofSize: 13, weight: .medium)
        detailLabel.numberOfLines = 0
        let statusLabel = UILabel()
        statusLabel.text = viewModel.statusText(for: item)
        statusLabel.textColor = viewModel.isEquipped(item)
            ? UIColor(red: 0.36, green: 1.0, blue: 0.62, alpha: 1)
            : UIColor(red: 1.0, green: 0.84, blue: 0.3, alpha: 1)
        statusLabel.font = .systemFont(ofSize: 13, weight: .heavy)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel, statusLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.isUserInteractionEnabled = false
        swatch.isUserInteractionEnabled = false

        card.addSubview(swatch)
        card.addSubview(textStack)
        NSLayoutConstraint.activate([
            swatch.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            swatch.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            swatch.widthAnchor.constraint(equalToConstant: 46),
            swatch.heightAnchor.constraint(equalToConstant: 46),
            textStack.leadingAnchor.constraint(equalTo: swatch.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            textStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        card.addAction(UIAction { [weak self] _ in
            self?.handleTap(on: item)
        }, for: .touchUpInside)
        return card
    }

    private func handleTap(on item: ShopItem) {
        switch viewModel.handle(item) {
        case .purchased:
            reload()
        case .equipped:
            reload()
        case .insufficientFunds:
            presentInfo(title: "Not enough coins", message: "Win levels to earn more coins, then come back for \(item.title).")
        }
    }
}
