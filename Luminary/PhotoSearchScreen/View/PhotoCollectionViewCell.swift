import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    
    private lazy var photoImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .black20
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var photoDescriptionLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            numberOfLines: 2,
            backgroundColor: .darkBlue,
            textInsets: .small
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var photoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var currentPhotoID: String?
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCellState()
    }
}

// MARK: - Setup UI

private extension PhotoCollectionViewCell {
    
    func setupAppearance() {
        layer.cornerRadius = Const.collectionCellCornerRadius
        layer.masksToBounds = true
        
        setupPhotoContainerView()
        setupPhotoImageView()
        setupPhotoDescriptionLabel()
    }
    
    func setupPhotoContainerView() {
        contentView.addSubview(photoContainerView)
        
        NSLayoutConstraint.activate([
            photoContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            photoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupPhotoImageView() {
        photoContainerView.addSubview(photoImageView)
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: photoContainerView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: photoContainerView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: photoContainerView.trailingAnchor),
            photoImageView.heightAnchor.constraint(equalTo: photoContainerView.heightAnchor, multiplier: 0.75)
        ])
    }
    
    func setupPhotoDescriptionLabel() {
        photoContainerView.addSubview(photoDescriptionLabel)
        
        NSLayoutConstraint.activate([
            photoDescriptionLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor),
            photoDescriptionLabel.leadingAnchor.constraint(equalTo: photoContainerView.leadingAnchor),
            photoDescriptionLabel.trailingAnchor.constraint(equalTo: photoContainerView.trailingAnchor),
            photoDescriptionLabel.bottomAnchor.constraint(equalTo: photoContainerView.bottomAnchor)
        ])
    }
    
    func resetCellState() {
        currentPhotoID = nil
        photoImageView.image = nil
        photoImageView.backgroundColor = .clear
        photoDescriptionLabel.text = nil
        
        PhotoLoader.shared.cancelLoading()
        removeShimmerAnimation()
    }
    
    func loadAndSetupPhoto(from photo: Photo) {
        addShimmerAnimation(borderWidth: 1)
        isUserInteractionEnabled = false
        
        let loadPhotoId = photo.id
        
        PhotoLoader.shared.loadPhoto(from: photo.urls.thumb ?? "") { [weak self] photo in
            guard let self, currentPhotoID == loadPhotoId else { return }
            
            removeShimmerAnimation()
            photoImageView.image = photo
            isUserInteractionEnabled = true
        }
    }
}

// MARK: - Methods

extension PhotoCollectionViewCell {
    
    func configure(with photo: Photo) {
        photoDescriptionLabel.text = photo.description
        currentPhotoID = photo.id
        loadAndSetupPhoto(from: photo)
    }
}
