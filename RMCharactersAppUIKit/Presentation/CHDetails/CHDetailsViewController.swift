//
//  CHDetailsViewController.swift
//  RMCharactersAppUIKit
//
//  Created by Selman Aslan on 19.03.2024.
//

import UIKit

final class CHDetailsViewController: UIViewController {
  var viewModel: CHDetailsViewModel
  var dismissSheet: (() -> Void)?
    
    override func endAppearanceTransition() {
        super.endAppearanceTransition()
        dismissSheet?()
    }

  private func createImageView(
    systemName: String? = nil,
    contentMode: UIView.ContentMode = .scaleAspectFill,
    tintColor: UIColor = .clear) -> UIImageView {
      let imageView = UIImageView()
      if let systemName = systemName {
        imageView.image = UIImage(systemName: systemName)
      }
      imageView.contentMode = contentMode
      imageView.clipsToBounds = true
      imageView.tintColor = tintColor
      return imageView
    }

  private func createLabel(font: UIFont, textColor: UIColor = .black, text: String = "") -> UILabel {
    let label = UILabel()
    label.font = font
    label.textColor = textColor
    label.text = text
    return label
  }

  private let containerView: UIView = {
    let view = UIView()
    return view
  }()

  private let nameTextContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white // Arka plan rengini buraya ekleyin
    view.layer.cornerRadius = 25 // Köşe yarıçapını ayarlayın (istenilen değer)
    view.layer.maskedCorners = [.layerMaxXMinYCorner] // Sağ üst köşe için maskeyi uygulayın
    return view
  }()

  private let statusTextContainerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 25
    view.layer.maskedCorners = [.layerMinXMaxYCorner]
    return view
  }()

  private let activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .medium)
    indicator.hidesWhenStopped = true
    return indicator
  }()
  private lazy var statusLabel: UILabel = createLabel(font: .systemFont(ofSize: 22, weight: .bold),
                                                      textColor: UIColor.white,
                                                      text: viewModel.statusField ?? "err")
  private lazy var nameLabel: UILabel = createLabel(font: .systemFont(ofSize: 22, weight: .bold),
                                                    text: viewModel.character.name ?? "err")
  private lazy var favoriteIcon: FavoriteIconView = FavoriteIconView(frame: CGRect(x: 0, y: 0, width: 50, height: 50),
                                                                     viewModel: viewModel.favoriteIconViewModel)
  private lazy var characterImageView: UIImageView = createImageView()
  private lazy var typeText: UILabel = createLabel(font: .systemFont(ofSize: 17, weight: .medium),
                                                   text: "Type: ")
  private lazy var typeLabel: UILabel = createLabel(font: .systemFont(ofSize: 17, weight: .regular),
                                                    text: viewModel.speciesText)
  private lazy var genderText: UILabel = createLabel(font: .systemFont(ofSize: 17, weight: .medium),
                                                     text: "Gender: ")
  private lazy var genderLabel: UILabel = createLabel(font: .systemFont(ofSize: 17, weight: .regular),
                                                      text: viewModel.genderText)
  private lazy var originText: UILabel = createLabel(font: .systemFont(ofSize: 17, weight: .medium),
                                                     text: "Origin: ")
  private lazy var originLabel: UILabel = createLabel(font: .systemFont(ofSize: 17, weight: .regular),
                                                      text: viewModel.originText)
  private lazy var lastSeenText: UILabel = createLabel(font: .systemFont(ofSize: 17, weight: .medium),
                                                       text: "Last Seen: ")
  private lazy var lastSeenLabel: UILabel = createLabel(font: .systemFont(ofSize: 17, weight: .regular),
                                                        text: viewModel.lastSeenText)
  private lazy var episodesText: UILabel = createLabel(font: .systemFont(ofSize: 17, weight: .medium),
                                                       text: "Episodes the Character Was Seen In: ")
  private lazy var episodesLabel: UILabel = createLabel(font: .systemFont(ofSize: 17, weight: .regular),
                                                        text: viewModel.episodesText)

  init(viewModel: CHDetailsViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    statusTextContainerView.backgroundColor = viewModel.detailDesign.bgColor
  }

  private func setupUI() {
    view.backgroundColor = .white
    let characterImageView = self.characterImageView
    characterImageView.contentMode = .scaleAspectFit
    view.addSubview(containerView)
    containerView.addSubview(characterImageView)
    containerView.addSubview(nameTextContainerView)
    nameTextContainerView.addSubview(nameLabel)
    containerView.addSubview(statusTextContainerView)
    statusTextContainerView.addSubview(statusLabel)
    let textViews = [typeText, genderText, originText, lastSeenText, episodesText]
    let labels = [typeLabel, genderLabel, originLabel, lastSeenLabel, episodesLabel]

    for (textView, label) in zip(textViews, labels) {
      view.addSubview(textView)
      view.addSubview(label)
    }
    view.addSubview(favoriteIcon)

    containerView.snp.makeConstraints { make in
      make.top.equalTo(view.snp.top)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(view.snp.width)
    }

    characterImageView.snp.makeConstraints { make in
      make.leading.trailing.top.bottom.equalToSuperview()
    }

    nameTextContainerView.snp.makeConstraints { make in
      make.leading.bottom.equalToSuperview()
      make.height.equalTo(60)
    }

    nameLabel.snp.makeConstraints { make in
      make.leading.equalTo(nameTextContainerView.snp.leading).offset(20) // Sol kenara olan boşluk
      make.trailing.lessThanOrEqualTo(nameTextContainerView.snp.trailing).inset(20) // Sağ kenara olan boşluk
      make.centerY.equalTo(nameTextContainerView.snp.centerY) // Dikey olarak ortala
    }

    statusTextContainerView.snp.makeConstraints { make in
      make.trailing.top.equalToSuperview()
      make.height.equalTo(60)
    }

    statusLabel.snp.makeConstraints { make in
      make.leading.equalTo(statusTextContainerView.snp.leading).inset(20) // Sol kenara olan boşluk
      make.trailing.lessThanOrEqualTo(statusTextContainerView.snp.trailing).inset(20) // Sağ kenara olan boşluk
      make.centerY.equalTo(statusTextContainerView.snp.centerY) // Dikey olarak ortala
    }

    favoriteIcon.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(20)
      make.centerY.equalTo(typeText.snp.centerY)
    }

    typeText.snp.makeConstraints { make in
      make.top.equalTo(containerView.snp.bottom).offset(20)
      make.leading.equalToSuperview().inset(20)
    }

    typeLabel.snp.makeConstraints { make in
      make.leading.equalTo(typeText.snp.trailing).offset(2)
      make.centerY.equalTo(typeText.snp.centerY)
    }

    genderText.snp.makeConstraints { make in
      make.top.equalTo(typeText.snp.bottom).offset(42)
      make.leading.equalToSuperview().inset(20)
    }

    genderLabel.snp.makeConstraints { make in
      make.leading.equalTo(genderText.snp.trailing).offset(2)
      make.centerY.equalTo(genderText.snp.centerY)
    }

    originText.snp.makeConstraints { make in
      make.top.equalTo(genderText.snp.bottom).offset(42)
      make.leading.equalToSuperview().inset(20)
    }

    originLabel.snp.makeConstraints { make in
      make.leading.equalTo(originText.snp.trailing).offset(2)
      make.centerY.equalTo(originText.snp.centerY)
    }

    lastSeenText.snp.makeConstraints { make in
      make.top.equalTo(originText.snp.bottom).offset(42)
      make.leading.equalToSuperview().inset(20)
    }

    lastSeenLabel.snp.makeConstraints { make in
      make.leading.equalTo(lastSeenText.snp.trailing).offset(2)
      make.centerY.equalTo(lastSeenText.snp.centerY)
    }

    episodesText.snp.makeConstraints { make in
      make.top.equalTo(lastSeenText.snp.bottom).offset(42)
      make.leading.equalToSuperview().inset(20)
    }

    episodesLabel.snp.makeConstraints { make in
      make.leading.equalTo(episodesText.snp.trailing).offset(2)
      make.centerY.equalTo(episodesText.snp.centerY)
    }

    // Eğer viewModel'den imageUrl varsa, resmi yükle
    if let imageUrl = viewModel.imageUrl {
      activityIndicator.startAnimating()
      characterImageView.kf.setImage(with: imageUrl, options: [.forceRefresh], progressBlock: { receivedSize, totalSize in
      }) { [weak self] result in
        DispatchQueue.main.async {
          self?.activityIndicator.stopAnimating()
        }
      }
    } else {
      print("Geçersiz URL")
    }

    // Aktivite göstergesini imageView'a ekleyin
    characterImageView.addSubview(activityIndicator)
    activityIndicator.center = CGPoint(x: characterImageView.bounds.midX, y: characterImageView.bounds.midY)
  }
}
