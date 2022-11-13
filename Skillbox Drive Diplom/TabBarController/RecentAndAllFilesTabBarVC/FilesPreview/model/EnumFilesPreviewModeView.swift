//
//  EnumFilesPreviewModeView.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 21.09.2022.
//


import UIKit
import PDFKit
import WebKit


enum EnumFilesPreviewModeView {
    
    static var imageView: UIImageView {
        let view = UIImageView()
        view.backgroundColor = .black
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFit
        return view
    }
    
    
    static var pdfView: PDFView {
        let view = PDFView()
        view.displayMode = .singlePageContinuous
        view.isUserInteractionEnabled = true
        return view
    }
    
    static var wkWebView: WKWebView {
        let webConfig = WKWebViewConfiguration()
        let view = WKWebView(frame: .zero, configuration: webConfig)
        view.isUserInteractionEnabled = true
        return view
    }
    
}
