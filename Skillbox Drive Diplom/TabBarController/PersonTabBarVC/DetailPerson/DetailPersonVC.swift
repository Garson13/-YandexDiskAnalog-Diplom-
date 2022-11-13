//
//  DetailPersonVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 10.11.2022.
//

import UIKit

class DetailPersonVC: AllFilesTabBarVC, UpdateDataAfterRemovePublicFilesProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupValues()
    }
    
    override func handleRefreshControl() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
            self?.viewModel?.uploadData(token: self?.token ?? "", path: self?.path, offset: self?.offset, completion: { _ in
            })
        }
    }
    
    private func setupValues() {
        tableView.register(DetailPersonCell.self, forCellReuseIdentifier: "DetailPersonCell")
        viewModel = DetailPersonViewModel()
        viewModel?.delegate = self
        viewModel?.uploadData(token: token, path: nil, offset: offset, completion: { [weak self] items in
            if items == nil {
                self?.presentNoneFilesVC()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailPersonCell") as! DetailPersonCell
        guard let model = viewModel?.items[indexPath.row] else {return UITableViewCell()}
        let dateStr = RecentAndAllFilesTabBarViewModel.transformDate(date: model.created)
        cell.nameFile.text = model.name
        cell.dateFile.text = dateStr
        cell.sizeFile.text = "\((model.size ?? 0)/1000000) " + "mb".localized()
        cell.configure(cellIndex: indexPath.row, path: model.path)
        cell.cancelPublicationButton.addTarget(self, action: #selector(tappedCancelPublicationButton), for: .touchUpInside)
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
    
    @objc func tappedCancelPublicationButton(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "MainTabBar", bundle: nil).instantiateViewController(withIdentifier: "CancelPublicFilesVC") as? CancelPublicFilesVC else { return  }
        vc.modalPresentationStyle = .popover
        vc.detailPersonVC = self
        let index = sender.tag
        let model = viewModel?.items[index]
        guard let path = model?.path, let name = model?.name else {return}
        vc.setValues(path: path, name: name)
        guard let presentationController = vc.popoverPresentationController else { return }
        presentationController.delegate = self
        self.present(vc, animated: true)
        
    }
    
    func updateData(removeName: String) {
        viewModel?.reloadDataAfterDelete(deletedName: removeName)
    }
    
}

extension DetailPersonVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .overFullScreen
    }
}
