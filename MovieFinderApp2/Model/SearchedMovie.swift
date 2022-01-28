//
//  SearchedMovie.swift
//  MovieFinderApp2
//
//  Created by dong eun shin on 2022/01/26.
//

import Foundation
import RealmSwift

class  SearchedMovie: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var link: String = ""
}
