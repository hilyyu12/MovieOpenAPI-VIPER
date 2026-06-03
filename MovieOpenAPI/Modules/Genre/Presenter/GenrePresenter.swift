//
//  GenrePresenter.swift
//  MovieOpenAPI
//

import Foundation

protocol GenrePresenterInput: AnyObject {
    var selectedGenre: Genre? { get }
    func loadGenres()
    func selectGenre(at index: Int)
}

protocol GenrePresenterOutput: AnyObject {
    func genrePresenterDidStartLoading(_ presenter: GenrePresenterInput)
    func genrePresenter(_ presenter: GenrePresenterInput, didUpdate genres: [GenreDisplayItem], selectedGenre: Genre?)
    func genrePresenter(_ presenter: GenrePresenterInput, didFailWith message: String)
}

final class GenrePresenter: GenrePresenterInput {
    weak var output: GenrePresenterOutput?
    
    private let interactor: GenreInteractorInput
    private var genres: [Genre] = []
    private(set) var selectedGenre: Genre?
    
    init(interactor: GenreInteractorInput) {
        self.interactor = interactor
    }
    
    func loadGenres() {
        output?.genrePresenterDidStartLoading(self)
        interactor.fetchGenres()
    }
    
    func selectGenre(at index: Int) {
        guard genres.indices.contains(index) else { return }
        let genre = genres[index]
        guard selectedGenre != genre else { return }
        selectedGenre = genre
        output?.genrePresenter(self, didUpdate: makeDisplayItems(), selectedGenre: selectedGenre)
    }
    
    private func makeDisplayItems() -> [GenreDisplayItem] {
        genres.map {
            GenreDisplayItem(id: $0.id, name: $0.name, isSelected: $0 == selectedGenre)
        }
    }
}

extension GenrePresenter: GenreInteractorOutput {
    func genreInteractor(_ interactor: GenreInteractorInput, didLoad genres: [Genre]) {
        self.genres = genres
        selectedGenre = genres.first
        output?.genrePresenter(self, didUpdate: makeDisplayItems(), selectedGenre: selectedGenre)
    }
    
    func genreInteractor(_ interactor: GenreInteractorInput, didFailWith message: String) {
        output?.genrePresenter(self, didFailWith: message)
    }
}
