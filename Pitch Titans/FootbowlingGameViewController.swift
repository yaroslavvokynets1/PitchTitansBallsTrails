import UIKit
import SpriteKit

final class FootbowlingGameViewController: PortraitViewController, FootbowlingSceneDelegate {
    private let viewModel: GameLevelViewModel
    private let shotsLabel = UILabel()
    private let resultLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private var finishOverlay: UIView?
    private var isCompleted = false

    init(viewModel: GameLevelViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = SKView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.level.title
        configureOverlay()
        viewModel.begin()
        guard let skView = view as? SKView else { return }
        skView.ignoresSiblingOrder = true
        skView.backgroundColor = viewModel.level.backgroundBottom.color
        let scene = GameScene(size: skView.bounds.size, level: viewModel.level)
        scene.gameDelegate = self
        skView.presentScene(scene)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let skView = view as? SKView, skView.scene == nil else { return }
        let scene = GameScene(size: skView.bounds.size, level: viewModel.level)
        scene.gameDelegate = self
        skView.presentScene(scene)
    }

    func sceneDidShoot() {
        guard !isCompleted else { return }
        viewModel.registerShot()
        shotsLabel.text = "Shots: \(viewModel.shotCount) / Par \(viewModel.level.parShots)"
        progressView.setProgress(min(Float(viewModel.shotCount) / Float(viewModel.level.parShots), 1), animated: true)
        resultLabel.text = "Rolling..."
    }

    func sceneDidFinish(defendersKnocked: Int, remainingDefenders: Int, completed: Bool) {
        guard !isCompleted else { return }
        viewModel.finish(defendersKnocked: defendersKnocked, won: completed)
        if completed {
            isCompleted = true
            resultLabel.text = "Level complete! \(defendersKnocked) defenders down."
            showFinishOverlay(defendersKnocked: defendersKnocked)
        } else {
            resultLabel.text = "Good hit. \(remainingDefenders) defenders left."
        }
    }

    private func configureOverlay() {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 22
        blur.layer.masksToBounds = true
        let panel = UIStackView()
        panel.axis = .vertical
        panel.spacing = 7
        panel.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        panel.layer.cornerRadius = 22
        panel.layer.borderWidth = 1
        panel.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        panel.layoutMargins = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        panel.isLayoutMarginsRelativeArrangement = true
        panel.translatesAutoresizingMaskIntoConstraints = false
        let header = UIStackView()
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 10
        let badge = SoccerBallBadgeView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.text = viewModel.level.themeName
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .black)
        titleLabel.adjustsFontSizeToFitWidth = true
        header.addArrangedSubview(badge)
        header.addArrangedSubview(titleLabel)
        shotsLabel.text = "Shots: 0 / Par \(viewModel.level.parShots)"
        shotsLabel.textColor = UIColor(red: 0.64, green: 1.0, blue: 0.78, alpha: 1)
        shotsLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        resultLabel.text = "Drag from the ball to draw a strike path."
        resultLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        resultLabel.font = .systemFont(ofSize: 13, weight: .medium)
        resultLabel.numberOfLines = 0
        progressView.progress = 0
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.16)
        progressView.progressTintColor = UIColor(red: 0.18, green: 0.92, blue: 0.54, alpha: 1)
        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true
        panel.addArrangedSubview(header)
        panel.addArrangedSubview(shotsLabel)
        panel.addArrangedSubview(progressView)
        panel.addArrangedSubview(resultLabel)
        let exitButton = MenuActionButton(title: "EXIT")
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        view.addSubview(blur)
        blur.contentView.addSubview(panel)
        view.addSubview(exitButton)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            blur.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            blur.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            exitButton.widthAnchor.constraint(equalToConstant: 108),
            badge.widthAnchor.constraint(equalToConstant: 34),
            badge.heightAnchor.constraint(equalToConstant: 34),
            progressView.heightAnchor.constraint(equalToConstant: 6),
            panel.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor),
            panel.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            panel.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor)
        ])
    }

    private func showFinishOverlay(defendersKnocked: Int) {
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        let card = GlassPanelView()
        card.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = UIEdgeInsets(top: 28, left: 24, bottom: 24, right: 24)
        stack.isLayoutMarginsRelativeArrangement = true
        let titleLabel = UILabel()
        titleLabel.text = "LEVEL COMPLETE"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 28, weight: .black)
        titleLabel.textAlignment = .center
        let infoLabel = UILabel()
        infoLabel.text = "Defenders knocked: \(defendersKnocked)\nShots used: \(viewModel.shotCount)"
        infoLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        infoLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        let replayButton = MenuActionButton(title: "REPLAY", primary: true)
        replayButton.addTarget(self, action: #selector(replayTapped), for: .touchUpInside)
        let exitButton = MenuActionButton(title: "EXIT")
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(infoLabel)
        stack.addArrangedSubview(replayButton)
        stack.addArrangedSubview(exitButton)
        card.addSubview(stack)
        overlay.addSubview(card)
        view.addSubview(overlay)
        finishOverlay = overlay
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
    }

    @objc private func exitTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func replayTapped() {
        finishOverlay?.removeFromSuperview()
        finishOverlay = nil
        isCompleted = false
        progressView.setProgress(0, animated: false)
        shotsLabel.text = "Shots: 0 / Par \(viewModel.level.parShots)"
        resultLabel.text = "Drag from the ball to draw a strike path."
        viewModel.begin()
        guard let skView = view as? SKView else { return }
        let scene = GameScene(size: skView.bounds.size, level: viewModel.level)
        scene.gameDelegate = self
        skView.presentScene(scene)
    }
}
