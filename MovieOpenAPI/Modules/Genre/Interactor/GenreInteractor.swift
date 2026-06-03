//
//  GenreInteractor.swift
//  MovieOpenAPI
//

import Foundation
import Combine

protocol GenreInteractorInput: AnyObject {
    func fetchGenres()
}

protocol GenreInteractorOutput: AnyObject {
    func genreInteractor(_ interactor: GenreInteractorInput, didLoad genres: [Genre])
    func genreInteractor(_ interactor: GenreInteractorInput, didFailWith message: String)
}

final class GenreInteractor: GenreInteractorInput {
    weak var output: GenreInteractorOutput?
    
    private let service: MovieServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(service: MovieServiceProtocol) {
        self.service = service
    }
    
    func fetchGenres() {
        service.fetchGenres()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.output?.genreInteractor(self, didFailWith: error.localizedDescription)
                }
            }, receiveValue: { [weak self] genres in
                guard let self else { return }
                self.output?.genreInteractor(self, didLoad: genres)
            })
            .store(in: &cancellables)
    }
}
