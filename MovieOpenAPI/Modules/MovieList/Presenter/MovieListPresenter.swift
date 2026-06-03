import Foundation
import UIKit

final class MovieListPresenter: MovieListViewOutput {
    weak var view: MovieListViewInput?

    private let interactor: MovieListInteractorInput
    private let router: MovieListRouterInput
    private var genrePresenter: GenrePresenterInput?
    private var selectedGenre: Genre?
    private var currentQuery: String = ""
    private var movies: [Movie] = []

    init(view: MovieListViewInput, interactor: MovieListInteractorInput, router: MovieListRouterInput) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func setGenrePresenter(_ genrePresenter: GenrePresenterInput) {
        self.genrePresenter = genrePresenter
    }

    func viewDidLoad() {
        genrePresenter?.loadGenres()
    }

    func didUpdateSearchText(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        currentQuery = trimmedText
        if trimmedText.isEmpty {
            interactor.loadMovies(genreId: selectedGenre?.id, query: "", reset: true)
        } else if trimmedText.count >= 3 {
            interactor.loadMovies(genreId: selectedGenre?.id, query: trimmedText, reset: true)
        }
    }

    func didSelectGenre(at index: Int) {
        genrePresenter?.selectGenre(at: index)
    }

    func didSelectMovie(at index: Int) {
        guard movies.indices.contains(index) else { return }
        guard let viewController = view as? UIViewController else { return }
        router.navigateToMovieDetail(from: viewController, movie: movies[index])
    }

    func didScrollToItem(at index: Int) {
        interactor.loadNextPageIfNeeded(currentIndex: index)
    }
}

extension MovieListPresenter: GenrePresenterOutput {
    func genrePresenterDidStartLoading(_ presenter: GenrePresenterInput) {
        view?.displayLoading(isFirstPage: true)
    }

    func genrePresenter(_ presenter: GenrePresenterInput, didUpdate genres: [GenreDisplayItem], selectedGenre: Genre?) {
        self.selectedGenre = selectedGenre
        view?.displayGenres(genres)
        interactor.loadMovies(genreId: selectedGenre?.id, query: currentQuery, reset: true)
    }

    func genrePresenter(_ presenter: GenrePresenterInput, didFailWith message: String) {
        view?.displayError(message)
    }
}

extension MovieListPresenter: MovieListInteractorOutput {
    func movieListInteractorDidStartLoading(_ interactor: MovieListInteractorInput, isFirstPage: Bool) {
        view?.displayLoading(isFirstPage: isFirstPage)
    }

    func movieListInteractor(_ interactor: MovieListInteractorInput, didLoad movies: [Movie], append: Bool) {
        self.movies = movies
        let displayItems = movies.map { movie in
            MovieRowDisplayItem(
                id: movie.id,
                title: movie.title,
                posterURL: movie.posterPath.flatMap { URL(string: APIConfig.imageBaseURL + $0) }
            )
        }
        view?.displayMovies(displayItems)
    }

    func movieListInteractorDidLoadEmptyMovies(_ interactor: MovieListInteractorInput) {
        movies = []
        view?.displayEmptyState("No movies found")
    }

    func movieListInteractor(_ interactor: MovieListInteractorInput, didFailWith message: String) {
        view?.displayError(message)
    }
}
