
import UIKit

protocol SignificantEventsHorizontallyScrollingCellDelegate: class {
    func tappedLink(_ url: URL, cell: SignificantEventsHorizontallyScrollingCell, sourceView: UIView, sourceRect: CGRect?)
}

class SignificantEventsHorizontallyScrollingCell: CollectionViewCell {
    let descriptionTextView = UITextView()
    var theme: Theme?
    
    weak var delegate: SignificantEventsHorizontallyScrollingCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func reset() {
        super.reset()
        descriptionTextView.attributedText = nil
    }
    
    override func sizeThatFits(_ size: CGSize, apply: Bool) -> CGSize {
        fatalError("Must override sizeThatFits in subclass")
    }
    
    func configure(change: LargeEventViewModel.ChangeDetail, theme: Theme, delegate: SignificantEventsHorizontallyScrollingCellDelegate) {
        
        setupDescription(for: change)
        updateFonts(with: traitCollection)
        
        backgroundView?.layer.cornerRadius = 3
        backgroundView?.layer.masksToBounds = true
        selectedBackgroundView?.layer.cornerRadius = 3
        selectedBackgroundView?.layer.masksToBounds = true
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3
        
        apply(theme: theme)
        self.delegate = delegate
    }
    
    func setupDescription(for change: LargeEventViewModel.ChangeDetail) {
        
        let description: NSAttributedString
        switch change {
        case .snippet(let snippet):
            description = snippet.displayText
        case .reference(let reference):
            description = reference.description
        }
        
        descriptionTextView.attributedText = description
    }
    
    override func setup() {
        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.delegate = self
        descriptionTextView.textContainer.maximumNumberOfLines = 3
        descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contentView.addSubview(descriptionTextView)
        super.setup()
    }
}

extension SignificantEventsHorizontallyScrollingCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.tappedLink(URL, cell: self, sourceView: textView, sourceRect: textView.frame(of: characterRange))
        return false
    }
}

extension SignificantEventsHorizontallyScrollingCell: Themeable {
    func apply(theme: Theme) {
        self.theme = theme
        backgroundColor = .clear
        descriptionTextView.backgroundColor = .clear
        setBackgroundColors(theme.colors.subCellBackground, selected: theme.colors.midBackground)
        layer.shadowColor = theme.colors.cardShadow.cgColor
    }
}