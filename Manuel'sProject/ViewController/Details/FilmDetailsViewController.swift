//
//  DetailsViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 8/3/22.
//

import UIKit
import AVKit
import AVFoundation
import YouTubePlayerKit

class FilmDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    enum CellType: String, CaseIterable {
        case labelCellId = "CellTypeII"
        case imageCellId = "CellTypeIII"
        case actorDirectorCellId = "CellTypeIV"
        case collectionViewCellId = "CellTypeV"
        case trailerCellId = "CellTypeVI"
    }
    
    let film: Film
    var sharedInstance = DataController.instance
    var trailer: String?
    var recommendedFilms = [Film]()
    var director, mainActor: Cast
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = film.title
        table.delegate = self
        table.dataSource = self
        CellType.allCases.forEach({ caseType in
            let nibCell = UINib(nibName: caseType.rawValue, bundle: nil)
            table.register(nibCell, forCellReuseIdentifier: caseType.rawValue)
        })
        loadCredits()
    }
    
    init(film: Film) {
        self.film = film
        director = Cast(id: 0, name: "Cargando", profilePath: nil, job: "Director")
        mainActor = Cast(id: 0, name: "Cargando", profilePath: nil, job: nil)
        super.init(nibName: "FilmDetailsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recommendedFilms.count == 0 {
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
            cellType.cellLabel.textAlignment = .justified
            cellType.cellLabel.font = .systemFont(ofSize: 17)
            return cellType
        case 4:
            let cellType = cell as! CellTypeIV
            cellType.indicatorLabel.text = "Director:"
            cellType.personLabel.text = director.name
            if let safeProfile = director.profilePath {
                let url = URL(string: "https://image.tmdb.org/t/p/w200\(safeProfile)")!
                
                getNetworkData(url: url) { data in
                    UIImage(data: data)
                } callback: { resultImage in
                    if case .success(let image) = resultImage {
                        DispatchQueue.main.async {
                            cellType.personImage.image = image
                        }
                    }
                    if case .failure(let error) = resultImage {
                        print(error.description)
                        DispatchQueue.main.async {
                            cellType.personImage.image = UIImage(systemName: "film")!
                        }
                    }
                }
            }
            cellType.personImage.layer.cornerRadius = cellType.personImage.frame.height / 2
            cellType.personImage.layer.masksToBounds = true
            return cellType
        case 5:
            let cellType = cell as! CellTypeIV
            cellType.indicatorLabel.text = "Actor principal:"
            cellType.personLabel.text = mainActor.name
            if let safeProfile = mainActor.profilePath {
                let url = URL(string: "https://image.tmdb.org/t/p/w200\(safeProfile)")!
                
                getNetworkData(url: url) { data in
                    UIImage(data: data)
                } callback: { resultImage in
                    if case .success(let image) = resultImage {
                        DispatchQueue.main.async {
                            cellType.personImage.image = image
                        }
                    }
                    if case .failure(let error) = resultImage {
                        print(error.description)
                        DispatchQueue.main.async {
                            cellType.personImage.image = UIImage(systemName: "film")!
                        }
                    }
                }
            }
            cellType.personImage.layer.cornerRadius = cellType.personImage.frame.height / 2
            cellType.personImage.layer.masksToBounds = true
            return cellType
        case 6:
            let cellType = cell as! CellTypeVI
            cellType.linkController(controller: self)
            return cellType
        case 7:
            let cellType = cell as! CellTypeV
            cellType.linkController(controller: self)
            cellType.film = film
            cellType.relatedFilms = recommendedFilms
            return cellType
        default:
            let cellType = cell as! CellTypeIII
            if let path = film.poster_path {
                let url = URL(string: "https://image.tmdb.org/t/p/w400\(path)")!
                
                getNetworkData(url: url) { data in
                    UIImage(data: data)
                } callback: { resultImage in
                    if case .success(let image) = resultImage {
                        DispatchQueue.main.async {
                            cellType.cellImage.image = image
                        }
                    }
                    if case .failure(let error) = resultImage {
                        print(error.description)
                        DispatchQueue.main.async {
                            cellType.cellImage.image = UIImage(systemName: "film")!
                        }
                    }
                }
            }
            return cellType
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.item {
        case 0:
            return 400
        case 4, 5:
            return 100
        case 6:
            return 44
        case 7:
            return 320
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        if indexPath.item == 4 {
            let instance = PersonDetailsViewController(nibName: "PersonDetailsViewController", bundle: nil)
            instance.person = director
            navigationController?.pushViewController(instance, animated: true)
        }
        if indexPath.item == 5 {
            let instance = PersonDetailsViewController(nibName: "PersonDetailsViewController", bundle: nil)
            instance.person = mainActor
            navigationController?.pushViewController(instance, animated: true)
        }
    }
    
    func pushView(view: FilmDetailsViewController) {
        navigationController?.pushViewController(view, animated: true)
    }
    
    private func typeOfId(indexPath: IndexPath) -> String {
        switch indexPath.item {
        case 0:
            return CellType.imageCellId.rawValue
        case 4, 5:
            return CellType.actorDirectorCellId.rawValue
        case 6:
            return CellType.trailerCellId.rawValue
        case 7, 8:
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

    private func loadCredits() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(film.id)/credits?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES")!
        
        getNetworkThrowingData(url: url) { data in
            try JSONDecoder().decode(Credits.self, from: data)
        } callback: { resultJSON in
            if case .success(let json) = resultJSON {
                let filtered = json.crew.filter { i in
                    i.job == "Director"
                }
                if filtered.isEmpty {
                    self.director = Cast(id: 0, name: "Desconocido", profilePath: nil, job: "Director")
                } else {
                    self.director = filtered[0]
                }
                if json.cast.isEmpty {
                    self.mainActor = Cast(id: 0, name: "Desconocido", profilePath: nil, job: nil)
                } else {
                    self.mainActor = json.cast[0]
                }
                DispatchQueue.main.async {
                    self.loadRecommendedFilms()
                    self.table.reloadData()
                }
            }
            if case .failure(let error) = resultJSON {
                print(error.description)
            }
        }
    }
    
    func loadTrailer() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(film.id)/videos?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES")!
        
        getNetworkThrowingData(url: url) { data in
            try JSONDecoder().decode(ResponseTrailer.self, from: data)
        } callback: { resultJSON in
            if case .success(let json) = resultJSON {
                if !json.results.isEmpty {
                    if json.results[0].site == "YouTube" {
                        DispatchQueue.main.async {
                            let youTubePlayer = YouTubePlayer(source: .video(id: json.results[0].key), configuration: .init(autoPlay: true))
                            let youTubePlayerViewController = YouTubePlayerViewController(player: youTubePlayer)
                            self.present(youTubePlayerViewController, animated: true)
                        }
                    }
                }
            }
            if case .failure(let error) = resultJSON {
                print(error.description)
            }
        }
    }
    
    private func loadRecommendedFilms() {
        
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(film.id)/recommendations?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&page=1")!
        
        getNetworkThrowingData(url: url) { data in
            try JSONDecoder().decode(ResponseFilms.self, from: data)
        } callback: { resultJSON in
            if case .success(let json) = resultJSON {
                self.recommendedFilms = json.results
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            }
            if case .failure(let error) = resultJSON {
                print(error.description)
            }
        }
       
    }

}
