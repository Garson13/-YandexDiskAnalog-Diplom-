//
//  PresentedDeleteViewModel.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 03.11.2022.
//

import Foundation


class PresentedDeleteViewModel {
    
    
    func deleteFile(_ pathToTheFile: String) {
        var urlComp = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources")
        urlComp?.queryItems = [URLQueryItem(name: "path", value: pathToTheFile), URLQueryItem(name: "permanently", value: "true")]
        
        guard let url = urlComp?.url else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: urlRequest)
        task.resume()
    }
    
    
    func deleteFileInCoreData(object: String, completion: () -> Void) {
        let context = RecentCoreDataModel().container.viewContext
        let objects = try? context.fetch(Recent.fetchRequest())
        
        objects?.forEach({ recentData in
            if recentData.name == object{
                context.delete(recentData)
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
