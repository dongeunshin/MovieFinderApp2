//
//  MovieDataSource.swift
//  MovieFinderApp2
//
//  Created by dong eun shin on 2022/01/26.
//

import Foundation
class MovieDataSource {
    
    static let shared: MovieDataSource = MovieDataSource()
    let clientID = "k798N9BY5HzV05f0pRAG"
    let clientSecret = "DC4QVuVKGs"
    private init() {}
    
    var loveMovieList: [Item] = []
    var heroMovieList: [Item] = []
    
    let apiQueue = DispatchQueue(label: "ApiQueue", attributes: .concurrent)
    
    let group = DispatchGroup()
    
    func fetch(quaryValues: [String], completion:  @escaping () -> ()) {
//        for i in 0..<quaryValues.count{
//            group.enter()
//            apiQueue.async {
//                self.fetchMovie(queryValue: quaryValues[i]) { (result) in
//                    switch result {
//                    case .success(let data):
//                        if let decodedData = data as? MovieModel {
//                            self.loveMovieList = decodedData.items
//                        }
//                    default:
//                        self.loveMovieList = []
//                    }
//                    self.group.leave()
//                }
//            }
//
//        }
        group.enter()
        apiQueue.async {
            self.fetchMovie(queryValue: quaryValues[0]) { (result) in
                switch result {
                case .success(let data):
                    if let decodedData = data as? MovieModel {
                        self.loveMovieList = decodedData.items
                    }
                default:
                    self.loveMovieList = []
                }
                self.group.leave()
            }
        }
        group.enter()
        apiQueue.async {
            self.fetchMovie(queryValue: quaryValues[1]) { (result) in
                switch result {
                case .success(let data):
                    if let decodedData = data as? MovieModel {
                        self.heroMovieList = decodedData.items
                    }
                default:
                    self.loveMovieList = []
                }
                self.group.leave()
            }
        }
        group.notify(queue: .main) {
            completion()
        }
    }
    
}
extension MovieDataSource{
    private func fetchMovie(queryValue: String , completion: @escaping (Result<Any, Error>) -> ()){
        
        let urlString = "https://openapi.naver.com/v1/search/movie.json?query=\(queryValue)"
        
        guard let url = URL(string: urlString) else { return }
        
        var requestURl = URLRequest(url: url)
        requestURl.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        requestURl.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: requestURl) { data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
                        
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(MovieModel.self, from: data)
                completion(.success(data))
            }catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
