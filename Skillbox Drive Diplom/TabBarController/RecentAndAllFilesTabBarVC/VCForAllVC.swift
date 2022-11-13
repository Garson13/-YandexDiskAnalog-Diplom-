//
//  VCForAllVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 05.11.2022.
//

import UIKit

class VCForAllVC: UIViewController, RecentViewControllerProtocol {
    
    // MARK: - Private Variables
    private var isOnInternet = true
    private var isPresentAlert = false
    private let viewModel: RecentViewModelProtocol = RecentTabBarViewModel()
    private var idCell = "RecentCell"
    private let token = UserDefaults.standard.string(forKey: "token") ?? ""
    
    
    // MARK: - PRIVATE VIEWS VARIABLES
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        return view
    }()
    private lazy var footerView: UIView =  {
        let view = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        view.startAnimating()
        return view
    }()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: view.frame.midX, y: view.frame.midY, width: 0, height: 0))
        view.style = .large
        return view
    }()
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.uploadData(token: token)
    }
    
    // MARK: - FUNCTIONS
    
    
    
    private func configureRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
            self?.viewModel.uploadData(token: self?.token ?? "")
        }
    }
    
    func reloadData(deletedName: String) {
        viewModel.reloadDataAfterDelete(deletedName: deletedName)
    }
    
    func editName(oldName: String, newName: String) {
        viewModel.editName(oldName: oldName, newName: newName)
    }
    
    private func setupViews() {
        viewModel.delegate = self
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecentCell.self, forCellReuseIdentifier: idCell)
        configureRefreshControl()
        setupConstraints()
    }
    
    private func createViewForDetailVC(view: UIView, dateString: String, textLabelImage: String, pathToTheFile: String) {
        let vc = FilesPreviewVC.createFilesPreviewVC(view: view)
        vc.textDateLabel = RecentTabBarViewModel.transformDate(date: dateString)
        vc.textLabelImage = textLabelImage
        vc.pathToTheFile = pathToTheFile
        vc.recentTabBarVC = self
        present(vc, animated: true, completion: nil)
    }
    
    func presentFailureAlert() {
        isOnInternet = false
        if !isPresentAlert {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Нет подключения к интернету. Отображаем файлы при последней загрузке из Вашего диска.",
                preferredStyle: .alert
            )
            let action = UIAlertAction(
                title: "Понятно",
                style: .cancel,
                handler: { [weak self] _ in
                    self?.isPresentAlert = true
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            )
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
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

extension VCForAllVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: idCell) as! RecentCell
        let model = viewModel.items[indexPath.row]
        let dateStr = RecentTabBarViewModel.transformDate(date: model.created)
        cell.nameFile.text = model.name
        cell.dateFile.text = dateStr
        cell.sizeFile.text = "\(model.size/1000000) мб"
        RecentTabBarViewModel.loadImage(url: model.preview , token: self.token, completion: { image in
            DispatchQueue.main.async {
                cell.preview.image = image
                self.activityIndicator.stopAnimating()
            }
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
}

extension VCForAllVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let limit = 19
        if isOnInternet {
            if indexPath.row == viewModel.items.count - 1, indexPath.row != limit {
                tableView.tableFooterView = footerView
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.75) {
                    self.viewModel.addDataAfterPagination()
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
        let model = viewModel.items[indexPath.row]
        let media_type = model.media_type
        let mime_type = model.mime_type
        
        if media_type == "image" {
            createViewForDetailVC(view: EnumFilesPreviewModeView.imageView, dateString: model.created, textLabelImage: model.name, pathToTheFile: model.path)
        } else if mime_type == "application/pdf"{
            createViewForDetailVC(view: EnumFilesPreviewModeView.pdfView, dateString: model.created, textLabelImage: model.name, pathToTheFile: model.path)
        }  else {
            createViewForDetailVC(view: EnumFilesPreviewModeView.wkWebView, dateString: model.created, textLabelImage: model.name, pathToTheFile: model.path)
        }
    }
}
