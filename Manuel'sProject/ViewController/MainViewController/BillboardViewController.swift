//
//  BillboardViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 18/3/22.
//

import UIKit

final class BillboardViewController: MainViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setNavigationBar()
        Task(priority: .high) {
            await modelLogic.loadGenres()
            await modelLogic.loadFilms()
            dataSource.apply(modelLogic.snapshot, animatingDifferences: false)
            await MainActor.run {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
                    self.blurEffectView.layer.opacity = 0.0
                    self.activityIndicator.layer.opacity = 0.0
                } completion: { _ in
                    self.blurEffectView.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        blurEffectView = UIVisualEffectView()
        activityIndicator = UIActivityIndicatorView(style: .large)
        blur(controller: tabBarController, blurEffectView: blurEffectView, activityIndicator: activityIndicator)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        modelLogic.onlyFavs = false
        navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = modelLogic.leftBarButtonTitle.rawValue
        dataSource.apply(modelLogic.snapshot)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        modelLogic.query = searchText.lowercased().folding(options: .diacriticInsensitive, locale: .current).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Task(priority: .high) {
            await modelLogic.loadSearch()
            dataSource.apply(modelLogic.snapshot)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        modelLogic.query = ""
        searchBar.resignFirstResponder()
        dataSource.apply(modelLogic.snapshot)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func setNavigationBar() {
        self.title = "Cartelera"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(self.pressedNextButton)),
            UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.pressedPrevButton))
        ]
    }
    
    @objc private func pressedNextButton() {
        if modelLogic.query.isEmpty {
            Task(priority: .high) {
                modelLogic.page += 5
                await modelLogic.loadFilms()
                dataSource.apply(modelLogic.snapshot, animatingDifferences: false)
                await MainActor.run {
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
                        self.blurEffectView.layer.opacity = 0.0
                        self.activityIndicator.layer.opacity = 0.0
                    } completion: { _ in
                        self.blurEffectView.removeFromSuperview()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
            blurEffectView = UIVisualEffectView()
            activityIndicator = UIActivityIndicatorView(style: .large)
            blur(controller: tabBarController, blurEffectView: blurEffectView, activityIndicator: activityIndicator)
        }
    }
    
    @objc private func pressedPrevButton() {
        if modelLogic.page > 0 {
            if modelLogic.query.isEmpty {
                Task(priority: .high) {
                    modelLogic.page -= 5
                    await modelLogic.loadFilms()
                    dataSource.apply(modelLogic.snapshot, animatingDifferences: false)
                    await MainActor.run {
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
                            self.blurEffectView.layer.opacity = 0.0
                            self.activityIndicator.layer.opacity = 0.0
                        } completion: { _ in
                            self.blurEffectView.removeFromSuperview()
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
                blurEffectView = UIVisualEffectView()
                activityIndicator = UIActivityIndicatorView(style: .large)
                blur(controller: tabBarController, blurEffectView: blurEffectView, activityIndicator: activityIndicator)
            }
        }
    }
}
