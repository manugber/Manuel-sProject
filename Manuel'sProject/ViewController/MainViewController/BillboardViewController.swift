//
//  BillboardViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 18/3/22.
//

import UIKit

class BillboardViewController: MainViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setNavigationBar()
        loadGenres()
        loadData(pageToView: page) { (films) in
            DispatchQueue.main.async {
                self.table.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
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
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" || searchBar.text == nil {
            sharedInstance.searchActive = false
            table.reloadData()
        } else {
            sharedInstance.searchActive = true
            let b = searchBar.text!.lowercased().folding(options: .diacriticInsensitive, locale: .current)
            let query = b.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            getSearch(query: query!) { (films) in
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        sharedInstance.searchActive = true
        filtered = []
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
            activityIndicator.startAnimating()
            loadData(pageToView: page+1) { (films) in
                DispatchQueue.main.async {
                    self.table.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    @objc private func pressedPrevButton() {
        if page > 1 {
            if !sharedInstance.searchActive {
                activityIndicator.startAnimating()
                loadData(pageToView: page-1) { (films) in
                    DispatchQueue.main.async {
                        self.table.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    private func loadGenres() {
        
        let genreUrl = URL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES")
        var genreRequest = URLRequest(url: genreUrl!)
        genreRequest.httpMethod = "GET"
        genreRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: genreRequest, completionHandler: { data, response, error -> Void in
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(ResponseGenres.self, from: data!)
                self.sharedInstance.genres = json.genres
                self.sharedInstance.genres.append(Genre(id: 0, name: "Desconocido"))
                self.sharedInstance.genres = self.sharedInstance.genres.sorted(by: {$0.name < $1.name})
                self.sharedInstance.genres.forEach { genre in
                    self.sharedInstance.filmsForGenre.append(0)
                }
            } catch {
                print(error)
            }
        }).resume()
    }
    
    private func loadData(pageToView: Int, completionHandler: @escaping ([Film]) -> Void) {
        
        let filmsUrl = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&sort_by=popularity.desc&page=\(pageToView)")
        var filmRequest = URLRequest(url: filmsUrl!)
        filmRequest.httpMethod = "GET"
        filmRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: filmRequest, completionHandler: { (data, response, error) in
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(ResponseFilms.self, from: data!)
                self.billboard = json.results.map({ film in
                    var newFilm = film
                    if newFilm.genre_ids.isEmpty {
                        newFilm.genre_ids.append(0)
                    }
                    newFilm.mainGenre = self.getMainGenre(genreId: newFilm.genre_ids[0])
                    self.loadImage(film: newFilm)
                    return newFilm
                })
                if !self.sharedInstance.popularityOrder {
                    self.billboard = self.billboard.sorted(by: {$0.mainGenre! < $1.mainGenre!})
                }
                self.page = json.page
                completionHandler(json.results)
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    private func getSearch(query: String, completionHandler: @escaping ([Film]) -> Void) {
        let filmsUrl = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&query=\(query)&page=1")
        var filmRequest = URLRequest(url: filmsUrl!)
        filmRequest.httpMethod = "GET"
        filmRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: filmRequest, completionHandler: { (data, response, error) in
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(ResponseFilms.self, from: data!)
                self.filtered = json.results.map({ film in
                    var newFilm = film
                    if newFilm.genre_ids.isEmpty {
                        newFilm.genre_ids.append(0)
                    }
                    newFilm.mainGenre = self.getMainGenre(genreId: newFilm.genre_ids[0])
                    self.loadImage(film: newFilm)
                    return newFilm
                })
                if !self.sharedInstance.popularityOrder {
                    self.filtered = self.filtered.sorted(by: {$0.mainGenre! < $1.mainGenre!})
                }
                completionHandler(json.results)
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    private func loadImage(film: Film) {
        if let path = film.poster_path {
            let data = try? Data(contentsOf: URL(string: "https://image.tmdb.org/t/p/w400\(path)")!)
            self.sharedInstance.images[film.id] = UIImage(data: data!)!
        } else {
            self.sharedInstance.images[film.id] = UIImage(systemName: "film")!
        }
    }
    
    private func getMainGenre(genreId: Int) -> String {
        let filteredGenre = sharedInstance.genres.filter { i in
            i.id == genreId
        }
        return filteredGenre[0].name
    }

}
