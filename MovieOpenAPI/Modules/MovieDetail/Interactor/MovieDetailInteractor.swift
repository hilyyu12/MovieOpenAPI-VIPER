import Foundation
import Combine

protocol MovieDetailInteractorInput: AnyObject {
    func loadInitialData()
    func loadNextReviewPageIfNeeded(currentIndex: Int)
}

protocol MovieDetailInteractorOutput: AnyObject {
    func movieDetailInteractorDidStartLoading(_ interactor: MovieDetailInteractorInput)
    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didLoadTrailerURL url: URL?)
    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didLoadReviews reviews: [Review], append: Bool)
    func movieDetailInteractorDidLoadEmptyReviews(_ interactor: MovieDetailInteractorInput)
    func movieDetailInteractor(_ interactor: MovieDetailInteractorInput, didFailWith message: String)
}

final class MovieDetailInteractor: MovieDetailInteractorInput {
    weak var output: MovieDetailInteractorOutput?

    private let movie: Movie
    private let service: MovieServiceProtocol
    private var currentReviewPage = 0
    private var totalReviewPages = 1
    private var isLoadingReviews = false
    private var reviews: [Review] = []
    private var trailerRequestCancellable: AnyCancellable?
    private var reviewRequestCancellable: AnyCancellable?

    init(movie: Movie, service: MovieServiceProtocol) {
        self.movie = movie
        self.service = service
    }

    func loadInitialData() {
        output?.movieDetailInteractorDidStartLoading(self)
        loadTrailer()
        loadReviews(reset: true)
    }

    func loadNextReviewPageIfNeeded(currentIndex: Int) {
        guard currentIndex >= reviews.count - 2 else { return }
        loadReviews(reset: false)
    }

    private func loadTrailer() {
        trailerRequestCancellable = service.fetchVideos(movieId: movie.id)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.output?.movieDetailInteractor(self, didFailWith: error.localizedDescription)
                }
            }, receiveValue: { [weak self] videos in
                guard let self = self else { return }
                let trailer = videos.first {
                    $0.site.lowercased() == "youtube" && $0.type.lowercased() == "trailer"
                } ?? videos.first {
                    $0.site.lowercased() == "youtube"
                }
                let url = trailer.flatMap { URL(string: "https://www.youtube.com/watch?v=\($0.key)&playsinline=1") }
                self.output?.movieDetailInteractor(self, didLoadTrailerURL: url)
            })
    }

    private func loadReviews(reset: Bool) {
        if reset {
            reviews = []
            currentReviewPage = 0
            totalReviewPages = 1
            output?.movieDetailInteractorDidStartLoading(self)
        }

        guard !isLoadingReviews, currentReviewPage < totalReviewPages else { return }

        isLoadingReviews = true
        let nextPage = currentReviewPage + 1

        reviewRequestCancellable = service.fetchReviews(movieId: movie.id, page: nextPage)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingReviews = false
                if case .failure(let error) = completion {
                    self.output?.movieDetailInteractor(self, didFailWith: error.localizedDescription)
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                self.currentReviewPage = response.page
                self.totalReviewPages = max(response.totalPages, response.page)
                self.reviews.append(contentsOf: response.results)

                if self.reviews.isEmpty {
                    self.output?.movieDetailInteractorDidLoadEmptyReviews(self)
                } else {
                    self.output?.movieDetailInteractor(self, didLoadReviews: self.reviews, append: nextPage > 1)
                }
            })
    }
}
