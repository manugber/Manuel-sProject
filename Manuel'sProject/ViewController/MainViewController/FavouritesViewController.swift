//
//  FavouritesViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 18/3/22.
//

import UIKit

class FavouritesViewController: MainViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        table.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sharedInstance.onlyFavs = true
        sharedInstance.searchActive = false
        navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = sharedInstance.leftBarButtonTitle
        if sharedInstance.popularityOrder {
            sharedInstance.favourites = sharedInstance.favourites.sorted(by: {$0.popularity! > $1.popularity!})
        } else {
            sharedInstance.favourites = sharedInstance.favourites.sorted(by: {$0.mainGenre! < $1.mainGenre!})
        }
        table.reloadData()
    }
    
    private func setNavigationBar() {
        self.title = "Favoritos"
    }

}
