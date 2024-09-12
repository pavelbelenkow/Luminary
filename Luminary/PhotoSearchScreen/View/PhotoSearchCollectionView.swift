import UIKit

// MARK: - Delegates

protocol PhotoSearchCollectionViewDelegate: AnyObject {
    func didScrollToBottomCollectionView()
    func didTapPhoto(at index: Int)
}

final class PhotoSearchCollectionView: UICollectionView {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Photo>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Photo>
    
    // MARK: - Private Properties
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    private var diffableDataSource: DataSource?
    
    // MARK: - Properties
    
    weak var interactionDelegate: PhotoSearchCollectionViewDelegate?
    
    // MARK: - Initialisers
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupAppearance()
        makeDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

private extension PhotoSearchCollectionView {
    
    func setupAppearance() {
        backgroundColor = .clear
        
        register(
            PhotoCollectionViewCell.self,
            forCellWithReuseIdentifier: Const.photoCollectionViewCellReuseIdentifier
        )
        
        register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: Const.photoCollectionViewFooterReuseIdentifier
        )
        
        allowsMultipleSelection = false
        showsVerticalScrollIndicator = false
        
        delegate = self
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func makeDataSource() {
        diffableDataSource = DataSource(
            collectionView: self,
            cellProvider: { collectionView, indexPath, photo in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Const.photoCollectionViewCellReuseIdentifier,
                    for: indexPath
                ) as? PhotoCollectionViewCell
                
                cell?.configure(with: photo)
                
                return cell
            }
        )
        
        diffableDataSource?
            .supplementaryViewProvider = { collectionView, kind, indexPath in
                let footerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: Const.photoCollectionViewFooterReuseIdentifier,
                    for: indexPath
                )
                
                footerView.addSubview(self.activityIndicatorView)
                self.activityIndicatorView.frame = footerView.bounds
                self.activityIndicatorView.color = .darkBlue
                
                return footerView
            }
    }
}

// MARK: - Methods

extension PhotoSearchCollectionView {
    
    func applySnapshot(for photos: [Photo]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.zero])
        snapshot.appendItems(photos)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func updateActivityIndicator(for state: State) {
        activityIndicatorView.isHidden = state != .loadingMore
        state != .loadingMore ? activityIndicatorView.stopAnimating() : activityIndicatorView.startAnimating()
    }
}

// MARK: - Delegate Methods

extension PhotoSearchCollectionView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            interactionDelegate?.didScrollToBottomCollectionView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        cell.animateSelection {
            self.interactionDelegate?.didTapPhoto(at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.animateHighlight()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.animateUnhighlight()
    }
}
