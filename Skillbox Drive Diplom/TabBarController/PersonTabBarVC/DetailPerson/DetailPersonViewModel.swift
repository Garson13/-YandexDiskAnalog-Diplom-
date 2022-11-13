//
//  DetailPersonViewModel.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 10.11.2022.
//

import Foundation

protocol UpdateDataAfterRemovePublicFilesProtocol: AnyObject {
    func updateData(removeName: String)
}

class DetailPersonViewModel: AllFilesViewModel {
    
    override func uploadData(token: String, path: String?, offset: String?, completion: @escaping ([ItemList]?) -> Void) {
        var urlComp = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/public")
        urlComp?.queryItems = [URLQueryItem(name: "limit", value: "15"), URLQueryItem(name: "offset", value: offset), URLQueryItem(name: "preview_crop", value: "true"), URLQueryItem(name: "preview_size", value: "50x50"), URLQueryItem(name: "preview_crop", value: "true"), URLQueryItem(name: "sort", value: "-created")]
        
        guard let url = urlComp?.url else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                guard let data = data else {
                    guard let error = error else {return}
                    
                    if error.localizedDescription == "The Internet connection appears to be offline." {
                        self.delegate?.presentFailureAlert()
                        return
                    }
                    return
                }
                
                do {
                    let dataList = try JSONDecoder().decode(MainList.self, from: data)
                    
                    if dataList.items.isEmpty {
                        completion(nil)
                    } else {
                        dataList.items.forEach { items in
                            if !self.items.contains(items) {
                                self.items.append(items)
                            }
                        }
                        
                        self.items.sort(by: { items1, items2 in
                            items1.type < items2.type
                        })
                        self.delegate?.successUploadData()
                        completion(self.items)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        })
        task.resume()
    }
}
