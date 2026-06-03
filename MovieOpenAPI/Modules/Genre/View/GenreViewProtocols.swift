//
//  GenreViewProtocols.swift
//  MovieOpenAPI
//

import Foundation

protocol GenreViewInput: AnyObject {
    func displayGenres(_ genres: [GenreDisplayItem])
}
