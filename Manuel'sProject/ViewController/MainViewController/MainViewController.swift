//
//  MainViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import UIKit
import Foundation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITabBarControllerDelegate {
    
    @IBOutlet weak var table: UITableView!
    
    var page = 1
    let refreshControl = UIRefreshControl()
    var sharedInstance = DataController.instance
    var billboard: [Film] = []
    var filtered: [Film] = []
    let cellTypeIId = "CellTypeI"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegatesAndDataSources()
        setNavigationBar()
        let nibCellTypeI = UINib(nibName: "CellTypeI", bundle: nil)
        table.register(nibCellTypeI, forCellReuseIdentifier: self.cellTypeIId)
        refreshControl.attributedTitle = NSAttributedString(string: "Desliza para refrescar")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        table.addSubview(refreshControl)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sharedInstance.popularityOrder {
            if sharedInstance.onlyFavs {
                return sharedInstance.favourites.count
            }
            return sharedInstance.searchActive ? filtered.count : billboard.count
        } else {
            let genre = sharedInstance.genres[section]
            if sharedInstance.onlyFavs {
                sharedInstance.filmsForGenre[section] = self.showFavsAndGenre(genre: genre).count
            } else {
                sharedInstance.filmsForGenre[section] = self.showGenre(genre: genre).count
            }
            return sharedInstance.filmsForGenre[section]
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if sharedInstance.popularityOrder {
            return 1
        } else {
            return sharedInstance.genres.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sharedInstance.popularityOrder {
            return ""
        } else {
            return sharedInstance.genres[section].name
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sharedInstance.popularityOrder {
            return 0
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: cellTypeIId, for: indexPath) as! CellTypeI
        cell.link = self
        var item: Film
        let index = calculateIndex(indexPath: indexPath)
        
        if sharedInstance.searchActive {
            item = filtered[index]
        } else {
            if sharedInstance.onlyFavs {
                item = sharedInstance.favourites[index]
            } else {
                item = billboard[index]
            }
        }
        
        cell.filmTitle.text = item.title
        cell.filmGenre.text = item.mainGenre
        
        if let path = item.poster_path {
            let url = URL(string: "https://image.tmdb.org/t/p/w400\(path)")!
            
            getNetworkData(url: url) { data in
                UIImage(data: data)
            } callback: { resultImage in
                if case .success(let image) = resultImage {
                    DispatchQueue.main.async {
                        cell.filmImage.image = image
                    }
                }
                if case .failure(let error) = resultImage {
                    print(error.description)
                    DispatchQueue.main.async {
                        cell.filmImage.image = UIImage(systemName: "film")!
                    }
                }
            }

        }

        let image = checkFavourite(film: item) ? "heart.fill" : "heart"
        cell.favouriteButton.setImage(UIImage(systemName: image), for: .normal)
        cell.favouriteButton.tintColor = .systemYellow
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if sharedInstance.onlyFavs {
            let instance = FilmDetailsViewController(film: sharedInstance.favourites[calculateIndex(indexPath: indexPath)])
            navigationController?.pushViewController(instance, animated: true)
        } else {
            if sharedInstance.searchActive {
                let instance = FilmDetailsViewController(film: filtered[calculateIndex(indexPath: indexPath)])
                navigationController?.pushViewController(instance, animated: true)
            } else {
                let instance = FilmDetailsViewController(film: billboard[calculateIndex(indexPath: indexPath)])
                navigationController?.pushViewController(instance, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func pressedFavButton(cell: CellTypeI) {
        let index = calculateIndex(indexPath: table.indexPath(for: cell)!)
        if sharedInstance.onlyFavs {
            sharedInstance.favourites.remove(at: index)
            table.reloadData()
        } else {
            if sharedInstance.searchActive {
                if !checkFavourite(film: filtered[index]) {
                    sharedInstance.favourites.append(filtered[index])
                } else {
                    sharedInstance.favourites.removeAll { film in
                        return filtered[index].id == film.id
                    }
                }
                table.reloadRows(at: [table.indexPath(for: cell)!], with: .none)
            } else {
                if !checkFavourite(film: billboard[index]) {
                    sharedInstance.favourites.append(billboard[index])
                } else {
                    sharedInstance.favourites.removeAll { film in
                        return billboard[index].id == film.id
                    }
                }
                table.reloadRows(at: [table.indexPath(for: cell)!], with: .none)
            }
        }
    }
    
    private func showFavsAndGenre(genre: Genre) -> [Film] {
        return sharedInstance.favourites.filter({i in
            i.genre_ids[0] == genre.id
        })
    }
    
    private func showGenre(genre: Genre) -> [Film] {
        if sharedInstance.searchActive {
            return filtered.filter({i in
                i.genre_ids[0] == genre.id
            })
        } else {
            return billboard.filter({i in
                i.genre_ids[0] == genre.id
            })
        }
    }
    
    private func calculateIndex(indexPath: IndexPath) -> Int {
        if sharedInstance.popularityOrder {
            return indexPath.item
        } else {
            return sharedInstance.filmsForGenre.prefix(indexPath.section).reduce(indexPath.item) { partialResult, elementIndex in
                partialResult + elementIndex
            }
        }
    }
    
    private func setDelegatesAndDataSources() {
        table.delegate = self
        table.dataSource = self
        tabBarController!.delegate = self
    }
    
    private func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: sharedInstance.leftBarButtonTitle, style: .plain, target: self, action: #selector(self.pressedLeftButton))
    }
    
    private func checkFavourite(film: Film) -> Bool {
        return sharedInstance.favourites.contains(film)
    }
    
    @objc func pressedLeftButton() {
        if sharedInstance.popularityOrder {
            sharedInstance.leftBarButtonTitle = "Título"
            navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = sharedInstance.leftBarButtonTitle
            sharedInstance.popularityOrder = false
            filtered = filtered.sorted(by: {$0.mainGenre! < $1.mainGenre!})
            sharedInstance.favourites = sharedInstance.favourites.sorted(by: {$0.mainGenre! < $1.mainGenre!})
            billboard = billboard.sorted(by: {$0.mainGenre! < $1.mainGenre!})
        } else {
            sharedInstance.leftBarButtonTitle = "Género"
            navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = sharedInstance.leftBarButtonTitle
            sharedInstance.popularityOrder = true
            filtered = filtered.sorted(by: {$0.popularity! > $1.popularity!})
            sharedInstance.favourites = sharedInstance.favourites.sorted(by: {$0.popularity! > $1.popularity!})
            billboard = billboard.sorted(by: {$0.popularity! > $1.popularity!})
        }
        table.reloadData()
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
