import UIKit

@objc(WMFPageIssuesTableViewController)
class PageIssuesTableViewController: UITableViewController {
    
    fileprivate var theme = Theme.standard
    
    var issues = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = WMFLocalizedStringWithDefaultValue("page-issues", nil, nil, "Page issues", "Label for the button that shows the \"Page issues\" dialog, where information about the imperfections of the current page is provided (by displaying the warning/cleanup templates).\n{{Identical|Page issue}}")
        
        self.tableView.estimatedRowHeight = 90.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.tableView.register(BaseTableViewCell.self, forCellReuseIdentifier: "BaseTableViewCell")

        let xButton = UIBarButtonItem.wmf_buttonType(WMFButtonType.X, target: self, action: #selector(closeButtonPressed))
        self.navigationItem.leftBarButtonItem = xButton
        apply(theme: self.theme)
    }
    
    func closeButtonPressed() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaseTableViewCell", for: indexPath)

        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        cell.textLabel?.text = issues[indexPath.row]
        
        cell.isUserInteractionEnabled = false
        cell.backgroundColor = self.theme.colors.paperBackground
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = self.theme.colors.midBackground
        cell.textLabel?.textColor = self.theme.colors.primaryText

        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return issues.count
    }

}

extension PageIssuesTableViewController: Themeable {
    public func apply(theme: Theme) {
        self.theme = theme
        
        guard viewIfLoaded != nil else {
            return
        }
        
        self.tableView.backgroundColor = theme.colors.baseBackground
        self.tableView.reloadData()
    }
}
