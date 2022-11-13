//
//  CancelPublicFilesVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 11.11.2022.
//

import UIKit


class CancelPublicFilesVC: UIViewController, CancelPublicFilesVCProtocol {
    
    weak var detailPersonVC: UpdateDataAfterRemovePublicFilesProtocol?
    
    private var viewModel: CancelPublicFilesViewModel?
    private lazy var path: String = ""
    private lazy var name: String = ""
    
    @IBOutlet weak var fileName: UILabel!
    
    @IBAction func removePost(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: name)
        viewModel?.unpublish(path: path)
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true) {
            self.removeFromParent()
        }
        UIView.animate(withDuration: 0.0001) { [weak self] in
            self?.view.backgroundColor = .clear
        }
    }
    
    func setValues(path: String, name: String) {
        self.path = path
        self.name = name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fileName.text = name
        viewModel = CancelPublicFilesViewModel()
        viewModel?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 1) { [weak self] in
            self?.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4456487997)
        }
    }
    
    func updateData() {
        detailPersonVC?.updateData(removeName: name)
        UIView.animate(withDuration: 0.0001) { [weak self] in
            self?.view.backgroundColor = .clear
            self?.dismiss(animated: true)
        }
    }
    
}
