//
//  MovieModel.swift
//  MovieFinderApp2
//
//  Created by dong eun shin on 2022/01/25.
//

import Foundation

struct MovieModel: Codable {
    let items: [Item]
}

struct Item: Codable {
    let title: String
    let link: String
    let image: String
    let subtitle, pubDate, director, actor: String
    let userRating: String
}
