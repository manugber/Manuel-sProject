//
//  BillboardViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 18/3/22.
//

import UIKit

class BillboardViewController: MainViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    let genresURL = URL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setNavigationBar()
        loadGenres()
        loadData(pageToView: page)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sharedInstance.onlyFavs = false
        navigationController?.navigationBar.topItem?.leftBarButtonItem?.title = sharedInstance.leftBarButtonTitle
        if sharedInstance.popularityOrder {
            billboard = billboard.sorted(by: {$0.popularity! > $1.popularity!})
        } else {
            billboard = billboard.sorted(by: {$0.mainGenre! < $1.mainGenre!})
        }
        table.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            sharedInstance.searchActive = false
            table.reloadData()
        } else {
            sharedInstance.searchActive = true
            let b = searchBar.text!.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            let query = b.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            getSearch(query: query!)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" || searchBar.text == nil {
            sharedInstance.searchActive = false
            table.reloadData()
        } else {
            sharedInstance.searchActive = true
            let b = searchBar.text!.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            let query = b.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            getSearch(query: query!)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            sharedInstance.searchActive = false
        } else {
            sharedInstance.searchActive = true
        }
        searchBar.setShowsCancelButton(true, animated: true)
        table.reloadData()
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
    
    private func setNavigationBar() {
        self.title = "Cartelera"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(self.pressedNextButton)),
            UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.pressedPrevButton))
        ]
    }
    
    @objc private func pressedNextButton() {
        if !sharedInstance.searchActive {
            loadData(pageToView: page + 1)
        }
    }
    
    @objc private func pressedPrevButton() {
        if page > 1 {
            if !sharedInstance.searchActive {
                loadData(pageToView: page - 1)
            }
        }
    }
    
    private func loadGenres() {
        getNetworkThrowingData(url: genresURL) { data in
            try JSONDecoder().decode(ResponseGenres.self, from: data)
        } callback: { resultJSON in
            if case .success(let json) = resultJSON {
                self.sharedInstance.genres = json.genres
                self.sharedInstance.genres.append(Genre(id: 0, name: "Desconocido"))
                self.sharedInstance.genres = self.sharedInstance.genres.sorted(by: {$0.name < $1.name})
                self.sharedInstance.genres.forEach { genre in
                        self.sharedInstance.filmsForGenre.append(0)
                }
            }
            if case .failure(let error) = resultJSON {
                print(error.description)
            }
        }
    }
    
    private func loadData(pageToView: Int) {
        
        let filmsUrl = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&sort_by=popularity.desc&page=\(pageToView)")!
        
        getNetworkThrowingData(url: filmsUrl) { data in
            try JSONDecoder().decode(ResponseFilms.self, from: data)
        } callback: { resultJSON in
            if case .success(let json) = resultJSON {
                self.billboard = json.results.map({ film in
                    var newFilm = film
                    if newFilm.genre_ids.isEmpty {
                        newFilm.genre_ids.append(0)
                    }
                    newFilm.mainGenre = self.getMainGenre(genreId: newFilm.genre_ids[0])
                    return newFilm
                })
                if !self.sharedInstance.popularityOrder {
                    self.billboard = self.billboard.sorted(by: {$0.mainGenre! < $1.mainGenre!})
                }
                self.page = json.page
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            }
            if case .failure(let error) = resultJSON {
                print(error.description)
            }
        }
        
    }
    
    private func getSearch(query: String) {
        let filmsUrl = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&query=\(query)&page=1")!
        
        getNetworkThrowingData(url: filmsUrl) { data in
            try JSONDecoder().decode(ResponseFilms.self, from: data)
        } callback: { resultJSON in
            if case .success(let json) = resultJSON {
                self.filtered = json.results.map({ film in
                    var newFilm = film
                    if newFilm.genre_ids.isEmpty {
                        newFilm.genre_ids.append(0)
                    }
                    newFilm.mainGenre = self.getMainGenre(genreId: newFilm.genre_ids[0])
                    return newFilm
                })
                if !self.sharedInstance.popularityOrder {
                    self.filtered = self.filtered.sorted(by: {$0.mainGenre! < $1.mainGenre!})
                } else {
                    self.filtered = self.filtered.sorted(by: {$0.popularity! > $1.popularity!})
                }
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            }
            if case .failure(let error) = resultJSON {
                print(error.description)
            }
        }
    }
    
    private func getMainGenre(genreId: Int) -> String {
        let filteredGenre = sharedInstance.genres.filter { i in
            i.id == genreId
        }
        if filteredGenre.isEmpty {
            return "Desconocido"
        }
        return filteredGenre[0].name
    }

}
