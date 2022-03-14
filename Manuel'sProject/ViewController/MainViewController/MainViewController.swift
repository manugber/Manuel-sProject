//
//  MainViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import UIKit
import Foundation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITabBarDelegate {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var billboard: [Film] = []
    var filtered: [Film] = []
    var onlyFavs = false
    var searchActive = false
    var alphabetic = true
    let cellTypeIId = "cellTypeI"
    var elementsIndex0 = 0
    var elementsIndex1 = 0
    var elementsIndex2 = 0
    var elementsIndex3 = 0
    var elementsIndex4 = 0
    var elementsIndex5 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setDelegatesAndDataSources()
        setNavigationBar()
        let nibCellTypeI = UINib(nibName: "CellTypeI", bundle: nil)
        table.register(nibCellTypeI, forCellReuseIdentifier: cellTypeIId)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if alphabetic {
            if onlyFavs {
                return showFavs().count
            }
            return searchActive ? filtered.count : billboard.count
        } else {
            if onlyFavs {
                switch section {
                case 1:
                    elementsIndex1 = showFavsAndGenre(genre: "Ciencia Ficción").count
                    return elementsIndex1
                case 2:
                    elementsIndex2 = showFavsAndGenre(genre: "Drama").count
                    return elementsIndex2
                case 3:
                    elementsIndex3 = showFavsAndGenre(genre: "Musical").count
                    return elementsIndex3
                case 4:
                    elementsIndex4 = showFavsAndGenre(genre: "Superhéroes").count
                    return elementsIndex4
                case 5:
                    elementsIndex5 = showFavsAndGenre(genre: "Suspense").count
                    return elementsIndex5
                default:
                    elementsIndex0 = showFavsAndGenre(genre: "Acción").count
                    return elementsIndex0
                }
            } else {
                switch section {
                case 1:
                    elementsIndex1 = showGenre(genre: "Ciencia Ficción").count
                    return elementsIndex1
                case 2:
                    elementsIndex2 = showGenre(genre: "Drama").count
                    return elementsIndex2
                case 3:
                    elementsIndex3 = showGenre(genre: "Musical").count
                    return elementsIndex3
                case 4:
                    elementsIndex4 = showGenre(genre: "Superhéroes").count
                    return elementsIndex4
                case 5:
                    elementsIndex5 = showGenre(genre: "Suspense").count
                    return elementsIndex5
                default:
                    elementsIndex0 = showGenre(genre: "Acción").count
                    return elementsIndex0
                }
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if alphabetic {
            return 1
        } else {
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Ciencia Ficción"
        case 2:
            return "Drama"
        case 3:
            return "Musical"
        case 4:
            return "Superhéroes"
        case 5:
            return "Suspense"
        default:
            return "Acción"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if alphabetic {
            return 0
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: cellTypeIId, for: indexPath) as! CellTypeI
        cell.link = self
        var item: Film
        
        if onlyFavs {
            item = showFavs()[calculateIndex(indexPath: indexPath)]
        } else {
            if searchActive {
                item = filtered[calculateIndex(indexPath: indexPath)]
            } else {
                item = billboard[calculateIndex(indexPath: indexPath)]
            }
        }
        
        cell.filmTitle.text = item.title
        cell.filmGenre.text = item.genre
        cell.filmImage.image = UIImage(named: item.image)
        
        let image = item.isFavourite ? "heart.fill" : "heart"
        cell.favouriteButton.setImage(UIImage(systemName: image), for: .normal)
        cell.favouriteButton.tintColor = .systemYellow
        
        UIView.animate(withDuration: 0.75) { // no está funcionando
            //UIView.transition(with: cell.favouriteButton.imageView!, duration: 0.75, options: .transitionCrossDissolve, animations: { cell.favouriteButton.imageView?.image = UIImage(systemName: image) }, completion: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if onlyFavs {
            let instance = DetailsViewController(film: showFavs()[indexPath.item], billboard: billboard)
            navigationController?.pushViewController(instance, animated: true)
        } else {
            if searchActive {
                let instance = DetailsViewController(film: filtered[indexPath.item], billboard: billboard)
                navigationController?.pushViewController(instance, animated: true)
            } else {
                let instance = DetailsViewController(film: billboard[indexPath.item], billboard: billboard)
                navigationController?.pushViewController(instance, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = searchBar.text == "" || searchBar.text == nil ? false : true
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        table.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = []
        
        if searchText == "" {
            searchActive = false
        } else {
            searchActive = true
            let b = searchText.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            filtered = billboard.filter({ i in
                let a = i.title.lowercased().folding(options: .diacriticInsensitive, locale: .current)
                return a.contains(b)
            })
        }
        table.reloadData()
    }
    
    func pressedFavButton(cell: CellTypeI) {
        let index = calculateIndex(indexPath: table.indexPath(for: cell)!)
        if onlyFavs {
            let element = showFavs()[index]
            let indexOfElement = billboard.firstIndex(of: element)
            billboard[indexOfElement!].isFavourite = false
            table.reloadData()
        } else {
            if searchActive {
                let indexOfElement = billboard.firstIndex(of: filtered[index])
                billboard[indexOfElement!].isFavourite = billboard[indexOfElement!].isFavourite ? false : true
                searchBar(searchBar, textDidChange: searchBar.text!)
                //table.reloadRows(at: [table.indexPath(for: cell)!], with: .none)
            } else {
                billboard[index].isFavourite = billboard[index].isFavourite ? false : true
                //table.reloadRows(at: [table.indexPath(for: cell)!], with: .none)
            }
            table.reloadData()
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        searchBar(searchBar, textDidChange: searchBar.text!)
        if tabBar.items![1] == item {
            onlyFavs = true
            self.title = "Favoritos"
        } else {
            onlyFavs = false
            self.title = "Cartelera"
        }
        table.reloadData()
    }
    
    private func showFavs() -> [Film] {
        if searchActive {
            return filtered.filter({i in
                i.isFavourite
            })
        } else {
            return billboard.filter({i in
                i.isFavourite
            })
        }
    }
    
    private func showFavsAndGenre(genre: String) -> [Film] {
        if searchActive {
            return filtered.filter({i in
                i.isFavourite && i.genre == genre
            })
        } else {
            return billboard.filter({i in
                i.isFavourite && i.genre == genre
            })
        }
    }
    
    private func showGenre(genre: String) -> [Film] {
        if searchActive {
            return filtered.filter({i in
                i.genre == genre
            })
        } else {
            return billboard.filter({i in
                i.genre == genre
            })
        }
    }
    
    private func calculateIndex(indexPath: IndexPath) -> Int {
        if alphabetic {
            return indexPath.item
        } else {
            switch indexPath.section {
            case 1:
                return elementsIndex0 + indexPath.item
            case 2:
                return elementsIndex0 + elementsIndex1 + indexPath.item
            case 3:
                return elementsIndex0 + elementsIndex1 + elementsIndex2 + indexPath.item
            case 4:
                return elementsIndex0 + elementsIndex1 + elementsIndex2 + elementsIndex3 + indexPath.item
            case 5:
                return elementsIndex0 + elementsIndex1 + elementsIndex2 + elementsIndex3 + elementsIndex4 + indexPath.item
            default:
                return indexPath.item
            }
        }
    }
    
    private func loadData() {
        guard let source = Bundle.main.url(forResource: "dataset", withExtension: "json") else { fatalError("error") }
        guard let data = try? Data(contentsOf: source) else { fatalError("error") }
        let decoder = JSONDecoder()
        guard let cartelera = try? decoder.decode([Film].self, from: data) else { fatalError("error") }
        billboard = cartelera.sorted(by: {$0.title < $1.title})
    }
    
    private func setDelegatesAndDataSources() {
        table.delegate = self
        table.dataSource = self
        searchBar.delegate = self
        tabBar.delegate = self
    }
    
    private func setNavigationBar() {
        self.title = "Cartelera"
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Género", style: .plain, target: self, action: #selector(self.pressedButton))
    }
    
    @objc private func pressedButton() {
        if alphabetic {
            navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Título"
            alphabetic = false
            billboard = billboard.sorted(by: {$0.genre < $1.genre})
            table.reloadData()
        } else {
            navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Género"
            alphabetic = true
            billboard = billboard.sorted(by: {$0.title < $1.title})
            table.reloadData()
        }
        
    }
    
}

//
//,
//{
//    "title": "",
//    "genre": "",
//    "director": "",
//    "mainActor": "",
//    "description": "",
//    "image": "",
//    "isFavourite": false
//}