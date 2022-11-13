//
//  PresentedEditVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 03.11.2022.
//

import Foundation

class PresentedEditViewModel {
    
    func editFile(from pathToTheFile: String?, to toPath: String) {
        var urlComp = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/move")
        urlComp?.queryItems = [URLQueryItem(name: "from", value: pathToTheFile), URLQueryItem(name: "path", value: toPath), URLQueryItem(name: "overwrite", value: "true")]
        
        guard let url = urlComp?.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: urlRequest)
        task.resume()
    }
    
    func editFileInCoreData(object: String?, newName: String, completion: () -> Void) {
        let context = RecentCoreDataModel().container.viewContext
        let objects = try? context.fetch(Recent.fetchRequest())
        guard let object = object else {return}
        objects?.forEach({ recentData in
            if recentData.name == object {
                recentData.name = newName
                do {
                    try context.save()
                    completion()
                } catch {
                    print(error)
                }
            }
            
        })
    }
}
