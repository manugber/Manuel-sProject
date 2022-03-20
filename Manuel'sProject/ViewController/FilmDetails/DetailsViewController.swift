//
//  DetailsViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    enum CellType: String, CaseIterable {
        case labelCellId = "CellTypeII"
        case imageCellId = "CellTypeIII"
        case actorDirectorCellId = "CellTypeIV"
        case collectionViewCellId = "CellTypeV"
    }
    
    var film: Film
    var billboard: [Film]
    var sharedInstance = DataController.instance
    var images = [UIImage]()
    // no funciona aún (creo que por async)
    var relatedByDirector = [Film]()
    var relatedByActor = [Film]()
    //
    
    var director: Crew
    var mainActor: Cast
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = film.title
        table.delegate = self
        table.dataSource = self
        CellType.allCases.forEach({ caseType in
            let nibCell = UINib(nibName: caseType.rawValue, bundle: nil)
            table.register(nibCell, forCellReuseIdentifier: caseType.rawValue)
        })
        
    }
    
    init(film: Film, billboard: [Film]) {
        self.film = film
        self.billboard = billboard
        director = Crew(id: 0, name: "Cargando", profile_path: nil, job: "Director")
        mainActor = Cast(id: 0, name: "Cargando", profile_path: nil)
        super.init(nibName: "DetailsViewController", bundle: nil)
        loadCredits { credits in
            DispatchQueue.main.async {
                self.loadImages()
                self.relatedFilms()
                self.table.reloadData()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if relatedByActor.count == 0 && relatedByDirector.count == 0 {
            return 6
        } else if relatedByActor.count == 0 && relatedByDirector.count != 0 {
            return 7
        } else if relatedByActor.count != 0 && relatedByDirector.count == 0 {
            return 7
        }
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = typeOfId(indexPath: indexPath)
        let cell = table.dequeueReusableCell(withIdentifier: id, for: indexPath)
        switch indexPath.item {
        case 1:
            let cellType = cell as! CellTypeII
            cellType.cellLabel.text = film.title
            cellType.cellLabel.textAlignment = .center
            cellType.cellLabel.font = .boldSystemFont(ofSize: 23)
            return cellType
        case 2:
            let cellType = cell as! CellTypeII
            cellType.cellLabel.text = getGenres(ids: film.genre_ids)
            cellType.cellLabel.textColor = .lightGray
            return cellType
            
        case 3:
            let cellType = cell as! CellTypeII
            cellType.cellLabel.text = film.overview
            cellType.cellLabel.textAlignment = .left
            cellType.cellLabel.font = .systemFont(ofSize: 17)
            return cellType
        case 4:
            let cellType = cell as! CellTypeIV
            cellType.indicatorLabel.text = "Director:"
            cellType.personLabel.text = director.name
            if !images.isEmpty {
                cellType.personImage.image = images[0]
                cellType.personImage.layer.cornerRadius = cellType.personImage.frame.height / 2
                cellType.personImage.layer.masksToBounds = true
            }
            return cellType
        case 5:
            let cellType = cell as! CellTypeIV
            cellType.indicatorLabel.text = "Actor principal:"
            cellType.personLabel.text = mainActor.name
            if !images.isEmpty {
                cellType.personImage.image = images[1]
                cellType.personImage.layer.cornerRadius = cellType.personImage.frame.height / 2
                cellType.personImage.layer.masksToBounds = true
            }
            return cellType
        //no muestra la collection
        case 6:
            let cellType = cell as! CellTypeV
            cellType.linkController(controller: self)
            cellType.director = director
            cellType.film = film
            cellType.billboard = billboard
            cellType.controller = self
            if relatedByDirector.count != 0 {
                cellType.relatedFilms = relatedByDirector
                cellType.isDirector = true
            } else {
                cellType.relatedFilms = relatedByActor
                cellType.isDirector = false
            }
            return cellType
        //no muestra la collection
        case 7:
            let cellType = cell as! CellTypeV
            cellType.linkController(controller: self)
            cellType.mainActor = mainActor
            cellType.film = film
            cellType.billboard = billboard
            cellType.controller = self
            cellType.relatedFilms = relatedByActor
            cellType.isDirector = false
            return cellType
        default:
            let cellType = cell as! CellTypeIII
            cellType.cellImage.image = sharedInstance.images[film.id]
            return cellType
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.item {
        case 0:
            return 400
        case 4, 5:
            return 100
        case 6, 7:
            return 300
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
    }
    
    func pushView(view: DetailsViewController) {
        navigationController?.pushViewController(view, animated: true)
    }
    
    private func typeOfId(indexPath: IndexPath) -> String {
        switch indexPath.item {
        case 0:
            return CellType.imageCellId.rawValue
        case 4, 5:
            return CellType.actorDirectorCellId.rawValue
        case 6, 7:
            return CellType.collectionViewCellId.rawValue
        default:
            return CellType.labelCellId.rawValue
        }
    }
    
    private func getGenres(ids: [Int]) -> String {
        var result = ""
        for id in ids {
            let genreFiltered = sharedInstance.genres.filter({ i in
                i.id == id
            })
            result += "\(genreFiltered[0].name), "
        }
        
        return String(result.dropLast(2))
    }

    private func loadCredits(completionHandler: @escaping (Credits) -> Void) {
        let url = "https://api.themoviedb.org/3/movie/\(film.id)/credits?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(Credits.self, from: data!)
                let filtered = json.crew.filter { i in
                    i.job == "Director"
                }
                if filtered.isEmpty {
                    self.director = Crew(id: 0, name: "Desconocido", profile_path: nil, job: "Director")
                } else {
                    self.director = filtered[0]
                }
                if json.cast.isEmpty {
                    self.mainActor = Cast(id: 0, name: "Desconocido", profile_path: nil)
                } else {
                    self.mainActor = json.cast[0]
                }
                completionHandler(json)
            } catch {
                print(error)
            }
        })
        
        task.resume()
        
    }
    
    private func loadImages() {
        if let safeProfile = director.profile_path {
            let data = try? Data(contentsOf: URL(string: "https://image.tmdb.org/t/p/w200\(safeProfile)")!)
            images.append(UIImage(data: data!)!)
        } else {
            images.append(UIImage(systemName: "person")!)
        }
        if let safeProfile = mainActor.profile_path {
            let data = try? Data(contentsOf: URL(string: "https://image.tmdb.org/t/p/w200\(safeProfile)")!)
            images.append(UIImage(data: data!)!)
        } else {
            images.append(UIImage(systemName: "person")!)
        }
        table.reloadData()
    }
    
    //no carga películas las relacionadas
    private func relatedFilms() {
        
        let directorUrl = "https://api.themoviedb.org/3/person/\(director.id)/movie_credits?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES"
        var directorRequest = URLRequest(url: URL(string: directorUrl)!)
        directorRequest.httpMethod = "GET"
        directorRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let directorTask = URLSession.shared.dataTask(with: directorRequest, completionHandler: { (data, response, error) in
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(ResponseRelatedFilms.self, from: data!)
                self.relatedByDirector = json.cast
            } catch {
                print(error)
            }
        })
        directorTask.resume()
        
        let actorUrl = "https://api.themoviedb.org/3/person/\(mainActor.id)/movie_credits?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES"
        var actorRequest = URLRequest(url: URL(string: actorUrl)!)
        actorRequest.httpMethod = "GET"
        actorRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let actorTask = URLSession.shared.dataTask(with: actorRequest, completionHandler: { (data, response, error) in
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(ResponseRelatedFilms.self, from: data!)
                self.relatedByActor = json.cast
            } catch {
                print(error)
            }
        })
        actorTask.resume()
        
        print(mainActor.id)
        print(director.id)
        
        //muestra 0
        print(relatedByDirector)
        print(relatedByActor)
    }

}
