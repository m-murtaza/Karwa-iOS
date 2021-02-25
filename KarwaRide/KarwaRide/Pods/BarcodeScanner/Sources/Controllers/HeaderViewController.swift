import UIKit

/// Delegate to handle touch event of the close button.
protocol HeaderViewControllerDelegate: class {
  func headerViewControllerDidTapCloseButton(_ controller: HeaderViewController)
  func headerViewControllerDidTapManageButton(_ controller: HeaderViewController)
}

/// View controller with title label and close button.
/// It will be added as a child view controller if `BarcodeScannerController` is being presented.
public final class HeaderViewController: UIViewController {
  weak var delegate: HeaderViewControllerDelegate?

  // MARK: - UI properties

  /// Header view with title label and close button.
  public private(set) lazy var navigationBar: UINavigationBar = self.makeNavigationBar()
  /// Title view of the navigation bar.
  public private(set) lazy var titleLabel: UILabel = self.makeTitleLabel()
  /// Left bar button item of the navigation bar.
  public private(set) lazy var closeButton: UIButton = self.makeCloseButton()
  /// Right bar button item of the navigation bar.
    public private(set) lazy var manageButton: UIButton = self.makeManageButton()

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    navigationBar.delegate = self
    closeButton.addTarget(self, action: #selector(handleCloseButtonTap), for: .touchUpInside)
    manageButton.addTarget(self, action: #selector(handleManageButtonTap), for: .touchUpInside)
    
    navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#ebf6f4")
    view.addSubview(navigationBar)
    setupConstraints()
  }
    
  // MARK: - Actions

  @objc private func handleManageButtonTap() {
    delegate?.headerViewControllerDidTapManageButton(self)
  }
    
  @objc private func handleCloseButtonTap() {
    delegate?.headerViewControllerDidTapCloseButton(self)
  }

  // MARK: - Layout

  private func setupConstraints() {
    NSLayoutConstraint.activate(
      navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    )

    if #available(iOS 11, *) {
      navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    } else {
      navigationBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
  }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
// MARK: - Subviews factory

private extension HeaderViewController {
  func makeNavigationBar() -> UINavigationBar {
    let navigationBar = UINavigationBar()
    navigationBar.isTranslucent = false
    navigationBar.backgroundColor = .white
    navigationBar.items = [makeNavigationItem()]
    return navigationBar
  }

  func makeNavigationItem() -> UINavigationItem {
    let navigationItem = UINavigationItem()

    closeButton.sizeToFit()
    manageButton.sizeToFit()
    titleLabel.sizeToFit()

    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: manageButton)
    navigationItem.titleView = titleLabel
    return navigationItem
  }

  func makeTitleLabel() -> UILabel {
    let label = UILabel()
    label.text = Locale.current.languageCode == "ar" ?  "صور الباركود وأدفع" : "Scan N Pay"
    label.font = UIFont.boldSystemFont(ofSize: 17)
    label.textColor = hexStringToUIColor(hex: "#49AAA6")
    label.numberOfLines = 1
    label.textAlignment = .center
    return label
  }

  func makeCloseButton() -> UIButton {
    let image = UIImage(named: "CrossBarButton") as UIImage?
    let button   = UIButton(type: UIButtonType.custom) as UIButton
    button.setImage(image, for: .normal)
    return button
  }
    
    func makeManageButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(Locale.current.languageCode == "ar" ?  "يدير" : "MANAGE", for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.tintColor = hexStringToUIColor(hex: "#49AAA6")
        return button
    }
}

// MARK: - UINavigationBarDelegate

extension HeaderViewController: UINavigationBarDelegate {
  public func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}
