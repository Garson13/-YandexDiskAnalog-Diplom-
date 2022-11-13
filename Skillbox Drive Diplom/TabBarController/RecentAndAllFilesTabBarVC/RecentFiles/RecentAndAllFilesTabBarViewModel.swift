//
//  File.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 08.08.2022.
//

import UIKit.UIImage
import CoreData
import PDFKit
import QuickLook


protocol RecentAndAllFilesViewControllerProtocol: AnyObject {
    func presentFailureAlert()
    func successUploadData()
    func reloadData(deletedName: String)
    func editName(oldName: String, newName: String)
}

protocol RecentAndAllFilesViewModelProtocol: AnyObject {
    var delegate: RecentAndAllFilesViewControllerProtocol? {get set}
    var items: [ItemList] {get set}
    func uploadData(token: String, path: String?, offset: String?, completion: @escaping ([ItemList]?) -> Void)
    func addDataAfterPagination()
    func reloadDataAfterDelete(deletedName: String)
    func editName(oldName: String, newName: String)
    func saveItemsInCoreData()
}

class RecentAndAllFilesTabBarViewModel: RecentAndAllFilesViewModelProtocol {
    
    weak var delegate: RecentAndAllFilesViewControllerProtocol?
    
    var recentModel: RecentCoreDataModel = RecentCoreDataModel()
    var items: [ItemList] = []
    var itemsForPagination: [ItemList] = []
    
    static func transformDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        let dateStr = dateFormatter.string(from: date ?? Date())
        
        return dateStr
    }
    
    static func loadImage(url: String, token: String, completion: @escaping (UIImage?) -> Void) {
        
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
        task.resume()
    }
    
    func reloadDataAfterDelete(deletedName: String) {
        for (index, value) in items.enumerated() {
            if value.name == deletedName {
                items.remove(at: index)
            }
        }
        for (index, value) in itemsForPagination.enumerated() {
            if value.name == deletedName {
                itemsForPagination.remove(at: index)
            }
        }
        
        delegate?.successUploadData()
    }
    
    func editName(oldName: String, newName: String) {
        for (index, value) in items.enumerated() {
            if value.name == oldName {
                items[index].name = newName
            }
        }
        for (index, value) in itemsForPagination.enumerated() {
            if value.name == oldName {
                itemsForPagination[index].name = newName
            }
        }
        delegate?.successUploadData()
    }
    
    func uploadData(token: String, path: String?, offset: String?, completion: @escaping ([ItemList]?) -> Void) {
        var urlComp = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded")
        urlComp?.queryItems = [URLQueryItem(name: "preview_size", value: "50x50"), URLQueryItem(name: "preview_crop", value: "true")]
        
        guard let url = urlComp?.url else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            
            DispatchQueue.main.async { [weak self] in
                guard let data = data else {
                    guard let error = error else {return}
                    
                    if error.localizedDescription == "The Internet connection appears to be offline.".localized() {
                        self?.delegate?.presentFailureAlert()
                        guard let arrayRecent = try? self?.recentModel.container.viewContext.fetch(Recent.fetchRequest()) else {return}
                        
                        self?.items =  arrayRecent.map({ fetchObj in
                            ItemList(name: fetchObj.name, preview: fetchObj.preview, created: fetchObj.created, modified: "", media_type: fetchObj.media_type, path: fetchObj.path, type: fetchObj.type, mime_type: fetchObj.mime_type, size: fetchObj.size)
                        })
                        self?.items.sort(by: { items1, items2 in
                            items1.type > items2.type
                        })
                    }
                    return
                }
                
                if let objects = try? self?.recentModel.container.viewContext.fetch(Recent.fetchRequest()) {
                    objects.forEach({ obj in
                        self?.recentModel.container.viewContext.delete(obj)
                    })
                }
                
                if let _ = self?.items, let _ = self?.itemsForPagination {
                    self?.items.removeAll()
                    self?.itemsForPagination.removeAll()
                }
                
                do {
                    let dataList = try JSONDecoder().decode(MainList.self, from: data)
                    self?.itemsForPagination = dataList.items
                    self?.itemsForPagination.sort(by: { items1, items2 in
                        items1.name > items2.name
                    })
                    
                    self?.items = Array(dataList.items.prefix(12))
                    self?.items.sort(by: { items1, items2 in
                        items1.name > items2.name
                    })
                    self?.saveItemsInCoreData()
                    self?.delegate?.successUploadData()
                } catch {
                    print("Error: \(error) ")
                }
            }
        })
        task.resume()
    }
    
    func saveItemsInCoreData() {
        do {
            itemsForPagination.forEach({ [weak self] itemList in
                let object = Recent.init(entity: NSEntityDescription.entity(forEntityName: "Recent", in: (self?.recentModel.container.viewContext)!)!, insertInto: self?.recentModel.container.viewContext)
                object.name = itemList.name
                object.preview = itemList.preview ?? ""
                object.created = itemList.created
                object.size = itemList.size ?? 0
                object.mime_type = itemList.mime_type ?? ""
                object.media_type = itemList.media_type ?? ""
                object.path = itemList.path
            })
            try recentModel.container.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addDataAfterPagination() {
        items = itemsForPagination
    }
}
