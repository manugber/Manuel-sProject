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
    var relatedByDirector = [Film]()
    var relatedByActor = [Film]()
    
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
    
    init(film: Film, billboard: [Film]) {
        self.film = film
        self.billboard = billboard
        super.init(nibName: "DetailsViewController", bundle: nil)
        relatedFilms(director: film.director, mainActor: film.mainActor)
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
            cellType.cellLabel.text = film.genre
            cellType.cellLabel.textColor = .lightGray
            return cellType
            
        case 3:
            let cellType = cell as! CellTypeII
            cellType.cellLabel.text = film.description
            return cellType
        case 4:
            let cellType = cell as! CellTypeIV
            cellType.indicatorLabel.text = "Director:"
            cellType.personLabel.text = film.director
            return cellType
        case 5:
            let cellType = cell as! CellTypeIV
            cellType.indicatorLabel.text = "Actor principal:"
            cellType.personLabel.text = film.mainActor
            return cellType
        case 6:
            let cellType = cell as! CellTypeV
            cellType.linkController(controller: self)
            cellType.film = film
            cellType.billboard = billboard
            cellType.controller = self
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
            cellType.relatedFilms = relatedByActor
            cellType.director = false
            return cellType
        default:
            let cellType = cell as! CellTypeIII
            cellType.cellImage.image = UIImage(named: film.image)
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
        print("aquí tambien")
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
    
    private func relatedFilms(director: String, mainActor: String) {
        relatedByDirector = billboard.filter({ i in
            film != i && i.director == film.director
        })
        relatedByActor = billboard.filter({i in
            film != i && i.mainActor == film.mainActor
        })
    }

}
