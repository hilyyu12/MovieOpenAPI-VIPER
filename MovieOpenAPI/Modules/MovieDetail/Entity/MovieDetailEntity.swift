import Foundation

struct MovieDetailDisplayItem: Equatable {
    let title: String
    let ratingText: String
    let overviewText: String
    let posterURL: URL?
}

struct ReviewDisplayItem: Equatable {
    let id: String
    let author: String
    let content: String
}
