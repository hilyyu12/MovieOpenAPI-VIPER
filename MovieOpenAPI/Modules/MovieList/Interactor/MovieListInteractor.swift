import Foundation
import Combine

protocol MovieListInteractorInput: AnyObject {
    func loadMovies(genreId: Int?, query: String?, reset: Bool)
    func loadNextPageIfNeeded(currentIndex: Int)
}

protocol MovieListInteractorOutput: AnyObject {
    func movieListInteractorDidStartLoading(_ interactor: MovieListInteractorInput, isFirstPage: Bool)
    func movieListInteractor(_ interactor: MovieListInteractorInput, didLoad movies: [Movie], append: Bool)
    func movieListInteractorDidLoadEmptyMovies(_ interactor: MovieListInteractorInput)
    func movieListInteractor(_ interactor: MovieListInteractorInput, didFailWith message: String)
}

final class MovieListInteractor: MovieListInteractorInput {
    weak var output: MovieListInteractorOutput?

    private let service: MovieServiceProtocol
    private var currentGenreId: Int?
    private var currentQuery: String = ""
    private var currentPage = 0
    private var totalPages = 1
    private var isLoading = false
    private var currentMovies: [Movie] = []
    private var movieRequestCancellable: AnyCancellable?

    init(service: MovieServiceProtocol) {
        self.service = service
    }

    func loadMovies(genreId: Int?, query: String?, reset: Bool) {
        let normalizedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if reset || currentGenreId != genreId || currentQuery != normalizedQuery {
            currentGenreId = genreId
            currentQuery = normalizedQuery
            currentPage = 0
            totalPages = 1
            currentMovies = []
            movieRequestCancellable?.cancel()
        }

        guard !isLoading else { return }
        guard currentGenreId != nil || !currentQuery.isEmpty else {
            output?.movieListInteractorDidLoadEmptyMovies(self)
            return
        }

        guard currentPage < totalPages else { return }

        let nextPage = currentPage + 1
        isLoading = true
        output?.movieListInteractorDidStartLoading(self, isFirstPage: reset)

        let request: AnyPublisher<MovieResponse, Error>
        if currentQuery.isEmpty {
            request = service.discoverMovies(genreId: currentGenreId!, page: nextPage)
        } else {
            request = service.searchMovie(query: currentQuery, page: nextPage)
        }

        movieRequestCancellable = request
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.output?.movieListInteractor(self, didFailWith: error.localizedDescription)
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.currentPage = response.page
                self.totalPages = max(response.totalPages, response.page)
                self.currentMovies.append(contentsOf: response.results)

                if self.currentMovies.isEmpty {
                    self.output?.movieListInteractorDidLoadEmptyMovies(self)
                } else {
                    self.output?.movieListInteractor(self, didLoad: self.currentMovies, append: nextPage > 1)
                }
            })
    }

    func loadNextPageIfNeeded(currentIndex: Int) {
        guard currentIndex >= currentMovies.count - 4 else { return }
        loadMovies(genreId: currentGenreId, query: currentQuery, reset: false)
    }
}
