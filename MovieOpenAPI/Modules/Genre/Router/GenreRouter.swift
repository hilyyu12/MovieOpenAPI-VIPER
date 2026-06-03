//
//  GenreRouter.swift
//  MovieOpenAPI
//

import Foundation

enum GenreRouter {
    static func makePresenter(
        service: MovieServiceProtocol,
        output: GenrePresenterOutput
    ) -> GenrePresenterInput {
        let interactor = GenreInteractor(service: service)
        let presenter = GenrePresenter(interactor: interactor)
        interactor.output = presenter
        presenter.output = output
        return presenter
    }
}
