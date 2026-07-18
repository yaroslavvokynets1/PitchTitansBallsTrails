import UIKit

final class PortraitNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        topViewController?.supportedInterfaceOrientations ?? .portrait
    }

    override var prefersStatusBarHidden: Bool {
        topViewController?.prefersStatusBarHidden ?? false
    }
}

class PortraitViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyOrientation(.portrait)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navigationController, navigationController.viewControllers.first !== self else { return }
        navigationController.setNavigationBarHidden(false, animated: animated)
        navigationController.navigationBar.prefersLargeTitles = false
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .black)
        ]
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .black)
        ]
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
    }

    func applyOrientation(_ mask: UIInterfaceOrientationMask) {
        setNeedsUpdateOfSupportedInterfaceOrientations()
        guard let scene = view.window?.windowScene else { return }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { _ in }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

final class GradientView: UIView {
    private let gradientLayer = CAGradientLayer()

    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    func set(top: UIColor, bottom: UIColor) {
        guard let layer = layer as? CAGradientLayer else { return }
        layer.colors = [top.cgColor, bottom.cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}

final class GlassPanelView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.12)
        layer.cornerRadius = 28
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.22).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.32
        layer.shadowRadius = 24
        layer.shadowOffset = CGSize(width: 0, height: 16)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class MenuActionButton: UIButton {
    private let gradientLayer = CAGradientLayer()

    init(title: String, primary: Bool = false) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: primary ? 21 : 17, weight: .black)
        layer.cornerRadius = primary ? 24 : 20
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(primary ? 0.42 : 0.22).cgColor
        contentEdgeInsets = UIEdgeInsets(top: primary ? 18 : 14, left: 18, bottom: primary ? 18 : 14, right: 18)
        gradientLayer.colors = primary
            ? [UIColor(red: 0.22, green: 0.9, blue: 0.5, alpha: 1).cgColor, UIColor(red: 0.02, green: 0.46, blue: 0.86, alpha: 1).cgColor]
            : [UIColor.white.withAlphaComponent(0.2).cgColor, UIColor.white.withAlphaComponent(0.08).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    override var isHighlighted: Bool {
        didSet {
            transform = isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            alpha = isHighlighted ? 0.82 : 1
        }
    }
}

final class SoccerBallBadgeView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let insetRect = rect.insetBy(dx: 4, dy: 4)
        context.setShadow(offset: CGSize(width: 0, height: 10), blur: 16, color: UIColor.black.withAlphaComponent(0.35).cgColor)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: insetRect).fill()
        context.setShadow(offset: .zero, blur: 0)
        UIColor.black.withAlphaComponent(0.86).setFill()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        UIBezierPath(ovalIn: CGRect(x: center.x - 10, y: center.y - 10, width: 20, height: 20)).fill()
        for angle in stride(from: 0.0, to: Double.pi * 2, by: Double.pi * 2 / 5) {
            let point = CGPoint(x: center.x + cos(angle) * 25, y: center.y + sin(angle) * 25)
            UIBezierPath(ovalIn: CGRect(x: point.x - 7, y: point.y - 7, width: 14, height: 14)).fill()
        }
    }
}

extension UIViewController {
    func addGradientBackground(top: UIColor, bottom: UIColor) {
        let background = GradientView()
        background.set(top: top, bottom: bottom)
        background.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(background, at: 0)
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func makeButton(title: String) -> UIButton {
        MenuActionButton(title: title)
    }

    func presentInfo(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        present(controller, animated: true)
    }
}

extension UILabel {
    func letterSpacing(text: String, spacing: CGFloat) {
        attributedText = NSAttributedString(
            string: text,
            attributes: [
                .kern: spacing,
                .foregroundColor: textColor as Any,
                .font: font as Any
            ]
        )
    }
}
