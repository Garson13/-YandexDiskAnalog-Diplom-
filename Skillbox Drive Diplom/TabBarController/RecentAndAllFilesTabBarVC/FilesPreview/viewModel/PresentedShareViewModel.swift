//
//  PresentedShareViewModel.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 11.11.2022.
//

import Foundation

protocol ShareVCProtocol: AnyObject {
    func setupData(public_url: String)
}

protocol ShareViewModelProtocol: AnyObject {
    var delegate: ShareVCProtocol? {get set}
    func uploadData(_ pathToTheFile: String)
}

class PresentedShareViewModel: ShareViewModelProtocol {
    
    weak var delegate: ShareVCProtocol?
    
    func uploadData(_ pathToTheFile: String) {
        var urlComp = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources")
        urlComp?.queryItems = [URLQueryItem(name: "path", value: pathToTheFile)]
        
        guard let url = urlComp?.url else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            DispatchQueue.main.async { [weak self] in
                guard let data = data else {
                    return
                }
                do {
                    let datas = try JSONDecoder().decode(FilesPreviewModel.self, from: data)
                    UserDefaults.standard.set(datas.public_url, forKey: datas.name)
                    self?.delegate?.setupData(public_url: datas.public_url ?? "")
                } catch {
                    print("\(error)")
                }
            }
        })
        task.resume()
    }
}
