import UIKit

enum MovieDetailRouter {
    static func makeModule(movie: Movie, service: MovieServiceProtocol) -> UIViewController {
        let view = MovieDetailVC()
        let interactor = MovieDetailInteractor(movie: movie, service: service)
        let presenter = MovieDetailPresenter(view: view, interactor: interactor, movie: movie)
        interactor.output = presenter
        view.presenter = presenter
        return view
    }
}
