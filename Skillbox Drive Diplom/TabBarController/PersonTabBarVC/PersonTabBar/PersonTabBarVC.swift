//
//  PersonTabBarVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 05.08.2022.
//

import UIKit

class PersonTabBarVC: UIViewController, PersonVCProtocol {
    
    var viewModel: PersonViewModelProtocol? = PersonTabBarViewModel()
    var isOnInternet: Bool = true
    let colorFreeOnDisk = #colorLiteral(red: 0.5960784314, green: 0.5960784314, blue: 0.6156862745, alpha: 1)
    let colorBusyOnDisk = #colorLiteral(red: 0.368627451, green: 0.3607843137, blue: 0.9019607843, alpha: 1)
    
    @IBAction func publishedFilesButton(_ sender: Any) {
        let vc = DetailPersonVC()
        vc.title = "Published files".localized()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func presentExitVC(_ sender: Any) {
        guard let vc = UIStoryboard(name: "MainTabBar", bundle: nil).instantiateViewController(withIdentifier: "ExitVC") as? ExitVC else { return }
        vc.modalPresentationStyle = .popover
        
        guard let presentationController = vc.popoverPresentationController else { return }
        presentationController.delegate = self
        self.present(vc, animated: true)
    }
    
    
    @IBOutlet weak var publishedFilesButton: UIButton!
    
    @IBOutlet weak var busuOnDiskColorVIew: UIView!
    
    @IBOutlet weak var freeOnDiskColorView: UIView!
    
    @IBOutlet weak var noInternetConnections: UIView!
    
    @IBOutlet weak var pieChart: UIView!
    
    @IBOutlet weak var diskSpace: UILabel!
    
    @IBOutlet weak var busyOnDisk: UILabel!
    
    @IBOutlet weak var freeOnDisk: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    private func setupElements() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.368627451, green: 0.3607843137, blue: 0.9019607843, alpha: 1)
        viewModel?.delegate = self
        viewModel?.uploadData()
        if traitCollection.userInterfaceStyle == .dark {
            freeOnDisk.textColor = .white
            busyOnDisk.textColor = .white
        } else {
            freeOnDisk.textColor = .black
            busyOnDisk.textColor = .black
        }
        busuOnDiskColorVIew.isHidden = true
        freeOnDiskColorView.isHidden = true
        publishedFilesButton.isHidden = true
    }
    
    func setupValue() {
        let data = viewModel?.data
        let totalSpace = convertBytesInGB(bytes: Double(data?.total_space ?? 0), isRoundToInt: true)
        let busyOnDisk = convertBytesInGB(bytes: Double(data?.used_space ?? 0), isRoundToInt: false)
        let freeOnDisk = totalSpace - busyOnDisk
        let noneDataString = "Failed to get data.".localized()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.noInternetConnections.isHidden = self.isOnInternet ? true : false
            self.setupPieChartFreeOnDisk()
            self.setupPieChartBusyOnDisk(busyOnDisk / totalSpace)
            let total = "\(Int(totalSpace)) " + "gb".localized()
            let used = "\(busyOnDisk) " + "gb - used".localized()
            let free = "\(freeOnDisk) " + "gb - free".localized()
            self.diskSpace.text = self.isOnInternet ? total : noneDataString
            self.busyOnDisk.text = self.isOnInternet ? used : noneDataString
            self.freeOnDisk.text = self.isOnInternet ? free : noneDataString
            self.busuOnDiskColorVIew.isHidden = false
            self.freeOnDiskColorView.isHidden = false
            self.publishedFilesButton.isHidden = false
        }
    }
    
    private func setupPieChartBusyOnDisk(_ strokeValue: Double) {
        let widthLayer = pieChart.bounds.width - 45
        let heightLayer = pieChart.bounds.height - 45
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(ovalIn: CGRect(x: 22.5, y: 22.5, width: widthLayer , height: heightLayer)).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 40
        layer.strokeColor = colorBusyOnDisk.cgColor
        layer.strokeEnd = strokeValue
        pieChart.clipsToBounds = true
        pieChart.layer.addSublayer(layer)
    }
    
    
    private func setupPieChartFreeOnDisk() {
        let widthLayer = pieChart.bounds.width - 45
        let heightLayer = pieChart.bounds.height - 45
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(ovalIn: CGRect(x: 22.5, y: 22.5, width: widthLayer , height: heightLayer)).cgPath
        layer.lineWidth = 40
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = colorFreeOnDisk.cgColor
        pieChart.clipsToBounds = true
        pieChart.layer.addSublayer(layer)
    }
    
    private func convertBytesInGB(bytes: Double, isRoundToInt: Bool) -> Double {
        var value: Double = 0
        let byte: Double = bytes
        var origin: Double = 1
        let degree = 9
        
        for _ in 1...degree {
            origin *= 10
        }
        let finalValue = byte/origin
        value = isRoundToInt ? round(finalValue) : floor(finalValue * 10) / 10
        return value
    }
}

extension PersonTabBarVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .overFullScreen
    }
}

