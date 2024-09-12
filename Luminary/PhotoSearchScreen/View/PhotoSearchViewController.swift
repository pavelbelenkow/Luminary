import UIKit

final class PhotoSearchViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var searchHistoryTableViewController: SearchHistoryTableViewController = {
        let controller = SearchHistoryTableViewController()
        controller.interactionDelegate = self
        return controller
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: searchHistoryTableViewController)
        searchController.searchBar.placeholder = Const.searchBarPlaceholder
        searchController.searchBar.tintColor = .darkBlue
        searchController.searchBar.searchTextField.backgroundColor = .mintBlue
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private lazy var photoSearchCollectionView: PhotoSearchCollectionView = {
        let view = PhotoSearchCollectionView(frame: .zero, collectionViewLayout: makeTwoColumnLayout())
        view.interactionDelegate = self
        return view
    }()
    
    private lazy var sortButton: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: Const.sortIcon),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        item.tintColor = .darkBlue
        return item
    }()
    
    private lazy var layoutSwitchButton: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: Const.twoColumnsGridIcon),
            style: .plain,
            target: self,
            action: #selector(layoutSwitchButtonTapped)
        )
        item.tintColor = .darkBlue
        return item
    }()
    
    private lazy var stateView: StateView = {
        let view = StateView()
        view.isHidden = true
        view.retryAction = { [weak self] in
            self?.viewModel.searchPhotos()
        }
        return view
    }()
    
    private var viewModel: any PhotoSearchViewModelProtocol
    
    // MARK: - Initializers
    
    init(viewModel: any PhotoSearchViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        bindViewModel()
    }
}

// MARK: - Setup UI

private extension PhotoSearchViewController {
    
    func setupAppearance() {
        view.backgroundColor = .lavender
        setupNavigationBar()
        setupPhotoSearchCollectionView()
        setupStateView()
    }
    
    func setupNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.standardAppearance.shadowColor = .clear
        navigationBar?.standardAppearance.backgroundColor = .lavender
        navigationItem.leftBarButtonItem = sortButton
        navigationItem.rightBarButtonItem = layoutSwitchButton
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupPhotoSearchCollectionView() {
        view.addSubview(photoSearchCollectionView)
        
        NSLayoutConstraint.activate([
            photoSearchCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoSearchCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            photoSearchCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            photoSearchCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupStateView() {
        view.addSubview(stateView)
        
        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func makeTwoColumnLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let numberOfItemsPerRow: CGFloat = 2
        let spacing: CGFloat = 8
        let totalSpacing = spacing * (numberOfItemsPerRow - 1)
        let itemWidth = ((view.bounds.width - 32) - totalSpacing) / numberOfItemsPerRow
        layout.itemSize = CGSize(width: itemWidth, height: 300)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.footerReferenceSize = .init(width: 40, height: 40)
        return layout
    }
    
    func makeSingleColumnLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width - 32, height: 300)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 12
        layout.footerReferenceSize = .init(width: 40, height: 40)
        return layout
    }
    
    func bindViewModel() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.searchBarTextSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.searchController.searchBar.text = text
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.recentSearchesSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.searchHistoryTableViewController.tableView.reloadData()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.photosSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                self?.photoSearchCollectionView.applySnapshot(for: photos)
            }
            .store(in: &viewModel.cancellables)
    }
    
    func handleStateChange(_ state: State) {
        photoSearchCollectionView.isHidden = !(state == .loadingMore || state == .loaded)
        photoSearchCollectionView.updateActivityIndicator(for: state)
        stateView.configure(for: state)
    }
    
    @objc func sortButtonTapped() {
        viewModel.changeSortType()
    }
    
    @objc func layoutSwitchButtonTapped() {
        let currentLayout = photoSearchCollectionView.collectionViewLayout
        
        if currentLayout is UICollectionViewFlowLayout &&
            (currentLayout as! UICollectionViewFlowLayout).itemSize.width == view.bounds.width
        {
            photoSearchCollectionView.setCollectionViewLayout(makeTwoColumnLayout(), animated: true)
            layoutSwitchButton.image = UIImage(systemName: Const.twoColumnsGridIcon)
        } else {
            photoSearchCollectionView.setCollectionViewLayout(makeSingleColumnLayout(), animated: true)
            layoutSwitchButton.image = UIImage(systemName: Const.oneColumnGridIcon)
        }
    }
}

//MARK: - UISearchControllerDelegate Methods

extension PhotoSearchViewController: UISearchControllerDelegate {
    
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
    }
}

//MARK: - UISearchResultsUpdating Methods

extension PhotoSearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.filterSuggestions(for: searchController.searchBar.text)
    }
}

// MARK: - UISearchBarDelegate Methods

extension PhotoSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        
        viewModel.setSearchQuery(for: query)
        searchHistoryTableViewController.dismiss(animated: true)
    }
}

// MARK: - SearchHistoryTableViewControllerDelegate Methods

extension PhotoSearchViewController: SearchHistoryTableViewControllerDelegate {
    
    func getRecentSearches() -> [String] {
        viewModel.recentSearchesSubject.value
    }
    
    func didTapSearchQuery(at index: Int) {
        viewModel.didSelectSearchQuery(at: index)
    }
}

// MARK: - PhotoSearchCollectionViewDelegate Methods

extension PhotoSearchViewController: PhotoSearchCollectionViewDelegate {
    
    func didScrollToBottomCollectionView() {
        viewModel.loadMorePhotos()
    }
    
    func didTapPhoto(at index: Int) {
        let photoId = viewModel.photosSubject.value[index].id
        let viewModel = PhotoDetailedViewModel(photoId: photoId)
        let viewController = PhotoDetailedViewController(viewModel: viewModel)
        present(viewController, animated: true)
    }
}
