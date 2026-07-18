import UIKit
import StoreKit

final class GameViewController: UIViewController {
    private let viewModel = LaunchViewModel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
        viewModel.start { [weak self] route in
            DispatchQueue.main.async {
                self?.handle(route)
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    private func handle(_ route: LaunchRoute) {
        switch route {
        case .game:
            showGame()
        case .external(let address, let shouldAskForRating):
            showExternal(address: address, shouldAskForRating: shouldAskForRating)
        }
    }

    private func showGame() {
        let controller = PortraitNavigationController(rootViewController: MainMenuViewController(viewModel: MainMenuViewModel()))
        controller.modalPresentationStyle = .fullScreen
        setRoot(controller)
    }

    private func showExternal(address: String, shouldAskForRating: Bool) {
        let controller = PortalViewController(address: address)
        controller.modalPresentationStyle = .fullScreen
        setRoot(controller)
        guard shouldAskForRating, let scene = controller.view.window?.windowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
        viewModel.markRatingAsked()
    }

    private func setRoot(_ controller: UIViewController) {
        guard let window = view.window else {
            present(controller, animated: false)
            return
        }
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
}
