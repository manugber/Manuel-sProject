//
//  PersonDetailsViewController.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 24/3/22.
//

import UIKit

final class PersonDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    enum CellType: String, CaseIterable {
        case labelCellId = "CellTypeII"
        case imageCellId = "CellTypeIII"
        case collectionViewCellId = "CellTypeV"
        case titleSubtitleCellID = "CellTypeVII"
    }
    
    var person: Cast?
    var personDetails: PersonDetails?
    var relatedFilms = Films()
    var blurEffectView:UIVisualEffectView!
    var activityIndicator:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = person?.name
        table.delegate = self
        table.dataSource = self
        CellType.allCases.forEach({ caseType in
            let nibCell = UINib(nibName: caseType.rawValue, bundle: nil)
            table.register(nibCell, forCellReuseIdentifier: caseType.rawValue)
        })
        Task(priority: .high) {
            personDetails = await modelLogic.getPersonDetails(id: person!.id)
            relatedFilms = await modelLogic.getRelatedFilms(id: person!.id)
            table.reloadData()
            await MainActor.run {
                UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn) {
                    self.blurEffectView.layer.opacity = 0.0
                    self.activityIndicator.layer.opacity = 0.0
                } completion: { _ in
                    self.blurEffectView.removeFromSuperview()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        blurEffectView = UIVisualEffectView()
        activityIndicator = UIActivityIndicatorView(style: .large)

        blur(controller: tabBarController, blurEffectView: blurEffectView, activityIndicator: activityIndicator)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if relatedFilms.isEmpty {
            return 6
        }
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
            cellType.person = person
            cellType.films = relatedFilms
            cellType.linkController(controller: self)
            return cellType
        default:
            let cellType = cell as! CellTypeIII
            if let path = person?.profilePath {
                Task { cellType.cellImage .image = await getFilmImage(path: path) }
            } else {
                Task { cellType.cellImage.image = UIImage(systemName: "film") }
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
}
