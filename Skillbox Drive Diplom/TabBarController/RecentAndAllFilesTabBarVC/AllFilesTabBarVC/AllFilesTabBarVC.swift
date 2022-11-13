//
//  AllFilesTabBarVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 05.08.2022.
//

import UIKit

class AllFilesTabBarVC: RecentAndAllFilesTabBarVC {
    
    var path: String? = nil
    var offset: String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.368627451, green: 0.3607843137, blue: 0.9019607843, alpha: 1)
        viewModel = AllFilesViewModel()
        viewModel?.delegate = self
        viewModel?.uploadData(token: token, path: self.path, offset: offset, completion: { [weak self] items in
            if items == nil {
                self?.presentNoneFilesVC()
            } else {
                self?.saveItemsInCoreData()
            }
        })
    }
    
    func saveItemsInCoreData() {
        viewModel?.saveItemsInCoreData()
    }
    
    func presentNoneFilesVC() {
        activityIndicator.removeFromSuperview()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.center = view.center
        label.text = "Directory contains no files".localized()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 19, weight: .light)
        view.addSubview(label)
        
    }
    
    override func handleRefreshControl() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
            self?.viewModel?.uploadData(token: self?.token ?? "", path: self?.path, offset: self?.offset, completion: { _ in
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = viewModel?.items[indexPath.row] else {return}
        switch model.type {
            
        case "file":
            let media_type = model.media_type
            let mime_type = model.mime_type
            
            if media_type == "image" {
                createViewForDetailVC(view: EnumFilesPreviewModeView.imageView, dateString: model.created, textLabelImage: model.name, pathToTheFile: model.path, newPath: path)
            } else if mime_type == "application/pdf"{
                createViewForDetailVC(view: EnumFilesPreviewModeView.pdfView, dateString: model.created, textLabelImage: model.name, pathToTheFile: model.path, newPath: path)
            }  else {
                createViewForDetailVC(view: EnumFilesPreviewModeView.wkWebView, dateString: model.created, textLabelImage: model.name, pathToTheFile: model.path, newPath: path)
            }
            
        case "dir":
            if isOnInternet {
                let newvc = AllFilesDirVC()
                newvc.title = model.name
                newvc.path = model.path + "/"
                self.navigationController?.pushViewController(newvc, animated: true)
            } else {
                createAlertController()
            }
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isOnInternet{
            guard let itemsCount = viewModel?.items.count else {return}
            if indexPath.row == itemsCount - 1 {
                offset = String(itemsCount)
                tableView.tableFooterView = footerView
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let self = self else {return}
                    self.viewModel?.uploadData(token: self.token, path: self.path, offset: self.offset, completion: { _ in
                        DispatchQueue.main.async {
                            self.tableView.tableFooterView = nil
                        }
                    })
                }
            }
        }
    }
}


