//
//  ViewModelLogin.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 29.07.2022.
//

import OnboardKit
import WebKit

protocol ViewControllerLoginProcotol: AnyObject {
    var viewModel: ViewModelLoginProtocol? {get set}
    func presentOnboardViewController()
    var token: String? {get set}
    var clientId: String {get set}
}

protocol ViewModelLoginProtocol: AnyObject {
    var delegate: ViewControllerLoginProcotol? {get set}
    func loginOauth() -> URLRequest
    func createOnboardViewController() -> OnboardViewController
    func presentOnboardViewController()
}

class ViewModelLogin: ViewModelLoginProtocol {
    
    weak var delegate: ViewControllerLoginProcotol?
    
    func loginOauth() -> URLRequest {
        var requestComp = URLComponents(string: "https://oauth.yandex.ru/authorize?")
        requestComp?.queryItems = [URLQueryItem(name: "response_type", value: "token"), URLQueryItem(name: "client_id", value: delegate?.clientId)]
        let url = requestComp?.url
        let urlRequest = URLRequest(url: url!)
        return urlRequest
    }
    
    func presentOnboardViewController() {
        delegate?.presentOnboardViewController()
    }
    
    func createOnboardViewController() -> OnboardViewController {
        let buttonStyle: OnboardViewController.ButtonStyling = { button in
            button.setTitleColor(.white, for: .normal)
            button.configuration = .filled()
            button.configuration?.cornerStyle = .capsule
            button.titleLabel?.font = UIFont.italicSystemFont(ofSize: 20)
        }
        
        let apperance = OnboardViewController.AppearanceConfiguration(tintColor: .blue, titleColor: .black, textColor: .black, backgroundColor: .white, imageContentMode: .scaleAspectFit, titleFont: UIFont.systemFont(ofSize: 23, weight: .semibold), textFont: UIFont.systemFont(ofSize: 25), advanceButtonStyling: buttonStyle)
        
        let onboardVC = OnboardViewController(pageItems: [
            OnboardPage(title: "Добро пожаловать в Skillbox Drive!", imageName: "PageOneImage", description: "Теперь все ваши документы в одном месте", advanceButtonTitle: "Далее"),
            OnboardPage(title: "Добро пожаловать в Skillbox Drive!", imageName: "PageTwoImage", description: "Доступ к файлам без интернета", advanceButtonTitle: "Далее"),
            OnboardPage(title: "Добро пожаловать в Skillbox Drive!", imageName: "PageThreeImage", description: "Делитесь вашими файлами с другими", advanceButtonTitle: "Далее")
        ], appearanceConfiguration: apperance)
        UserDefaults.standard.set(true, forKey: "isOnboardHidden")
        return onboardVC
    }
}
