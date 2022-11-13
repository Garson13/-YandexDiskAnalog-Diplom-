//
//  AllFilesViewModel.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 05.11.2022.
//

import Foundation
import CoreData

class AllFilesViewModel: RecentAndAllFilesTabBarViewModel {
    
    var allFilesCoreDataModel = AllFilesCoreDataModel()
    
    override func uploadData(token: String, path: String?, offset: String?, completion: @escaping ([ItemList]?) -> Void) {
        
        var urlComp = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources")
        urlComp?.queryItems = [URLQueryItem(name: "path", value: path != nil ? path : "disk:/"), URLQueryItem(name: "limit", value: "15"), URLQueryItem(name: "offset", value: offset), URLQueryItem(name: "preview_crop", value: "true"), URLQueryItem(name: "preview_size", value: "50x50"), URLQueryItem(name: "preview_crop", value: "true"), URLQueryItem(name: "sort", value: "-created")]
        
        guard let url = urlComp?.url else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                guard let data = data else {
                    guard let error = error else {return}
                    
                    if error.localizedDescription == "The Internet connection appears to be offline.".localized() {
                        self.delegate?.presentFailureAlert()
                        guard let arrayAllFiles = try? self.allFilesCoreDataModel.container.viewContext.fetch(AllFiles.fetchRequest()) else {return}
                        self.items =  arrayAllFiles.map({ fetchObj in
                            ItemList(name: fetchObj.name, preview: fetchObj.preview, created: fetchObj.created, modified: "", media_type: fetchObj.media_type, path: fetchObj.path, type: fetchObj.type, mime_type: fetchObj.mime_type, size: fetchObj.size)
                        })
                        self.items.sort(by: { items1, items2 in
                            items1.type < items2.type
                        })
                        return
                    }
                    return
                }
                
                if let objects = try? self.allFilesCoreDataModel.container.viewContext.fetch(AllFiles.fetchRequest()) {
                    objects.forEach({ obj in
                        self.allFilesCoreDataModel.container.viewContext.delete(obj)
                    })
                }
                
                do {
                    let dataList = try JSONDecoder().decode(AllFilesModel.self, from: data)
                    if dataList._embedded.items.isEmpty {
                        completion(nil)
                    } else {
                        dataList._embedded.items.forEach { items in
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
    
    override func saveItemsInCoreData() {
        do {
            items.forEach({ [weak self] itemList in
                let object = AllFiles.init(entity: NSEntityDescription.entity(forEntityName: "AllFiles", in: (self?.allFilesCoreDataModel.container.viewContext)!)!, insertInto: self?.allFilesCoreDataModel.container.viewContext)
                object.name = itemList.name
                object.preview = itemList.preview ?? ""
                object.created = itemList.created
                object.size = itemList.size ?? 0
                object.mime_type = itemList.mime_type ?? ""
                object.media_type = itemList.media_type ?? ""
                object.path = itemList.path
                object.type = itemList.type
            })
            try allFilesCoreDataModel.container.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
