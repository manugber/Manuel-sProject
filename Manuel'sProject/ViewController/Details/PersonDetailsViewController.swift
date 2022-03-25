//
//  PersonDetailsViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 24/3/22.
//

import UIKit

class PersonDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    enum CellType: String, CaseIterable {
        case labelCellId = "CellTypeII"
        case imageCellId = "CellTypeIII"
        case collectionViewCellId = "CellTypeV"
        case titleSubtitleCellID = "CellTypeVII"
    }
    
    var person: Cast?
    var personDetails: PersonDetails?
    var relatedFilms = [Film]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = person?.name
        table.delegate = self
        table.dataSource = self
        CellType.allCases.forEach({ caseType in
            let nibCell = UINib(nibName: caseType.rawValue, bundle: nil)
            table.register(nibCell, forCellReuseIdentifier: caseType.rawValue)
        })
        loadRelatedFilms()
        loadPersonDetails()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = typeOfId(indexPath: indexPath)
        let cell = table.dequeueReusableCell(withIdentifier: id, for: indexPath)
        switch indexPath.item {
        case 1:
            let cellType = cell as! CellTypeII
            cellType.cellLabel.text = person?.name
            cellType.cellLabel.textAlignment = .center
            cellType.cellLabel.font = .boldSystemFont(ofSize: 23)
            return cellType
        case 2:
            let cellType = cell as! CellTypeII
            cellType.cellLabel.text = personDetails?.biography
            cellType.cellLabel.textAlignment = .justified
            cellType.cellLabel.font = .systemFont(ofSize: 17)
            return cellType
            
        case 3:
            let cellType = cell as! CellTypeVII
            cellType.title.text = "Profesión:"
            cellType.subtitle.text = personDetails?.knownForDepartment
            return cellType
        case 4:
            let cellType = cell as! CellTypeVII
            cellType.title.text = "Año de nacimiento:"
            cellType.subtitle.text = personDetails?.birthday
            return cellType
        case 5:
            let cellType = cell as! CellTypeVII
            cellType.title.text = "Lugar de nacimiento:"
            cellType.subtitle.text = personDetails?.placeOfBirth
            return cellType
        case 6:
            let cellType = cell as! CellTypeV
            cellType.linkController(controller: self)
            cellType.person = person
            cellType.relatedFilms = relatedFilms
            return cellType
        default:
            let cellType = cell as! CellTypeIII
            if let path = person?.profilePath {
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
                            cellType.cellImage.image = UIImage(systemName: "person")!
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
        case 6:
            return 320
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
    }
    
    func pushView(view: FilmDetailsViewController) {
        navigationController?.pushViewController(view, animated: true)
    }
    
    private func typeOfId(indexPath: IndexPath) -> String {
        switch indexPath.item {
        case 0:
            return CellType.imageCellId.rawValue
        case 1, 2:
            return CellType.labelCellId.rawValue
        case 6:
            return CellType.collectionViewCellId.rawValue
        default:
            return CellType.titleSubtitleCellID.rawValue
        }
    }

    private func loadPersonDetails() {
        let url = URL(string: "https://api.themoviedb.org/3/person/\(person?.id ?? 0 )?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES")!
        getNetworkThrowingData(url: url) { data in
            try JSONDecoder().decode(PersonDetails.self, from: data)
        } callback: { resultJSON in
            if case .success(let json) = resultJSON {
                self.personDetails = json
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            }
            if case .failure(let error) = resultJSON {
                print(error.description)
            }
        }
    }
    
    private func loadRelatedFilms() {
        let url = URL(string: "https://api.themoviedb.org/3/person/\(person?.id ?? 0)/movie_credits?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES")!
        
        getNetworkThrowingData(url: url) { data in
            try JSONDecoder().decode(ResponseRelatedFilms.self, from: data)
        } callback: { resultJSON in
            if case .success(let json) = resultJSON {
                self.relatedFilms = json.cast
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
