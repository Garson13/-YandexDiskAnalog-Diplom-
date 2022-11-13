//
//  DetailPersonCell.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 11.11.2022.
//

import UIKit

class DetailPersonCell: RecentCell {
    
    private lazy var path: String = ""
    
    lazy var cancelPublicationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor.systemGray
        return button
    }()
    
    func configure(cellIndex: Int, path: String) {
        cancelPublicationButton.tag = cellIndex
        self.path = path
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "DetailPersonCell")
        contentView.addSubview(cancelPublicationButton)
        setupConstraintsButton()
        UIView.animate(withDuration: 0.37) {
            self.cancelPublicationButton.alpha = 1
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraintsButton() {
        cancelPublicationButton.snp.makeConstraints { make in
            make.right.equalTo(contentView.snp.right).inset(25)
            make.top.equalTo(contentView.snp.top).inset(15)
            make.bottom.equalTo(contentView.snp.bottom).inset(15)
        }
    }
    
    
}
