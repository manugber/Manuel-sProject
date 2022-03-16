//
//  DetailsViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    let cellTypeIIId = "cellTypeII"
    let cellTypeIIIId = "cellTypeIII"
    let cellTypeIVId = "cellTypeIV"
    let cellTypeVId = "cellTypeV"
    var film: Film
    var billboard: [Film]
    var genres: [Genre]
    var relatedByDirector = [Film]()
    var relatedByActor = [Film]()
    var credits = Credits(id: 0, cast: [Cast(id: 1, name: "", profile_path: "")], crew: [Crew(id: 1, name: "", job: "Director")])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = film.title
        table.delegate = self
        table.dataSource = self
        let nibCellTypeII = UINib(nibName: "CellTypeII", bundle: nil)
        table.register(nibCellTypeII, forCellReuseIdentifier: cellTypeIIId)
//        table.register(ImageHeader.self,
//               forHeaderFooterViewReuseIdentifier: "header")
        let nibCellTypeIII = UINib(nibName: "CellTypeIII", bundle: nil)
        table.register(nibCellTypeIII, forCellReuseIdentifier: cellTypeIIIId)
//        let nibHeader = UINib(nibName: "ImageHeader", bundle: nil)
//        table.register(nibHeader, forHeaderFooterViewReuseIdentifier: "header")
        let nibCellTypeIV = UINib(nibName: "CellTypeIV", bundle: nil)
        table.register(nibCellTypeIV, forCellReuseIdentifier: cellTypeIVId)
        let nibCellTypeV = UINib(nibName: "CellTypeV", bundle: nil)
        table.register(nibCellTypeV, forCellReuseIdentifier: cellTypeVId)
    }
    
    init(film: Film, billboard: [Film], genres: [Genre]) {
        self.film = film
        self.billboard = billboard
        self.genres = genres
        super.init(nibName: "DetailsViewController", bundle: nil)
        print("entro")
        loadCredits()
        print("salgo")
//        relatedFilms(director: film.director, mainActor: film.mainActor)
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
            return cellType
        case 4:
            let cellType = cell as! CellTypeIV
            cellType.indicatorLabel.text = "Director:"
            cellType.personLabel.text = findDirector()
            return cellType
        case 5:
            let cellType = cell as! CellTypeIV
            cellType.indicatorLabel.text = "Actor principal:"
            cellType.personLabel.text = credits.cast[0].name
            return cellType
        case 6:
            let cellType = cell as! CellTypeV
            cellType.linkController(controller: self)
            cellType.film = film
            cellType.billboard = billboard
            cellType.controller = self
            cellType.genres = genres
            if relatedByDirector.count != 0 {
                cellType.relatedFilms = relatedByDirector
                cellType.director = true
            } else {
                cellType.relatedFilms = relatedByActor
                cellType.director = false
            }
            return cellType
        case 7:
            let cellType = cell as! CellTypeV
            cellType.linkController(controller: self)
            cellType.film = film
            cellType.billboard = billboard
            cellType.controller = self
            cellType.genres = genres
            cellType.relatedFilms = relatedByActor
            cellType.director = false
            return cellType
        default:
            let cellType = cell as! CellTypeIII
            let data = try? Data(contentsOf: URL(string: "https://image.tmdb.org/t/p/original\(film.poster_path)")!)
            cellType.cellImage.image = UIImage(data: data!)
            return cellType
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.item {
        case 0:
            return 400
        case 6, 7:
            return 300
        default:
            return UITableView.automaticDimension
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = table.dequeueReusableHeaderFooterView(withIdentifier: "header") as! ImageHeader
//        view.theView.imageHeader.image = UIImage(systemName: elemento.image)
//        return view
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 300
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
    }
    
    func pushView(view: DetailsViewController) {
        navigationController?.pushViewController(view, animated: true)
    }
    
    private func typeOfId(indexPath: IndexPath) -> String {
        switch indexPath.item {
        case 0:
            return cellTypeIIIId
        case 4, 5:
            return cellTypeIVId
        case 6, 7:
            return cellTypeVId
        default:
            return cellTypeIIId
        }
    }
    
    private func findDirector() -> String {
        print(credits.cast.count) //printea uno porque aún no se han cargado los datos del json
        let filtered = credits.crew.filter { i in
            i.job == "Director"
        }
        return filtered[0].name
    }
    
    private func getGenres(ids: [Int]) -> String {
        var result = ""
        for id in ids {
            let genreFiltered = genres.filter({ i in
                i.id == id
            })
            result += "\(genreFiltered[0].name), "
        }
        
        return String(result.dropLast(2))
    }

    
    private func loadCredits() {
        let url = "https://api.themoviedb.org/3/movie/\(film.id)/credits?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(Credits.self, from: data!)
                self.credits = json
            } catch {
                print("error1")
            }
        }).resume()
    }
    
    private func relatedFilms(director: String, mainActor: String) {
//        relatedByDirector = billboard.filter({ i in
//            film != i && i.director == film.director
//        })
//        relatedByActor = billboard.filter({i in
//            film != i && i.mainActor == film.mainActor
//        })
    }

}
