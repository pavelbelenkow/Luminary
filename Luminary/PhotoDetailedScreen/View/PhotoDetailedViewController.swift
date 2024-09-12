import UIKit

final class PhotoDetailedViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .black20
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .mintBlue
        button.setImage(UIImage(systemName: Const.shareIcon), for: .normal)
        button.addTarget(self, action: #selector(shareImage), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .darkBlue
        button.setImage(UIImage(systemName: Const.saveIcon), for: .normal)
        button.addTarget(self, action: #selector(saveImageToGallery), for: .touchUpInside)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkBlue
        label.textAlignment = .left
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .mintBlue
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stateView: StateView = {
        let view = StateView()
        view.isHidden = true
        view.retryAction = { [weak self] in
            self?.viewModel.loadPhotoDetail()
        }
        return view
    }()
    
    private var viewModel: any PhotoDetailedViewModelProtocol
    
    // MARK: - Initializers
    
    init(viewModel: any PhotoDetailedViewModelProtocol) {
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
        viewModel.loadPhotoDetail()
    }
}

// MARK: - Setup UI

private extension PhotoDetailedViewController {
    
    func setupAppearance() {
        view.backgroundColor = .lavender
        setupImageView()
        setupShareButton()
        setupSaveButton()
        setupDescriptionLabel()
        setupAuthorLabel()
        setupStateView()
    }
    
    func setupImageView() {
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupShareButton() {
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            shareButton.widthAnchor.constraint(equalToConstant: 44),
            shareButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func setupSaveButton() {
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            saveButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -8),
            saveButton.widthAnchor.constraint(equalToConstant: 44),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func setupDescriptionLabel() {
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func setupAuthorLabel() {
        view.addSubview(authorLabel)
        
        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            authorLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func setupStateView() {
        view.addSubview(stateView)
        stateView.frame = view.bounds
    }
    
    func bindViewModel() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.photoSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photo in
                self?.updateUI(with: photo)
            }
            .store(in: &viewModel.cancellables)
    }
    
    func handleStateChange(_ state: State) {
        stateView.configure(for: state)
        [
            imageView, descriptionLabel, authorLabel
        ].forEach { $0.isHidden = state != .loaded }
    }
    
    func updateUI(with photo: Photo) {
        imageView.addShimmerAnimation(borderWidth: 1)
        
        PhotoLoader.shared.loadPhoto(from: photo.urls.full ?? "") { [weak self] photo in
            guard let self else { return }
            
            imageView.removeShimmerAnimation()
            imageView.image = photo
            shareButton.isHidden = false
            saveButton.isHidden = false
        }
        
        descriptionLabel.text = photo.description
        authorLabel.text = "Author: \(photo.user.name)"
    }
}

// MARK: - Obj-c Private Methods

@objc
private extension PhotoDetailedViewController {
    
    func shareImage() {
        guard let image = imageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact, .saveToCameraRoll]
        present(activityVC, animated: true)
    }
    
    func saveImageToGallery() {
        guard let image = imageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func saveImageCompletion(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error {
            stateView.configure(for: .error(error.localizedDescription))
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image successfully saved to gallery")
        }
    }
}
