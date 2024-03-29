//
//  FilmListCollectionViewCell.swift
//  sf_diplom
//
//  Created by Иван on 15.12.2023.
//

import UIKit
import SnapKit
import SDWebImage
import MarqueeLabel
import RealmSwift

class FilmListCollectionViewCell: UICollectionViewCell {
    
    var isFavorite: Bool!
    var model: Model!
    var kinopoiskID: Int!
    var filmCellData: FilmCellData!
    
    private let nameLabel: MarqueeLabel = {
        let label = MarqueeLabel()
        label.trailingBuffer = 30
        return label
    }()
    private let rateLabel = UILabel()
    private let yearLabel = UILabel()
    private let imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.layer.cornerRadius = 4
        backgroundView.clipsToBounds = true

        let heartImageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartImageView.contentMode = .scaleAspectFit
        heartImageView.tintColor = .white
        
        button.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalTo(button)
        }

        button.addSubview(heartImageView)
        heartImageView.snp.makeConstraints { make in
            make.center.equalTo(button)
            make.width.height.equalTo(17)
        }
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(film: FilmObject, model: Model) {
        filmCellData = film.convertToFilmCellData()
        nameLabel.text = filmCellData.name
        rateLabel.text = " \(filmCellData.rate) "
        yearLabel.text = " \(filmCellData.year) "
        imageView.sd_setImage(with: filmCellData.imgUrl)
        isFavorite = film.isFavorite
        
        self.model = model
        self.kinopoiskID = filmCellData.id
        
        guard let heartImageView = likeButton.subviews.compactMap({ $0 as? UIImageView }).first else { return }
        heartImageView.tintColor = isFavorite ? .red : .white
    }
}
private extension FilmListCollectionViewCell {
    
    // Constants
    private struct Constants {
        static let contentInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        static let cornerRadius: CGFloat = 10.0
        static let borderWidth: CGFloat = 1.0
        static let shadowOffset = CGSize(width: 0, height: 0)
        static let shadowRadius: CGFloat = 5.0
        static let shadowOpacity: Float = 2.5
    }
    
    func initialize() {
        configureAppearance()
        setupConstraints()
    }
    
    func configureAppearance() {
        contentView.backgroundColor = UIColor(named: "BackgroundColor")
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layer.borderWidth = Constants.borderWidth
        contentView.layer.borderColor = UIColor(named: "BorderShadowColor")?.cgColor
        contentView.layer.shadowOffset = Constants.shadowOffset
        contentView.layer.shadowRadius = Constants.shadowRadius
        contentView.layer.shadowColor = UIColor(named: "BorderShadowColor")?.cgColor
        contentView.layer.shadowOpacity = Constants.shadowOpacity
        contentView.layer.masksToBounds = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(rateLabel)
        contentView.addSubview(yearLabel)
        contentView.addSubview(likeButton)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.layer.masksToBounds = true
        
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        nameLabel.lineBreakMode = .byTruncatingTail
        
        rateLabel.textColor = .white
        rateLabel.backgroundColor = .black.withAlphaComponent(0.5)
        rateLabel.layer.cornerRadius = 4
        rateLabel.clipsToBounds = true

        
        yearLabel.textColor = .white
        yearLabel.backgroundColor = .black.withAlphaComponent(0.5)
        yearLabel.layer.cornerRadius = 4
        yearLabel.clipsToBounds = true
        
        likeButton.accessibilityIdentifier = "likeButton"
        likeButton.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(likeButtonTapped))
        likeButton.addGestureRecognizer(tapGesture)
        
    }
    
    func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Constants.contentInsets)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.right.equalTo(contentView.snp.right)
            make.left.equalTo(contentView.snp.left)
            make.height.equalTo(contentView.snp.height).multipliedBy(0.85)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(imageView.snp.bottom).offset(5)
        }
        
        rateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.equalToSuperview().inset(8)
            make.height.equalTo(20)
        }

        
        yearLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.right.top.equalToSuperview().inset(8)
            make.height.equalTo(rateLabel.snp.height)
        }
        
        likeButton.snp.makeConstraints { make in
            make.centerX.equalTo(imageView)
            make.top.equalTo(imageView.snp.top).inset(8)
            make.height.equalTo(yearLabel.snp.height)
            make.width.equalTo(likeButton.snp.height)
        }
    }
    
    @objc func likeButtonTapped() {
        guard let heartImageView = likeButton.subviews.compactMap({ $0 as? UIImageView }).first else { return }
        
        var film: FilmObject? // Declare film object outside the scope of the if let block
            
            if let existingFilm = model.getFilmFromRealmById(id: self.kinopoiskID) {
                film = existingFilm // Assign existing film to the film variable
            } else {
                let newFilm = FilmObject()
                newFilm.kinopoiskId = self.kinopoiskID
                newFilm.isFavorite = false
                newFilm.nameRu = filmCellData.name
                newFilm.ratingKinopoisk = Double(filmCellData.rate) ?? 0.0
                newFilm.year = Int(filmCellData.year) ?? 0
                if let imgUrl = filmCellData.imgUrl {
                    newFilm.posterUrlPreview = imgUrl.absoluteString
                }
                
                model.updateRealm(with: newFilm)
                film = newFilm // Assign new film to the film variable
            }
        guard let film = film else {
              return
          }
        let newFavoriteState = !film.isFavorite
        
        do {
            let realm = try Realm()
            try realm.write {
                film.isFavorite = newFavoriteState
            }
        } catch {
            print("Error updating favorite state: \(error)")
        }
        
        heartImageView.tintColor = newFavoriteState ? .red : .white
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.2
        animation.fromValue = 0.8
        animation.toValue = 1.25
        animation.autoreverses = true
        animation.delegate = self
        heartImageView.layer.add(animation, forKey: "splashAnimation")
    }

    
}
extension FilmListCollectionViewCell: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let collectionView = superview as? UICollectionView {
            collectionView.reloadData()
        }
    }
}
