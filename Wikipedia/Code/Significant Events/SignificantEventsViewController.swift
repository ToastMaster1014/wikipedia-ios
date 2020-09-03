
import UIKit
import WMF

class SignificantEventsViewController: ColumnarCollectionViewController {
    
    private let significantEventsController = SignificantEventsController()
    private let significantEventsViewModel: SignificantEventsViewModel
    private var events: [TimelineEventViewModel] = []
    
    fileprivate static let sideScrollingCellReuseIdentifier = "SignificantEventsSideScrollingCollectionViewCell"
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    required init(significantEventsViewModel: SignificantEventsViewModel, theme: Theme) {
        self.significantEventsViewModel = significantEventsViewModel
        super.init()
        self.theme = theme
    }

    override func metrics(with size: CGSize, readableWidth: CGFloat, layoutMargins: UIEdgeInsets) -> ColumnarCollectionViewLayoutMetrics {
        return ColumnarCollectionViewLayoutMetrics.tableViewMetrics(with: size, readableWidth: readableWidth, layoutMargins: layoutMargins)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutManager.register(SignificantEventsSideScrollingCollectionViewCell.self, forCellWithReuseIdentifier: SignificantEventsViewController.sideScrollingCellReuseIdentifier, addPlaceholder: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, estimatedHeightForItemAt indexPath: IndexPath, forColumnWidth columnWidth: CGFloat) -> ColumnarCollectionViewLayoutHeightEstimate {
        var estimate = ColumnarCollectionViewLayoutHeightEstimate(precalculated: false, height: 350)
        guard let placeholderCell = layoutManager.placeholder(forCellWithReuseIdentifier: SignificantEventsViewController.sideScrollingCellReuseIdentifier) as? SignificantEventsSideScrollingCollectionViewCell else {
            return estimate
        }
        guard let event = events[safeIndex: indexPath.item] else {
            return estimate
        }
        placeholderCell.layoutMargins = layout.itemLayoutMargins
        
        switch event {
        case .largeEvent(let largeEvent):
            placeholderCell.configure(with: largeEvent, theme: theme)
        default:
            break
        }
        
        estimate.height = placeholderCell.sizeThatFits(CGSize(width: columnWidth, height: UIView.noIntrinsicMetric), apply: false).height
        estimate.precalculated = true
        return estimate
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SignificantEventsViewController.sideScrollingCellReuseIdentifier, for: indexPath)
        guard let significantEventsSideScrollingCell = cell as? SignificantEventsSideScrollingCollectionViewCell else {
            return cell
        }
        guard let event = events[safeIndex: indexPath.item] else {
            return cell
        }

        significantEventsSideScrollingCell.layoutMargins = layout.itemLayoutMargins
        
        switch event {
        case .largeEvent(let largeEvent):
            significantEventsSideScrollingCell.configure(with: largeEvent, theme: theme)
            significantEventsSideScrollingCell.apply(theme: theme)
        default:
            break
        }
        
        //significantEventsSideScrollingCell.timelineView.extendTimelineAboveDot = indexPath.section == 0 ? false : true

        return significantEventsSideScrollingCell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return events.count
    }

    @objc func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}