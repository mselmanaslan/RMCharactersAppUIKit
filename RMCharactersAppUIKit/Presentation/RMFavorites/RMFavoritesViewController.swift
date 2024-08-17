//
//  RMFavoritesViewController.swift
//  RMCharactersAppUIKit
//
//  Created by Selman Aslan on 19.03.2024.
//

import UIKit
import SnapKit

final class RMFavoritesViewController: UIViewController {
  private let viewModel = RMFavoritesViewModel()
  private var filterMenuHeightConstraint: Constraint?
  private var filterButtonHeightConstraint: Constraint?
  private var containerView: UIView!
  private lazy var characterTableView: CharacterTableView = {
    let view = CharacterTableView(viewModel: viewModel.characterTableViewModel)
    return view
  }()

  private lazy var emptyStateText: UILabel = {
    let label = UILabel()
    label.text = "It looks like you haven't added\nany favorite characters yet."
    label.textAlignment = .center
    label.textColor = .gray
    label.numberOfLines = 0
    label.isHidden = true // Başlangıçta gizli olacak
    label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    return label
  }()

  private lazy var emptyStateTitle: UILabel = {
    let label = UILabel()
    label.text = "Oops..."
    label.textAlignment = .center
    label.textColor = .gray
    label.numberOfLines = 0
    label.isHidden = true // Başlangıçta gizli olacak
    label.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
    return label
  }()

  private lazy var headerView: HeaderView = {
    let view = HeaderView(title: "Favorited\nCharacters")
    return view
  }()

  private lazy var filterMenuView: FilterMenuView = {
    let view = FilterMenuView(viewModel: viewModel.filterViewModel)
    return view
  }()

  private lazy var filterButtons: FilterButtonsView = {
    let view = FilterButtonsView(viewModel: viewModel.filterViewModel)
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.setNavigationBarHidden(true, animated: false)
    setupUI()
    viewModel.filteredCharacters = viewModel.dbCharacters
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.fetchFavoriteCharacters()
    viewModel.applyFilterToCharacters()
    characterTableView.viewModel.characters = viewModel.filteredCharacters
    characterTableView.reloadTable()
    print("favorites did appear")
  }

  private func setupUI() {
    containerView = UIView()
    view.addSubview(containerView)
    view.addSubview(headerView)
    view.addSubview(characterTableView)
    view.addSubview(emptyStateText)
    view.addSubview(emptyStateTitle)
    emptyStateText.snp.makeConstraints { make in
      make.centerX.equalTo(characterTableView)
      make.centerY.equalTo(characterTableView).offset(-50)
      make.leading.trailing.equalTo(characterTableView).inset(20)
    }

    emptyStateTitle.snp.makeConstraints { make in
      make.centerX.equalTo(emptyStateText)
      make.centerY.equalTo(emptyStateText.snp.top).offset(-15)
      make.leading.trailing.equalTo(characterTableView).inset(20)
    }

    containerView.snp.makeConstraints { make in
      make.top.equalTo(headerView.snp.bottom)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      filterButtonHeightConstraint = make.height.equalTo(30).constraint
    }

    containerView.addSubview(filterMenuView)
    containerView.addSubview(filterButtons)
    filterMenuView.isHidden = true

    filterMenuView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(280)
    }

    filterButtons.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(30)
    }

    headerView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(60)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }

    characterTableView.snp.makeConstraints { make in
      make.top.equalTo(containerView.snp.bottom)
      make.leading.trailing.bottom.equalToSuperview()
    }

    viewModel.onCharacterDetailsOpened = {
      self.toggleDetailsView()
    }

    characterTableView.viewModel.addNewCharacters = { [weak self] in
        guard let self else { return }
      self.characterTableView.viewModel.characters = self.viewModel.filteredCharacters
        self.characterTableView.reloadTable()
    }

    viewModel.onFilterChange = { [weak self] in
        guard let self else { return }
      self.characterTableView.viewModel.isFilterChanged = self.viewModel.isWaiting
      self.filterButtons.viewModel.filter = (self.viewModel.filter)
      self.filterMenuView.viewModel.filter = (self.viewModel.filter)
        self.characterTableView.reloadTable()
    }

    headerView.onFilterButtonTapped = {
      self.toggleFilterMenu()
    }

    viewModel.isCharacterListEmpty = { [weak self] isEmpty in
      print("characterlist degisti")
      print(self?.viewModel.filteredCharacters.count ?? 0)
      if isEmpty {
        self?.emptyStateText.isHidden = false
        self?.emptyStateTitle.isHidden = false
        self?.characterTableView.isHidden = true
      } else {
        self?.emptyStateText.isHidden = true
        self?.emptyStateTitle.isHidden = true
        self?.characterTableView.isHidden = false
      }
    }
  }

  private func toggleFilterMenu() {
    viewModel.isFilterMenuOpen.toggle()
    filterMenuView.isHidden = !viewModel.isFilterMenuOpen
    filterButtons.isHidden = viewModel.isFilterMenuOpen
    let newFilterHeight: CGFloat = viewModel.isFilterMenuOpen ? 280 : 30
    UIView.animate(withDuration: 0.3) {
      self.filterButtonHeightConstraint?.update(offset: newFilterHeight)
      self.view.layoutIfNeeded()
    }
  }

  private func toggleDetailsView() {
    let detailsVC = CHDetailsViewController( viewModel: CHDetailsViewModel(character: viewModel.selectedCharacter!))
    let navController = UINavigationController(rootViewController: detailsVC)
    navController.modalPresentationStyle = .pageSheet
    detailsVC.dismissSheet = {
      self.viewDidAppear(true)
    }
    present(navController, animated: true, completion: nil)
  }
}
