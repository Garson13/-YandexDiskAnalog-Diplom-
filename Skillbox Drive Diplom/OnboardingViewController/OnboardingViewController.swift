//
//  OnboardingViewController.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 30.07.2022.
//

import UIKit
import OnboardKit

class OnboardingViewController: UIViewController {
    
    
//    let pageOne = OnboardPage(title: "Добро пожаловать в Skillbox Drive!", imageName: "PageOneImage", description: "Теперь все ваши документы в одном месте")
//    let pageTwo = OnboardPage(title: "Добро пожаловать в Skillbox Drive!", imageName: "PageTwoImage", description: "Доступ к файлам без интернета")
//    let pageThree = OnboardPage(title: "Добро пожаловать в Skillbox Drive!", imageName: "PageThreeImage", description: "Делитесь вашими файлами с другими")
    
    let onboardVC = OnboardViewController(pageItems: [
        OnboardPage(title: "Добро пожаловать в Skillbox Drive!", imageName: "PageOneImage", description: "Теперь все ваши документы в одном месте"),
        OnboardPage(title: "Добро пожаловать в Skillbox Drive!", imageName: "PageTwoImage", description: "Доступ к файлам без интернета"),
        OnboardPage(title: "Добро пожаловать в Skillbox Drive!", imageName: "PageThreeImage", description: "Делитесь вашими файлами с другими")
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        onboardVC.presentFrom(self, animated: true)
    }
    
}
