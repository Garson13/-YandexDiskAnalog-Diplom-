//
//  ViewControllerLoginScreenOne.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 30.07.2022.
//

import UIKit

class ViewControllerLoginScreeOne: UIViewController {
    let viewModel = ViewModelLogin()
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.presentOnboardViewController(viewController: self)
    }
}


