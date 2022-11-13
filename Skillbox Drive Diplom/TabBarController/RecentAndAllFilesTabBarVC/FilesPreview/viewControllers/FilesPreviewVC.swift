//
//  FilesPreviewVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 13.09.2022.
//

import UIKit
import PDFKit
import WebKit


class FilesPreviewVC: UIViewController, FilesPreviewViewControllerProtocol {
    
    
    // MARK: - VARIABLES
    
    private var file: Any = 0
    
    private let token = UserDefaults.standard.string(forKey: "token") ?? ""
    private let viewModel: FilesPreviewViewModelProtocol = FilesPreviewViewModel()
    
    var recentTabBarVC: RecentAndAllFilesViewControllerProtocol?
    lazy var pathToTheFile: String = ""
    var newPath: String? = nil
    lazy var textDateLabel: String = ""
    lazy var textLabelImage: String = ""
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(frame: CGRect(x: view.frame.midX, y: view.bounds.midY, width: 0, height: 0))
        activity.style = .large
        activity.color = .white
        return activity
    }()
    private lazy var data: FilesPreviewModel? = nil
    private lazy var isImageFullScreen = false
    private lazy var isHiddenForViewItems = false
    private var myView: UIView?
    
    // MARK: - IBOUTLETS
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var labelImage: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var editButtonOutlet: UIButton!
    @IBOutlet weak var shareButtonOutlet: UIButton!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    
    // MARK: - IBACTIONS
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true) {
            self.removeFromParent()
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Rename".localized(), message: "Enter file name".localized(), preferredStyle: .alert)
        alertController.addTextField()
        
        let action = UIAlertAction(title: "Apply".localized(), style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else {return}
            let oldName = self.textLabelImage
            guard let ext = oldName.split(separator: ".").last else {return}
            let extensionsAndName = "\(text).\(ext)"
            DispatchQueue.main.async {
                self.labelImage.text = extensionsAndName
            }
            if let public_url = UserDefaults.standard.string(forKey: oldName) {
                UserDefaults.standard.set(public_url, forKey: extensionsAndName)
                UserDefaults.standard.removeObject(forKey: oldName)
            }
            self.viewModel.moveFileInCaches(at: oldName, to: extensionsAndName)
            let presentedModel = PresentedEditViewModel()
            presentedModel.editFile(from: self.pathToTheFile, to: "\(self.newPath ?? "")\(extensionsAndName)")
            presentedModel.editFileInCoreData(object: oldName, newName: extensionsAndName) {
                self.recentTabBarVC?.editName(oldName: oldName, newName: extensionsAndName)
            }
        }
        let action2 = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        alertController.addAction(action)
        alertController.addAction(action2)
        present(alertController, animated: true)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        viewModel.filePublication(pathToTheFile)
        guard let vc = UIStoryboard(name: "MainTabBar", bundle: nil).instantiateViewController(withIdentifier: "PresentedShareVC") as? PresentedShareVC else {return}
        vc.modalPresentationStyle = .popover
        vc.setInitValue(path: pathToTheFile, file: file)
        guard let presentationController = vc.popoverPresentationController else { return }
        presentationController.delegate = self
        self.present(vc, animated: true)
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        guard let vc = UIStoryboard(name: "MainTabBar", bundle: nil).instantiateViewController(withIdentifier: "PresentedDeleteVC") as? PresentedDeleteVC else {return}
        UserDefaults.standard.removeObject(forKey: textLabelImage)
        vc.deleteFileAndReloadData(path: pathToTheFile, deleteName: textLabelImage, filesPreviewVC: self)
        vc.modalPresentationStyle = .popover
        
        guard let presentationController = vc.popoverPresentationController else { return }
        presentationController.delegate = self
        self.present(vc, animated: true)
    }
    
    // MARK: - FUNC CREATE VIEW CONTROLLER
    
    static func createFilesPreviewVC(view: UIView) -> FilesPreviewVC {
        let vc = UIStoryboard(name: "MainTabBar", bundle: nil).instantiateViewController(withIdentifier: "FilesPreviewVC") as! FilesPreviewVC
        vc.myView = view
        return vc
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }
    
    // MARK: - Functions
    
    func reloadData() {
        recentTabBarVC?.reloadData(deletedName: textLabelImage)
        dismiss(animated: true) {
            self.removeFromParent()
        }
    }
    
    func deleteFileInCaches() {
        viewModel.deleteFileInCaches(at: textLabelImage)
    }
    
    private func configuration() {
        viewModel.delegate = self
        labelImage.text = textLabelImage
        dateLabel.text = textDateLabel
        setupGestures()
        setupGradientLayer()
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        showData()
    }
    
    private func showData() {
        let url = viewModel.createDirectoryURLForFile(fileName: textLabelImage)
        if let _ = try? Data(contentsOf: url) {
            viewSelection(data: nil)
        } else {
            viewModel.uploadData(pathToTheFile)
        }
    }
    
    func presentFailureAlert() {
        let alert = UIAlertController(
            title: "Error".localized(),
            message: "No internet connection. Please connect to view and download the file.".localized(),
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: "OK".localized(),
            style: .cancel) { _ in
                self.dismiss(animated: false) {
                    self.removeFromParent()
                }
            }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func setupData(data: FilesPreviewModel) {
        self.data = data
        viewSelection(data: self.data)
    }
    
    
    private func viewSelection(data: FilesPreviewModel?) {
        switch self.myView {
            
        case is UIImageView:
            self.viewModel.uploadFileInCaches(url: data?.file, fileName: textLabelImage) { url in
                guard let data = try? Data(contentsOf: url) else {return}
                guard let image = UIImage(data: data) else {return}
                let imageScrollView = ImageScrollView(frame: self.view.frame)
                self.file = image
                self.mainView.removeFromSuperview()
                self.view.addSubview(imageScrollView)
                self.view.sendSubviewToBack(imageScrollView)
                imageScrollView.set(image: image)
                self.activityIndicator.stopAnimating()
            }
        case let pdfView as PDFView:
            self.viewModel.uploadFileInCaches(url: data?.file, fileName: textLabelImage) { url in
                guard let pdfDoc = PDFDocument(url: url) else { return }
                self.file = pdfDoc
                self.mainView.removeFromSuperview()
                self.view.addSubview(pdfView)
                self.view.sendSubviewToBack(pdfView)
                pdfView.frame = self.view.frame
                pdfView.document = pdfDoc
                self.activityIndicator.stopAnimating()
            }
        case let office as WKWebView:
            self.viewModel.uploadFileInCaches(url: data?.file, fileName: textLabelImage) { url in
                guard let file = try? Data(contentsOf: url) else { return }
                self.file = file
                self.mainView.removeFromSuperview()
                office.frame = self.view.frame
                self.view.addSubview(office)
                self.view.sendSubviewToBack(office)
                office.loadFileURL(url, allowingReadAccessTo: url)
                self.activityIndicator.stopAnimating()
            }
        default:
            return
        }
    }
    
    private func setupGestures() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipeGesture.direction = [.up, .down]
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(hiddenItemOneTap))
        oneTap.delegate = self
        view.addGestureRecognizer(swipeGesture)
        view.addGestureRecognizer(oneTap)
    }
    
    private func setupGradientLayer() {
        let gragientTopView = CAGradientLayer()
        gragientTopView.colors = [
            UIColor(red: 0.025, green: 0.025, blue: 0.025, alpha: 0.75).cgColor,
            UIColor(red: 0.025, green: 0.025, blue: 0.025, alpha: 0).cgColor
        ]
        gragientTopView.startPoint = CGPoint(x: 0, y: 0)
        gragientTopView.endPoint = CGPoint(x: 0, y: 1)
        gragientTopView.frame = topView.frame
        topView.layer.insertSublayer(gragientTopView, at: 0)
        
        let gragientBottomView = CAGradientLayer()
        gragientBottomView.colors = [
            UIColor(red: 0.025, green: 0.025, blue: 0.025, alpha: 0.75).cgColor,
            UIColor(red: 0.025, green: 0.025, blue: 0.025, alpha: 0).cgColor
        ]
        gragientBottomView.startPoint = CGPoint(x: 0, y: 1)
        gragientBottomView.endPoint = CGPoint(x: 0, y: 0)
        gragientBottomView.frame = bottomView.frame
        topView.layer.insertSublayer(gragientBottomView, at: 0)
    }
    
    private func hiddenItems(){
        UIView.animate(withDuration: 0.25) {
            self.topView.alpha = self.isHiddenForViewItems ? 1 : 0
            self.backButtonOutlet.alpha = self.isHiddenForViewItems ? 1 : 0
            self.editButtonOutlet.alpha = self.isHiddenForViewItems ? 1 : 0
            self.shareButtonOutlet.alpha = self.isHiddenForViewItems ? 1 : 0
            self.deleteButtonOutlet.alpha = self.isHiddenForViewItems ? 1 : 0
            self.dateLabel.alpha = self.isHiddenForViewItems ? 1 : 0
            self.labelImage.alpha = self.isHiddenForViewItems ? 1 : 0
        } completion: { _ in
            self.isHiddenForViewItems = !self.isHiddenForViewItems
        }
    }
    
    // MARK: - @objc FUNC
    
    @objc private func swipeGesture() {
        dismiss(animated: true) {
            self.removeFromParent()
        }
    }
    
    @objc private func hiddenItemOneTap() {
        hiddenItems()
    }
}

// MARK: - EXTENSIONS

extension FilesPreviewVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension FilesPreviewVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .currentContext
    }
}
