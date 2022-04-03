//
//  MainViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import UIKit
import Foundation

class MainViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UITabBarControllerDelegate {
    
    @IBOutlet weak var table: UITableView!
    
    lazy var dataSource: FilmsDiffableDataSource = {
        FilmsDiffableDataSource(tableView: table) { table, indexPath, film in
            let cell = table.dequeueReusableCell(withIdentifier: "CellTypeI", for: indexPath) as? CellTypeI
            cell?.link = self
            cell?.filmTitle.text = film.title
            cell?.filmGenre.text = film.mainGenre
            cell?.favouriteButton.setImage(UIImage(systemName: film.isFavourite! ? "heart.fill" : "heart"), for: .normal)
            cell?.favouriteButton.tintColor = .systemYellow
            if let path = film.posterPath {
                Task { cell?.filmImage.image = await getFilmImage(path: path) }
            } else {
                Task { cell?.filmImage.image = UIImage(systemName: "film") }
            }
            return cell
        }
    }()
    
    var blurEffectView:UIVisualEffectView!
    var activityIndicator:UIActivityIndicatorView!
    let refreshControl = UIRefreshControl()
    let modelLogic = ModelLogic.shared
    let cellTypeIId = "CellTypeI"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setNavigationBar()
        table.dataSource = dataSource
        let nibCellTypeI = UINib(nibName: "CellTypeI", bundle: nil)
        table.register(nibCellTypeI, forCellReuseIdentifier: cellTypeIId)
        refreshControl.attributedTitle = NSAttributedString(string: "Desliza para refrescar")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        table.addSubview(refreshControl)
        dataSource.defaultRowAnimation = .right
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let film = dataSource.itemIdentifier(for: indexPath) else { return }
        let instance = FilmDetailsViewController(nibName: "FilmDetailsViewController", bundle: nil)
        instance.film = film
        navigationController?.pushViewController(instance, animated: true)
    }
    
    func pressedFavButton(cell: CellTypeI) {
        guard let film = dataSource.itemIdentifier(for: table.indexPath(for: cell)!) else { return }
        modelLogic.filmFavourited(film: film)
        dataSource.apply(modelLogic.snapshot, animatingDifferences: true)
    }
    
    private func setDelegates() {
        table.delegate = self
        tabBarController!.delegate = self
    }
    
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: modelLogic.leftBarButtonTitle.rawValue, style: .plain, target: self, action: #selector(self.pressedLeftButton))
    }
    
    @objc func pressedLeftButton() {
        if modelLogic.leftBarButtonTitle == .genre {
            modelLogic.leftBarButtonTitle = .popularity
        } else {
            modelLogic.leftBarButtonTitle = .genre
        }
        navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = modelLogic.leftBarButtonTitle.rawValue
        dataSource.apply(modelLogic.snapshot)
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        table.reloadData()
        refreshControl.endRefreshing()
    }
    
}

// TODO -
//implementar imagenes con SDWebImage y CocoaPods
//await/async cuando nos lo expliquen (+iOS 15.0)
//películas relacionadas por actor y director
//meter tráiler de la película
//REPASAR POR SI SE ME QUEDA ALGO
