//
//  FilesPreviewViewModel.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 13.09.2022.
//

import Foundation
import UIKit.UIImage

protocol FilesPreviewViewControllerProtocol: AnyObject {
    func presentFailureAlert()
    func setupData(data: FilesPreviewModel)
    func deleteFileInCaches()
    func reloadData()
    var newPath: String? {get set}
}
protocol FilesPreviewViewModelProtocol: AnyObject {
    var delegate: FilesPreviewViewControllerProtocol? {get set}
    func uploadFileInCaches(url: String?, fileName: String, completion: @escaping (URL) -> Void )
    func moveFileInCaches(at fileName: String?, to newFileName: String)
    func deleteFileInCaches(at fileName: String?)
    func createDirectoryURLForFile(fileName: String) -> URL
    func uploadData(_ pathToTheFile: String)
    func filePublication(_ pathToTheFile: String)
}

class FilesPreviewViewModel: FilesPreviewViewModelProtocol {
    
    weak var delegate: FilesPreviewViewControllerProtocol?
    
    func createDirectoryURLForFile(fileName: String) -> URL {
        let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let filesPath = cachePath.appendingPathComponent("Files")
        try? FileManager.default.createDirectory(at: filesPath, withIntermediateDirectories: false, attributes: nil)
        let fileURL = filesPath.appendingPathComponent(fileName)
        return fileURL
    }
    
    func uploadFileInCaches(url: String?, fileName: String, completion: @escaping (URL) -> Void) {
        let fileURL = createDirectoryURLForFile(fileName: fileName)
        if let _ = try? Data(contentsOf: fileURL) {
            completion(fileURL)
        } else {
            guard let url = url else { return }
            guard let url2 = URL(string: url) else { return  }
            let request = URLRequest(url: url2)
            let task = URLSession.shared.downloadTask(with: request) { localURL, _, _ in
                guard let localURL = localURL else { return }
                do {
                    try FileManager.default.copyItem(at: localURL, to: fileURL)
                    DispatchQueue.main.async {
                        completion(fileURL)
                    }
                } catch let error {
                    print("Copy Error: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
    }
    
    func deleteFileInCaches(at fileName: String?) {
        guard let fileName = fileName else { return }
        let atFileURL = createDirectoryURLForFile(fileName: fileName)
        do {
            try FileManager.default.removeItem(at: atFileURL)
        } catch {
            print("Remove Error: \(error.localizedDescription)")
        }
    }
    
    func moveFileInCaches(at fileName: String?, to newFileName: String) {
        guard let fileName = fileName else { return }
        let atFileURL = createDirectoryURLForFile(fileName: fileName)
        let toFileURL = createDirectoryURLForFile(fileName: newFileName)
        do {
            try FileManager.default.moveItem(at: atFileURL, to: toFileURL)
        } catch {
            print("Move Error: \(error.localizedDescription)")
        }
    }
    
    func filePublication(_ pathToTheFile: String) {
        var urlComp = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/publish")
        urlComp?.queryItems = [URLQueryItem(name: "path", value: pathToTheFile), URLQueryItem(name: "path", value: pathToTheFile)]
        
        guard let url = urlComp?.url else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "PUT"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            guard let _ = data else {
                self?.delegate?.presentFailureAlert()
                return
            }
        }
        task.resume()
    }
    
    
    func uploadData(_ pathToTheFile: String) {
        var urlComp = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources")
        urlComp?.queryItems = [URLQueryItem(name: "path", value: pathToTheFile)]
        
        guard let url = urlComp?.url else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("OAuth \(UserDefaults.standard.string(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            DispatchQueue.main.async { [weak self] in
                guard let data = data else {
                    self?.delegate?.presentFailureAlert()
                    return
                }
                do {
                    let datas = try JSONDecoder().decode(FilesPreviewModel.self, from: data)
                    self?.delegate?.setupData(data: datas)
                } catch {
                    print("\(error)")
                }
            }
        })
        task.resume()
    }
}
