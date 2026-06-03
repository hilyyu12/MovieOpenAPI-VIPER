import UIKit

protocol MovieListRouterInput: AnyObject {
    func navigateToMovieDetail(from view: UIViewController, movie: Movie)
}

final class MovieListRouter: MovieListRouterInput {
    private let service: MovieServiceProtocol

    init(service: MovieServiceProtocol) {
        self.service = service
    }

    static func makeModule(service: MovieServiceProtocol) -> UIViewController {
        let view = ListPopularVC(nibName: "ListPopularVC", bundle: nil)
        let interactor = MovieListInteractor(service: service)
        let router = MovieListRouter(service: service)
        let presenter = MovieListPresenter(view: view, interactor: interactor, router: router)
        let genrePresenter = GenreRouter.makePresenter(service: service, output: presenter)
        presenter.setGenrePresenter(genrePresenter)
        view.presenter = presenter
        interactor.output = presenter
        return view
    }

    func navigateToMovieDetail(from view: UIViewController, movie: Movie) {
        let detailVC = MovieDetailRouter.makeModule(movie: movie, service: service)
        view.navigationController?.pushViewController(detailVC, animated: true)
    }
}
