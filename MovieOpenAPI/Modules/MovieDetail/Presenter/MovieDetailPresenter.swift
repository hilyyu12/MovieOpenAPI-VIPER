import Foundation


final class MovieDetailPresenter: MovieDetailViewOutput {
    private weak var view: MovieDetailViewInput?
    private let interactor: MovieDetailInteractorInput
    private let movie: Movie
    private var reviewItems: [ReviewDisplayItem] = []

    init(view: MovieDetailViewInput, interactor: MovieDetailInteractorInput, movie: Movie) {
        self.view = view
        self.interactor = interactor
        self.movie = movie
    }

    func viewDidLoad() {
        view?.displayMovie(makeMovieDisplayItem())
        interactor.loadInitialData()
    }

    func didScrollToReview(at index: Int) {
        interactor.loadNextReviewPageIfNeeded(currentIndex: index)
    }

    private func makeMovieDisplayItem() -> MovieDetailDisplayItem {
        MovieDetailDisplayItem(
            title: movie.title,
            ratingText: String(format: "Rating %.1f/10", movie.voteAverage),
            overviewText: movie.overview?.isEmpty == false ? movie.overview! : "No overview available",
            posterURL: movie.posterPath.flatMap { URL(string: APIConfig.imageBaseURL + $0) }
        )
    }

    private func makeReviewItems(from reviews: [Review]) -> [ReviewDisplayItem] {
        reviews.map { ReviewDisplayItem(id: $0.id, author: $0.author, content: $0.content) }
    }
}

extension MovieDetailPresenter: MovieDetailInteractorOutput {
    func movieDetailInteractorDidStartLoading(_ interactor: MovieDetailInteractorInput) {
        view?.displayLoading()
    }

    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didLoadTrailerURL url: URL?) {
        view?.displayTrailer(url: url)
    }

    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didLoadReviews reviews: [Review], append: Bool) {
        reviewItems = makeReviewItems(from: reviews)
        view?.displayReviews(reviewItems)
    }

    func movieDetailInteractorDidLoadEmptyReviews(_ interactor: MovieDetailInteractorInput) {
        reviewItems = []
        view?.displayEmptyReviews()
    }

    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didFailWith message: String) {
        view?.displayError(message)
    }
}
