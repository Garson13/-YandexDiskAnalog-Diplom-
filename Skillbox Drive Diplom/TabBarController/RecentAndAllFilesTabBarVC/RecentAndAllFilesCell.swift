//
//  File.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 08.08.2022.
//

import UIKit
import SnapKit

class RecentCell: UITableViewCell {
    
    lazy var preview: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    lazy var nameFile: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        view.contentMode = .scaleAspectFit
        if traitCollection.userInterfaceStyle == .dark {
            view.textColor = .white
        } else {
            view.textColor = .black
        }
        return view
    }()
    
    lazy var sizeFile: UILabel = {
        let view = UILabel()
        view.textColor = .gray
        view.contentMode = .scaleAspectFit
        view.font = .systemFont(ofSize: 12)
        return view
    }()
    
    lazy var dateFile: UILabel = {
        let view = UILabel()
        view.textColor = .gray
        view.contentMode = .scaleAspectFit
        view.font = .systemFont(ofSize: 12)
        return view
    }()
    
    private lazy var threeStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 5
        view.contentMode = .scaleAspectFit
        view.addArrangedSubview(sizeFile)
        view.addArrangedSubview(dateFile)
        return view
    }()
    
    private lazy var secondStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.contentMode = .scaleAspectFit
        view.spacing = 10
        view.addArrangedSubview(nameFile)
        view.addArrangedSubview(threeStackView)
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.alpha = 0
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 10
        view.contentMode = .scaleAspectFit
        view.addArrangedSubview(preview)
        view.addArrangedSubview(secondStackView)
        return view
    }()
    
    private func setupConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).inset(15)
            make.bottom.equalTo(contentView.snp.bottom).inset(15)
            make.left.equalTo(contentView.snp.left).inset(15)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "RecentCell")
        contentView.addSubview(mainStackView)
        setupConstraints()
        UIView.animate(withDuration: 0.37) {
            self.mainStackView.alpha = 1
        }
        let viewforselected = UIView()
        viewforselected.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 1, alpha: 0.1985720199)
        selectedBackgroundView = viewforselected
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
