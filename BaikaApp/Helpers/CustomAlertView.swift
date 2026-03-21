import UIKit

class CustomAlertView: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!    
    @IBOutlet weak var secondLabel: UILabel!
    
    var contentView: UIView!
    var backgroundView: UIView!
    var buttonCompletionHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundView()
        loadViewFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBackgroundView()
        loadViewFromNib()
    }
    
    private func setupBackgroundView() {
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.alpha = 0
    }
    
    private func loadViewFromNib() {
        let nib = UINib(nibName: "CustomAlertView", bundle: nil)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            contentView = view
            contentView.layer.cornerRadius = 10
            contentView.clipsToBounds = true
            self.addSubview(contentView)
        }
    }
    
    func show(on window: UIWindow, withMessage message: String, completion: (() -> Void)? = nil) {
        messageLabel.text = message
        secondLabel.text = " DENEMEDENEM "
        buttonCompletionHandler = completion
        
        // Background view'ı window'un bounds'una göre ayarla
        backgroundView.frame = window.bounds
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            contentView.widthAnchor.constraint(equalToConstant: self.frame.width),
        ])
        
        layoutIfNeeded()
        
        let maxHeight: CGFloat = self.frame.height
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight - 100)
        ])
        
        window.addSubview(backgroundView)
        window.addSubview(self)
        
        self.alpha = 0
        self.contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
            self.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.backgroundView.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
            self.buttonCompletionHandler?()
        }
    }
}
