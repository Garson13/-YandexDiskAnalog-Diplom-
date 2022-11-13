//
//  PresentedShareVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 13.10.2022.
//

import UIKit

class PresentedShareVC: UIViewController, ShareVCProtocol {
    
    private lazy var file: Any = ""
    private lazy var public_url: String = ""
    private lazy var path: String = ""
    private var viewModel: ShareViewModelProtocol?
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBAction func shareFile(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [file], applicationActivities: [])
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func sharePublicURL(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [public_url], applicationActivities: [])
        self.present(activityVC, animated: true)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func setInitValue(path: String, file: Any) {
        self.path = path
        self.file = file
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PresentedShareViewModel()
        viewModel?.delegate = self
        viewModel?.uploadData(path)
        stackView.layer.cornerRadius = 10
    }
    
    func setupData(public_url: String) {
        self.public_url = public_url
        self.file = file
    }
}
