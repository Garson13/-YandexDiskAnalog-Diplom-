//
//  PageViewController.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 13.09.2022.
//

import UIKit

class PageViewController: UIPageViewController {
    
    let vc = UIStoryboard(name: "MainTabBar", bundle: nil).instantiateViewController(withIdentifier: "FilesPreviewVC") as! FilesPreviewVC
    
    var index: Int? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if index == 0 {
            return nil
        } else {
        let vc = UIStoryboard(name: "MainTabBar", bundle: nil).instantiateViewController(withIdentifier: "FilesPreviewVC") as! FilesPreviewVC
        return vc
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if index == 19 {
            return nil
        } else {
            let vc = UIStoryboard(name: "MainTabBar", bundle: nil).instantiateViewController(withIdentifier: "FilesPreviewVC") as! FilesPreviewVC
            return vc
        }
    }
    
    
}
