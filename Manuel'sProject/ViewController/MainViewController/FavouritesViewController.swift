//
//  FavouritesViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 18/3/22.
//

import UIKit

final class FavouritesViewController: MainViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        modelLogic.onlyFavs = true
        navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = modelLogic.leftBarButtonTitle.rawValue
        dataSource.apply(modelLogic.snapshot)
    }
    
    private func setNavigationBar() {
        self.title = "Favoritos"
    }

}
