//
//  PaginationCell.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 11.09.2022.
//

import UIKit

class PaginationCell: UITableViewCell {
    
    lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.alpha = 0
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "PaginationCell")
        contentView.addSubview(spinner)
        setupConstraints()
        UIView.animate(withDuration: 3 ) {
            self.spinner.alpha = 1
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        spinner.snp.makeConstraints { make in
            make.centerX.equalTo(contentView.snp.centerX)
            make.centerY.equalTo(contentView.snp.centerY)
        }
    }
}
