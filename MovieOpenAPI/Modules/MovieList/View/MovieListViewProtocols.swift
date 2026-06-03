import Foundation

protocol MovieListViewInput: AnyObject {
    func displayLoading(isFirstPage: Bool)
    func displayMovies(_ movies: [MovieRowDisplayItem])
    func displayGenres(_ genres: [GenreDisplayItem])
    func displayEmptyState(_ message: String)
    func displayError(_ message: String)
}

protocol MovieListViewOutput: AnyObject {
    func viewDidLoad()
    func didUpdateSearchText(_ text: String)
    func didSelectGenre(at index: Int)
    func didSelectMovie(at index: Int)
    func didScrollToItem(at index: Int)
}
