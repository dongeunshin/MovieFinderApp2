//
//  MovieTableViewCell.swift
//  MovieFinderApp2
//
//  Created by dong eun shin on 2022/01/26.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    static let identifier = "MovieTableViewCell"
    
    let movieImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let movieNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let actorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addContentView()
        setConstraints()
        selectionStyle = .none
    }
    
    private func addContentView() {
        contentView.addSubview(movieImage)
        contentView.addSubview(movieNameLabel)
        contentView.addSubview(actorLabel)
    }
    
    private func setConstraints() {
        let margin: CGFloat = 10
        NSLayoutConstraint.activate([
            movieImage.topAnchor.constraint(equalTo: self.topAnchor),
            movieImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            movieImage.widthAnchor.constraint(equalToConstant: 100),
            movieImage.heightAnchor.constraint(equalToConstant: 100),
            
            movieNameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            movieNameLabel.leadingAnchor.constraint(equalTo: movieImage.trailingAnchor, constant: margin),
            movieNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            actorLabel.topAnchor.constraint(equalTo: movieNameLabel.bottomAnchor),
            actorLabel.leadingAnchor.constraint(equalTo: movieImage.trailingAnchor, constant: margin),
            actorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            actorLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            actorLabel.heightAnchor.constraint(equalTo: movieNameLabel.heightAnchor),
            ])
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
