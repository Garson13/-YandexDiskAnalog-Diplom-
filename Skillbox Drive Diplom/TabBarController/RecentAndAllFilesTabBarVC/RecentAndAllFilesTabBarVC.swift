//
//  RecentTabBarVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 05.08.2022.
//

import UIKit
import SnapKit

class RecentAndAllFilesTabBarVC: UIViewController, RecentAndAllFilesViewControllerProtocol {
    
    // MARK: - Private Variables
    var isOnInternet = true
    private var isPresentAlert = false
    var viewModel: RecentAndAllFilesTabBarViewModel?
    private var idCell = "RecentCell"
    let token = UserDefaults.standard.string(forKey: "token") ?? ""
    
    
    // MARK: - PRIVATE VIEWS VARIABLES
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        return view
    }()
    lazy var footerView: UIView =  {
        let view = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        view.startAnimating()
        return view
    }()
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: view.frame.midX, y: view.frame.midY, width: 0, height: 0))
        view.style = .large
        return view
    }()
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - FUNCTIONS
    
    
    
    private func configureRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
            self?.viewModel?.uploadData(token: self?.token ?? "", path: nil, offset: nil, completion: { _ in
            })
        }
    }
    
    func reloadData(deletedName: String) {
        viewModel?.reloadDataAfterDelete(deletedName: deletedName)
    }
    
    func editName(oldName: String, newName: String) {
        viewModel?.editName(oldName: oldName, newName: newName)
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecentCell.self, forCellReuseIdentifier: idCell)
        configureRefreshControl()
        setupConstraints()
    }
    
    func createViewForDetailVC(view: UIView, dateString: String, textLabelImage: String, pathToTheFile: String, newPath: String? ) {
        let vc = FilesPreviewVC.createFilesPreviewVC(view: view)
        vc.textDateLabel = RecentAndAllFilesTabBarViewModel.transformDate(date: dateString)
        vc.textLabelImage = textLabelImage
        vc.pathToTheFile = pathToTheFile
        vc.recentTabBarVC = self
        vc.newPath = newPath
        present(vc, animated: true, completion: nil)
    }
    
    func presentFailureAlert() {
        isOnInternet = false
        if !isPresentAlert {
            createAlertController()
            isPresentAlert = true
        }
    }
    
    func createAlertController() {
        let alert = UIAlertController(
            title: "Error".localized(),
            message: "No internet connection. Displaying files on last boot from your drive.".localized(),
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "OK".localized(),
            style: .cancel,
            handler: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        )
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func successUploadData() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - SETUP CONSTRAINTS
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - EXTENSTIONS

extension RecentAndAllFilesTabBarVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: idCell) as! RecentCell
        guard let model = viewModel?.items[indexPath.row] else {return UITableViewCell()}
        let dateStr = RecentAndAllFilesTabBarViewModel.transformDate(date: model.created)
        cell.nameFile.text = model.name
        cell.dateFile.text = dateStr
        cell.sizeFile.text = "\((model.size ?? 0)/1000000) " + "mb"
        if model.type == "dir" {
            cell.preview.image = UIImage(named: "dir")
            return cell
        } else {
            RecentAndAllFilesTabBarViewModel.loadImage(url: model.preview ?? "" , token: self.token, completion: { image in
                DispatchQueue.main.async {
                    cell.preview.image = image
                    self.activityIndicator.stopAnimating()
                }
            })
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
}

extension RecentAndAllFilesTabBarVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isOnInternet {
            guard let itemsCount = viewModel?.items.count else {return}
            let limit = 19
            if indexPath.row == itemsCount - 1, indexPath.row != limit {
                tableView.tableFooterView = footerView
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.75) {
                    self.viewModel?.addDataAfterPagination()
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
            } else {
                tableView.tableFooterView = nil
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let model = viewModel?.items[indexPath.row] else {return}
        
        switch model.type {
        case "file":
            let media_type = model.media_type
            let mime_type = model.mime_type
            let path = model.path
            var newPath = path.split(separator: "/")
            newPath.removeLast()
            var newPath2: String = ""
            newPath.forEach { str in
                newPath2 = newPath2 + str + "/"
            }
            
            if media_type == "image" {
                createViewForDetailVC(view: EnumFilesPreviewModeView.imageView, dateString: model.created, textLabelImage: model.name, pathToTheFile: model.path, newPath: newPath2)
            } else if mime_type == "application/pdf"{
                createViewForDetailVC(view: EnumFilesPreviewModeView.pdfView, dateString: model.created, textLabelImage: model.name, pathToTheFile: model.path, newPath: nil)
            }  else {
                createViewForDetailVC(view: EnumFilesPreviewModeView.wkWebView, dateString: model.created, textLabelImage: model.name, pathToTheFile: model.path, newPath: nil)
            }
            
        case "dir":
            let newvc = AllFilesTabBarVC()
            newvc.title = model.name
            newvc.path = model.path
            self.navigationController?.pushViewController(newvc, animated: true)
        default:
            return
        }
    }
}
