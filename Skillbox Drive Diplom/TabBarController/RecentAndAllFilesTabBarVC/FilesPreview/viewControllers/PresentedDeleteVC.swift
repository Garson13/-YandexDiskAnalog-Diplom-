//
//  PresentedDeleteVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 13.10.2022.
//

import UIKit

class PresentedDeleteVC: UIViewController {
    
    let viewModel = PresentedDeleteViewModel()
    
    weak var filesPreviewVC: FilesPreviewViewControllerProtocol? 
    private lazy var pathForDelete: String = ""
    private lazy var nameDeletedObject: String = ""
    
    func deleteFileAndReloadData(path: String, deleteName: String, filesPreviewVC: FilesPreviewViewControllerProtocol) {
        self.pathForDelete = path
        self.nameDeletedObject = deleteName
        self.filesPreviewVC = filesPreviewVC
    }
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    @IBAction func deleteFile(_ sender: Any) {
        viewModel.deleteFile(pathForDelete)
        viewModel.deleteFileInCoreData(object: nameDeletedObject) {
            dismiss(animated: true) { [weak self] in
                self?.filesPreviewVC?.reloadData()
                self?.filesPreviewVC?.deleteFileInCaches()
            }
        }
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.layer.cornerRadius = 10
        
    }
    
}
