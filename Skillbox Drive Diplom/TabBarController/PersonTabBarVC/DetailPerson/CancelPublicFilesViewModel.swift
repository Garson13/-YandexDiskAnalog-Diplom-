//
//  cancelPublicFilesViewModel.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 11.11.2022.
//

import Foundation

protocol CancelPublicFilesVCProtocol: AnyObject {
    func updateData()
}

protocol CancelPublicFilesViewModelProtocol: AnyObject {
    var delegate: CancelPublicFilesVCProtocol? {get set}
    func unpublish(path: String)
}

class CancelPublicFilesViewModel: CancelPublicFilesViewModelProtocol {
    
    weak var delegate: CancelPublicFilesVCProtocol?
    
    func unpublish(path: String) {
        var urlComp = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/unpublish")
        urlComp?.queryItems = [URLQueryItem(name: "path", value: path)]
        
        guard let url = urlComp?.url else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: urlRequest)
        delegate?.updateData()
        task.resume()
    }
}
