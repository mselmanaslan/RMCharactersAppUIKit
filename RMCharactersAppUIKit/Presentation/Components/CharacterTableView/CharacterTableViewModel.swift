//
//  CharcterTableViewModel.swift
//  RMCharactersAppUIKit
//
//  Created by Selman Aslan on 20.03.2024.
//

import Foundation
import Combine

class CharacterTableViewModel {
  var isItFavoritesTable: Bool
  var onEndReached: (() -> Void)?
  var dataFetched: (() -> Void)?
  var onFilterChange: (() -> Void)?
  var addNewCharacters: (() -> Void)?
  var toggledFavorite: (() -> Void)?
  var removedCharacter: ((AdaptedCharacter) -> Void)?
  var isFilteredCharactersEmpty: ((Bool) -> Void)?
  var onCharacterDetailsButtonTapped: (AdaptedCharacter) -> Void
  var isFetching = false
  var isFilterChanged: Bool {
    didSet {
      if isFilterChanged {
        // delete table characters
        onFilterChange?()
      } else {
        // add new characters
        print("addnewcharacters")
        addNewCharacters?()
        if(characters.isEmpty) {
          isFilteredCharactersEmpty?(true)
        } else {
          isFilteredCharactersEmpty?(false)
        }
      }
    }
  }

  var oldCharacters: [AdaptedCharacter] = []
    var cancellables: Set<AnyCancellable> = []
  @Published var characters: [AdaptedCharacter] = []

  init(isFilterChanged: Bool,
       characters: [AdaptedCharacter],
       isItFavoritesTable: Bool,
       onCharacterDetailsButtonTapped: @escaping (AdaptedCharacter) -> Void,
       removedCharacter: @escaping (AdaptedCharacter) -> Void
       ) {
      self.characters = characters
      self.isFilterChanged = isFilterChanged
      self.isItFavoritesTable = isItFavoritesTable
      self.onCharacterDetailsButtonTapped = onCharacterDetailsButtonTapped
      self.removedCharacter = removedCharacter
      
      $characters
          .first()
          .sink { [weak self] characters in
              if isFilterChanged {
                  self?.oldCharacters = characters
              } else {
                  self?.oldCharacters = []
              }
              self?.isFetching = false
              if !isItFavoritesTable {
                  self?.dataFetched?()
              }
          }
          .store(in: &cancellables)
  }

  func viewModelForRow(at indexPath: IndexPath) -> CharacterCellViewModel {
    let character = characters[indexPath.row]
    return CharacterCellViewModel(character: character,
                                  onFavoriteButtonTapped: {},
                                  onCharacterDetailsButtonTapped: { _ in }
    )
  }

  func checkForEndOfList(indexPath: IndexPath) {
    let endOfList = indexPath.row == characters.count - 1 && !isFetching
    if endOfList {
      isFetching = true
      onEndReached?()
    } else {
      return
    }
  }
}
