//
//  ExitVC.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 12.11.2022.
//

import UIKit

class ExitVC: UIViewController {
    
    @IBAction func exitButton(_ sender: Any) {
        view.isHidden = true
        exitAlert()
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        UIView.animate(withDuration: 0.001) { [weak self] in
            self?.dismiss(animated: true)
            self?.view.backgroundColor = .clear
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1) { [weak self] in
            self?.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4456487997)
        }
    }
    
    private func exitAlert() {
        let alert = UIAlertController(
            title: "Log out".localized(),
            message: "Are you sure you want to sign out? All local data will be deleted".localized(),
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "Yes".localized(),
            style: .default,
            handler: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.deleteAllFilesAndLogout()
                }
            }
        )
        let action2 = UIAlertAction(
            title: "No".localized(),
            style: .cancel,
            handler: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true)
                    alert.dismiss(animated: true)
                    self?.removeFromParent()
                    alert.removeFromParent()
                }
            }
        )
        alert.addAction(action)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func deleteAllFilesAndLogout() {
        resetFilesInDirectory()
        resetCoreData()
        resetUserDefaults()
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
            return}
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        
        show(vc, sender: self)
    }
    
    private func resetCoreData() {
        let allFiles = AllFilesCoreDataModel()
        let recentFiles = RecentCoreDataModel()
        if let objects = try? allFiles.container.viewContext.fetch(AllFiles.fetchRequest()) {
            objects.forEach({ obj in
                allFiles.container.viewContext.delete(obj)
            })
        }
        
        if let objects = try? recentFiles.container.viewContext.fetch(AllFiles.fetchRequest()) {
            objects.forEach({ obj in
                recentFiles.container.viewContext.delete(obj)
            })
        }
        do {
            try allFiles.container.viewContext.save()
            try recentFiles.container.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func resetFilesInDirectory() {
        let cachePath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let objects = try? FileManager().contentsOfDirectory(at: cachePath, includingPropertiesForKeys: [])
        objects?.forEach({ url in
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error.localizedDescription)
            }
        })
    }
    
    private func resetUserDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}
