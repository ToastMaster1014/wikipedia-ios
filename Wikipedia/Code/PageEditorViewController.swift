import UIKit
import Components

protocol PageEditorViewControllerDelegate: AnyObject {
    func pageEditorDidCancelEditing(_ pageEditor: PageEditorViewController, navigateToURL: URL?)
}

class PageEditorViewController: UIViewController {
    
    // MARK: - Properties
    
    private let pageURL: URL
    private let sectionID: Int?
    private let dataStore: MWKDataStore
    private weak var delegate: PageEditorViewControllerDelegate?
    private let theme: Theme
    
    private let fetcher: SectionFetcher
    private var sourceEditor: WKSourceEditorViewController!
    private var editorTopConstraint: NSLayoutConstraint!
    
    private lazy var focusNavigationView: FocusNavigationView = {
        return FocusNavigationView.wmf_viewFromClassNib()
    }()
    
    private lazy var navigationItemController: PageEditorNavigationItemController = {
        let navigationItemController = PageEditorNavigationItemController(navigationItem: navigationItem)
        navigationItemController.delegate = self
        return navigationItemController
    }()
    
    lazy var readingThemesControlsViewController: ReadingThemesControlsViewController = {
        return ReadingThemesControlsViewController.init(nibName: ReadingThemesControlsViewController.nibName, bundle: nil)
    }()
    
// MARK: - Lifecycle
    
    init(pageURL: URL, sectionID: Int?, dataStore: MWKDataStore, delegate: PageEditorViewControllerDelegate, theme: Theme) {
        self.pageURL = pageURL
        self.sectionID = sectionID
        self.fetcher = SectionFetcher(session: dataStore.session, configuration: dataStore.configuration)
        self.dataStore = dataStore
        self.delegate = delegate
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupFocusNavigationView()
        loadWikitext()
        
        apply(theme: theme)
    }
}

// MARK: - Private

private extension PageEditorViewController {
    func setupNavigationBar() {
        navigationItemController.undoButton.isEnabled = false
        navigationItemController.redoButton.isEnabled = false
    }
    
    func setupFocusNavigationView() {

        let closeAccessibilityText = WMFLocalizedString("find-replace-header-close-accessibility", value: "Close find and replace", comment: "Accessibility label for closing the find and replace view.")
        let headerTitle = WMFLocalizedString("find-replace-header", value: "Find and replace", comment: "Find and replace header title.")
        
        focusNavigationView.configure(titleText: headerTitle, closeButtonAccessibilityText: closeAccessibilityText, traitCollection: traitCollection)
        
        focusNavigationView.isHidden = true
        focusNavigationView.delegate = self
        focusNavigationView.apply(theme: theme)
        
        focusNavigationView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(focusNavigationView)
        
        let leadingConstraint = view.leadingAnchor.constraint(equalTo: focusNavigationView.leadingAnchor)
        let trailingConstraint = view.trailingAnchor.constraint(equalTo: focusNavigationView.trailingAnchor)
        let topConstraint = view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: focusNavigationView.topAnchor)
        
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint])
    }
    
    func loadWikitext() {
        fetcher.fetchSection(with: sectionID, articleURL: pageURL) {  [weak self] (result) in
            DispatchQueue.main.async { [weak self] in
                
                guard let self else {
                    return
                }
                
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let response):
                    self.addChildEditor(wikitext: response.wikitext)
                }
            }
        }
    }
    
    func addChildEditor(wikitext: String) {
        
        let viewModel = WKSourceEditorViewModel(configuration: .full, wikitext: wikitext)
        let sourceEditor = WKSourceEditorViewController(viewModel: viewModel, delegate: self, strings: WKEditorLocalizedStrings.editorStrings)
        
        addChild(sourceEditor)
        sourceEditor.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(sourceEditor.view)
        
        let top = view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: sourceEditor.view.topAnchor)
        let bottom = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: sourceEditor.view.bottomAnchor)
        let leading = view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: sourceEditor.view.leadingAnchor)
        let trailing = view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: sourceEditor.view.trailingAnchor)
        
        NSLayoutConstraint.activate([
            top,
            bottom,
            leading,
            trailing
        ])
        
        sourceEditor.didMove(toParent: self)
        self.sourceEditor = sourceEditor
        self.editorTopConstraint = top
    }
    
    func showFocusNavigationView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        editorTopConstraint.constant = -focusNavigationView.frame.height
        focusNavigationView.isHidden = false
        
    }
    
    func hideFocusNavigationView() {
        editorTopConstraint.constant = 0
        focusNavigationView.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: - Themeable

extension PageEditorViewController: Themeable {
    func apply(theme: Theme) {
        guard isViewLoaded else {
            return
        }
        
        navigationItemController.apply(theme: theme)
    }
}

// MARK: - WKSourceEditorViewControllerDelegate

extension PageEditorViewController: WKSourceEditorViewControllerDelegate {
    func sourceEditorViewControllerDidTapFind(sourceEditorViewController: Components.WKSourceEditorViewController) {
        navigationItemController.progressButton.isEnabled = false
        navigationItemController.readingThemesControlsToolbarItem.isEnabled = false
    }
}

// MARK: - PageEditorNavigationItemControllerDelegate

extension PageEditorViewController: PageEditorNavigationItemControllerDelegate {
    func pageEditorNavigationItemController(_ pageEditorNavigationItemController: PageEditorNavigationItemController, didTapProgressButton progressButton: UIBarButtonItem) {

    }
    
    func pageEditorNavigationItemController(_ pageEditorNavigationItemController: PageEditorNavigationItemController, didTapCloseButton closeButton: UIBarButtonItem) {
        delegate?.pageEditorDidCancelEditing(self, navigateToURL: nil)
    }
    
    func pageEditorNavigationItemController(_ pageEditorNavigationItemController: PageEditorNavigationItemController, didTapUndoButton undoButton: UIBarButtonItem) {

    }
    
    func pageEditorNavigationItemController(_ pageEditorNavigationItemController: PageEditorNavigationItemController, didTapRedoButton redoButton: UIBarButtonItem) {

    }
    
    func pageEditorNavigationItemController(_ pageEditorNavigationItemController: PageEditorNavigationItemController, didTapReadingThemesControlsButton readingThemesControlsButton: UIBarButtonItem) {
        
        showReadingThemesControlsPopup(on: self, responder: self, theme: theme)
    }
    
    func pageEditorNavigationItemController(_ pageEditorNavigationItemController: PageEditorNavigationItemController, didTapEditNoticesButton: UIBarButtonItem) {

    }
}

// MARK: - FocusNavigationViewDelegate

extension PageEditorViewController: FocusNavigationViewDelegate {
    func focusNavigationViewDidTapClose(_ focusNavigationView: FocusNavigationView) {
        sourceEditor.closeFind()
    }
}

// MARK: - ReadingThemesControlsResponding

extension PageEditorViewController: ReadingThemesControlsResponding {
    func updateWebViewTextSize(textSize: Int) {
    }
    
    func toggleSyntaxHighlighting(_ controller: ReadingThemesControlsViewController) {
    }
}

// MARK: - ReadingThemesControlsPresenting

extension PageEditorViewController: ReadingThemesControlsPresenting {
    var shouldPassthroughNavBar: Bool {
        return false
    }
    
    var showsSyntaxHighlighting: Bool {
        return true
    }
    
    var readingThemesControlsToolbarItem: UIBarButtonItem {
        return self.navigationItemController.readingThemesControlsToolbarItem
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {

    }
}
