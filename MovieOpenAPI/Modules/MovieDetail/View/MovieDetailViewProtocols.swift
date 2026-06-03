import Foundation

protocol MovieDetailViewInput: AnyObject {
    func displayLoading()
    func displayMovie(_ item: MovieDetailDisplayItem)
    func displayTrailer(url: URL?)
    func displayReviews(_ reviews: [ReviewDisplayItem])
    func displayEmptyReviews()
    func displayError(_ message: String)
}

protocol MovieDetailViewOutput: AnyObject {
    func viewDidLoad()
    func didScrollToReview(at index: Int)
}
