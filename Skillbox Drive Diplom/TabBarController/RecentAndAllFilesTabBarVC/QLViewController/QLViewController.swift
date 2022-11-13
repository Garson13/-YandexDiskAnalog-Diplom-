//
//  QLViewController.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 29.09.2022.
//

import UIKit
import QuickLook

class QLViewController: UIViewController, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
    var url: URL?
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let previewurl = url
        return previewurl! as QLPreviewItem
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = QLPreviewController()
        vc.dataSource = self
        vc.delegate = self
    }
    
}
