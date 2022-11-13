//
//  VCForVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 05.11.2022.
//

import Foundation

class RecentVC: RecentAndAllFilesTabBarVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = RecentAndAllFilesTabBarViewModel()
        viewModel?.delegate = self
        self.viewModel?.uploadData(token: self.token, path: nil, offset: nil, completion: { _ in
        })
    }
}
