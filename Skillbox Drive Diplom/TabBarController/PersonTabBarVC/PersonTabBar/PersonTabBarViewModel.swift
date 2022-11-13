//
//  PersonTabBarViewModel.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 09.11.2022.
//

import Foundation

protocol PersonVCProtocol: AnyObject {
    func setupValue()
    var isOnInternet: Bool {get set}
}

protocol PersonViewModelProtocol: AnyObject {
    var delegate: PersonVCProtocol? {get set}
    var data: PersonTabBarModel? {get set}
    func uploadData()
}

class PersonTabBarViewModel: PersonViewModelProtocol {
    
    weak var delegate: PersonVCProtocol?
    
    var data: PersonTabBarModel?
    
    func uploadData() {
        let urlComp = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/")
        
        guard let url = urlComp?.url else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            
            DispatchQueue.main.async { [weak self] in
                guard let data = data else {
                    if error?.localizedDescription == "The Internet connection appears to be offline.".localized() {
                        self?.delegate?.isOnInternet = false
                        self?.delegate?.setupValue()
                    }
                    return
                }
                do {
                    let data = try JSONDecoder().decode(PersonTabBarModel.self, from: data)
                    self?.data = data
                    self?.delegate?.setupValue()
                } catch {
                    print("Error: \(error) ")
                }
            }
        })
        task.resume()
    }
}
