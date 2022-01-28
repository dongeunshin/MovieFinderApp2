//
//  HistoryTableViewCell.swift
//  MovieFinderApp2
//
//  Created by dong eun shin on 2022/01/26.
//

import UIKit
import SnapKit

class HistoryTableViewCell: UITableViewCell {
    static let identifier = "HistoryTableViewCell"
    
    let movieNameLabel: UILabel = {
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
        contentView.addSubview(movieNameLabel)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            movieNameLabel.topAnchor.constraint(equalTo: self.topAnchor),
            movieNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            movieNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            movieNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
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
