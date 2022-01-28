//
//  SearchViewController.swift
//  MovieFinderApp2
//
//  Created by dong eun shin on 2022/01/23.
//
import UIKit
import Alamofire
import SafariServices
import RealmSwift
import Kingfisher

class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate{

//    var notificationToken: NotificationToken?
    
    let realm = try! Realm()
    lazy var searchedMovie : Results<SearchedMovie> = {
        let result: Results<SearchedMovie>
        result = self.realm.objects(SearchedMovie.self) //.sorted(byKeyPath: <#T##String#>, ascending: false )
        return result
    }()
    
    var movieList : [Item] = []
    
    let RecentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "최근 검색어"
        return label
    }()

    let searchTableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.rowHeight = 100
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    let historyTableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.identifier)
        tableView.rowHeight = 50
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let searchController = UISearchController(searchResultsController: nil) // 왜 안에서는 안되는지..
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "어떤 영화를 찾으시나요?"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.showsSearchResultsController = true
        searchController.searchBar.showsCancelButton = false
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.dataSource = self
        view.addSubview(searchTableView)
        view.addSubview(historyTableView)
        view.addSubview(RecentLabel)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            RecentLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            RecentLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            RecentLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            historyTableView.topAnchor.constraint(equalTo: RecentLabel.bottomAnchor),
            historyTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            historyTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            historyTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }
    @objc private func touchesTableView(_ sender: UISwipeGestureRecognizer){
         print("SWIPE!!!!!!!")
         self.view.endEditing(true)
   }
    func fetchMovie(queryValue: String){
        let urlString = "https://openapi.naver.com/v1/search/movie.json?query=\(queryValue)"
        let headers: HTTPHeaders = [ "X-Naver-Client-Id": "k798N9BY5HzV05f0pRAG", "X-Naver-Client-Secret": "DC4QVuVKGs"]
        AF.request(urlString, headers: headers)
            .responseData { (response) in
                switch response.result{
                case let .success(data):
                    do {
                        let decoder = JSONDecoder()
                        let decodedData = try decoder.decode(MovieModel.self, from: data)
//                        completion(.success(decodedData))
                        self.movieList = decodedData.items
                        DispatchQueue.main.async {
                            self.searchTableView.reloadData()
                        }
                    } catch {
                        print(self.movieList)
                    }
                case let .failure(error):
                    print(error)
                }
            }
    }
    
}
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView{
            return movieList.count
        }else if tableView == historyTableView{
            return searchedMovie.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchTableView{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else { return UITableViewCell()}
            let target = movieList[indexPath.row]
            if let imageURL = URL(string: target.image) {
                cell.movieImage.kf.indicatorType = .activity
                cell.movieImage.kf.setImage(with: imageURL)
            }
            cell.movieNameLabel.text = target.title
            return cell
        }else if tableView == historyTableView{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as? HistoryTableViewCell else { return UITableViewCell()}
            cell.movieNameLabel.text = searchedMovie[indexPath.row].title //여기서 거꾸로
            let deleteBtn = UIButton(type: .close, primaryAction: UIAction(handler: { [self] _ in
                do {
                    try self.realm.write {
                        self.realm.delete(self.searchedMovie[indexPath.row])
                        print(searchedMovie)
                    }
                } catch {
                    print("Delete Error")
                }
                self.historyTableView.reloadData()
            }))
            cell.accessoryView = deleteBtn
            return cell
        }
        return UITableViewCell()
    }
}
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var linkURL = ""
        if tableView == searchTableView{
            let target = movieList[indexPath.row]
            //realm에 없을때
            if realm.objects(SearchedMovie.self).filter("title = '\(target.title)'").count == 0 { // 삭제하고 ㅊ
                let newMovie = SearchedMovie()
                newMovie.title =  target.title
                newMovie.link = target.link
                do{
                    try realm.write{ realm.add(newMovie) }
                } catch {
                    print("Error: \(error)")
                }
            }
            linkURL = movieList[indexPath.row].link
        }else{ // historyTableView
            linkURL = searchedMovie[indexPath.row].link
        }
        if let url = URL(string: linkURL) {
            let svc = SFSafariViewController(url: url)
            self.present(svc, animated: true, completion: nil)
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {

    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false

    }
    func updateSearchResults(for searchController: UISearchController) {
        if ((searchController.searchBar.text?.isEmpty) == true){
            self.searchTableView.isHidden = true
            
            self.historyTableView.isHidden = false
            self.RecentLabel.isHidden = false
            self.historyTableView.reloadData()
        }
        else if let searchText = searchController.searchBar.text {
            self.historyTableView.isHidden = true
            self.RecentLabel.isHidden = true
            
            self.searchTableView.isHidden = false
            fetchMovie(queryValue: searchText)
        }
    }
}
extension UIImageView {
    
    func setImage(with urlString: String) {
        let cache = ImageCache.default
        cache.retrieveImage(forKey: urlString, options: nil) { result in
                  switch result {
                  case .success(let value):
                    if let image = value.image {
                      //캐시가 존재하는 경우
                      self.image = image
                    } else {
                      //캐시가 존재하지 않는 경우
                      guard let url = URL(string: urlString) else { return }
                      let resource = ImageResource(downloadURL: url, cacheKey: urlString)
                      self.kf.setImage(with: resource)
                    }
                  case .failure(let error):
                    print(error)
                  }
        }
    }
    
}
//        notificationToken = searchedMovie.observe { [unowned self] changes in
//                    switch changes {
//                    case .initial(let users):
//                        print("Initial count: \(users.count)")
//                        self.historyTableView.reloadData()
//                    case .update(let users, let deletions, let insertions, let modifications):
//                        if deletions.count > 0 {
//                            print("delete object.")
////                            print(searchedMovie)
////                            historyTableView.beginUpdates()
////                            let indexPaths = insertions.map {
////                                IndexPath(item: $0, section: 0)
////
////                            }
////                            historyTableView.deleteRows(at: indexPaths, with: .automatic)
////                            historyTableView.reloadData()
////                            historyTableView.endUpdates()
//                        }
//                    case .error(let error):
//                        fatalError("\(error)")
//                    }
//        }
//
//        do{
//            try self.realm.write {
//                realm.deleteAll()
//                print(searchedMovie)
//            }
//        }catch{
//            print("err")
//        }



//private func SetnotiToken(){
//        Datas = realm.objects(SearchHistory.self)
//        notiToken = Datas?.observe { [weak self] change in
//            switch change {
//            case .initial(_):
//                self?.tableView.reloadData()
//            case .error(let error):
//                fatalError("\(error)")
//            case .update(_, deletions: _, insertions: _, modifications: _):
//                self?.tableView.reloadData()
//            }
//        }
//    }
