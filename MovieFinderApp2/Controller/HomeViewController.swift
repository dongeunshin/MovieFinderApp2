//
//  HomeViewController.swift
//  MovieFinderApp2
//
//  Created by dong eun shin on 2022/01/23.
//
// 1. Indicator view ✅
// 2. search bar - 검색어 감당하는 것 -> 비동기적으로? operationqueue
// 3. detail view - webview ✅
// 4. almofire ✅
// 5. kingfisher ✅
// 6. 탭바로 구성? - 노노
// 7. userdefult 최근 검색어 -> 램으로 변경 ✅
//--------------------------------
// 8. snapKit ✅
// 9. 클린코드
// 10. 정규표현식 x -> replace
// 11. 날짜...
// 12. 서치바 비활성화, 키보드 ✅
import UIKit
import Alamofire
//import SwiftUI
import Kingfisher
import SafariServices

class HomeViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        
        view.addSubview(collectionView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])

        let quaryValues = ["Ironman", "avengers"]
        MovieDataSource.shared.fetch(quaryValues: quaryValues) { [self] in
            collectionView.reloadData()
            print("reload in Home")
        }
     }
    
    func setNavigationBar(){
        let searchBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchBtnPressed(_:)))
        self.navigationItem.rightBarButtonItem = searchBtn
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    @objc private func searchBtnPressed(_ sender: Any) {
        let vc = SearchViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            if sectionNumber == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: .estimated(200)), subitems: [item])
                group.contentInsets = .init(top: 0, leading: 5, bottom: 16, trailing: 5)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = .init(top: 0, leading: 16, bottom: 10, trailing: 16)
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
                item.contentInsets = .init(top: 0, leading: 5, bottom: 16, trailing: 5)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(200), heightDimension: .estimated(200)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous //스크롤 방식
                section.contentInsets = .init(top: 0, leading: 16, bottom: 10, trailing: 16)
                return section
            }
        }
    }

    func fetchMovie(queryValue: String, completion: @escaping (Result<Any,Error>) -> ()){
        let urlString = "https://openapi.naver.com/v1/search/movie.json?query=\(queryValue)"
        let headers: HTTPHeaders = [ "X-Naver-Client-Id": "k798N9BY5HzV05f0pRAG", "X-Naver-Client-Secret": "DC4QVuVKGs"]
        AF.request(urlString,headers: headers)
            .responseData { (response) in
                switch response.result{
                case let .success(data):
                    do {
                        let decoder = JSONDecoder()
                        let decodedData = try decoder.decode(MovieModel.self, from: data)
                        completion(.success(decodedData))
                    } catch {
                        completion(.failure(error))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
    }
}


extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let target = MovieDataSource.shared.loveMovieList[indexPath.row]
        let urlString = target.link
        if let url = URL(string: urlString) {
            let svc = SFSafariViewController(url: url)
            self.present(svc, animated: true, completion: nil)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MovieDataSource.shared.loveMovieList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as! MovieCollectionViewCell
        if indexPath.section == 0 {
            let target = MovieDataSource.shared.loveMovieList[indexPath.row]
            if let imageURL = URL(string: target.image) {
                cell.imageView.kf.setImage(with: imageURL)
            }
            cell.titleLabel.text = target.title
            cell.ratingLabel.text = target.userRating
        }else {
            let target = MovieDataSource.shared.heroMovieList[indexPath.row]
            if let imageURL = URL(string: target.image) {
                cell.imageView.kf.setImage(with: imageURL)
            }
            cell.titleLabel.text = target.title
            cell.ratingLabel.text = target.userRating
        }
        return cell
  }
}

// MARK: - canvas
//import SwiftUI
//struct PreView: PreviewProvider {
//    static var previews: some View {HomeViewController().toPreview()}
//}
//#if DEBUG
//extension UIViewController {
//    private struct Preview: UIViewControllerRepresentable {
//            let viewController: UIViewController
//            func makeUIViewController(context: Context) -> UIViewController {return viewController}
//            func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//        }
//        func toPreview() -> some View {Preview(viewController: self)}
//}
//#endif
//
//
