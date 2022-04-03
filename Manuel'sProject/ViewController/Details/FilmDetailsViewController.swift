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

final class FilmDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    
    enum CellType: String, CaseIterable {
        case labelCellId = "CellTypeII"
        case imageCellId = "CellTypeIII"
        case actorDirectorCellId = "CellTypeIV"
        case collectionViewCellId = "CellTypeV"
        case trailerCellId = "CellTypeVI"
    }
    
    var film: Film?
    let modelLogic = ModelLogic.shared
    var recommendedFilms = [Film]()
    var director, mainActor: Cast?
    var blurEffectView:UIVisualEffectView!
    var activityIndicator:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        self.title = film?.title
        table.delegate = self
        table.dataSource = self
        CellType.allCases.forEach({ caseType in
            let nibCell = UINib(nibName: caseType.rawValue, bundle: nil)
            table.register(nibCell, forCellReuseIdentifier: caseType.rawValue)
        })
        Task(priority: .high) {
            (director, mainActor) = await modelLogic.getCredits(id: film!.id)
            recommendedFilms = await modelLogic.getRecomendedFilms(id: film!.id)
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
        if recommendedFilms.isEmpty {
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
            cellType.cellLabel.text = film?.title
            cellType.cellLabel.textAlignment = .center
            cellType.cellLabel.font = .boldSystemFont(ofSize: 23)
            return cellType
        case 2:
            let cellType = cell as! CellTypeII
            cellType.cellLabel.text = film?.genres
            cellType.cellLabel.textColor = .lightGray
            return cellType
            
        case 3:
            let cellType = cell as! CellTypeII
            cellType.cellLabel.text = film?.overview
            cellType.cellLabel.textAlignment = .justified
            cellType.cellLabel.font = .systemFont(ofSize: 17)
            return cellType
        case 4:
            let cellType = cell as! CellTypeIV
            cellType.indicatorLabel.text = "Director:"
            cellType.personLabel.text = director?.name
            if let path = director?.profilePath {
                Task { cellType.personImage.image = await getFilmImage(path: path) }
            } else {
                Task { cellType.personImage.image = UIImage(systemName: "person") }
            }
            cellType.personImage.layer.cornerRadius = cellType.personImage.frame.height / 2
            cellType.personImage.layer.masksToBounds = true
            return cellType
        case 5:
            let cellType = cell as! CellTypeIV
            cellType.indicatorLabel.text = "Actor principal:"
            cellType.personLabel.text = mainActor?.name
            if let path = mainActor?.profilePath {
                Task { cellType.personImage.image = await getFilmImage(path: path) }
            } else {
                Task { cellType.personImage.image = UIImage(systemName: "person") }
            }
            cellType.personImage.layer.cornerRadius = cellType.personImage.frame.height / 2
            cellType.personImage.layer.masksToBounds = true
            return cellType
        case 6:
            let cellType = cell as! CellTypeVI
            cellType.controller = self
            return cellType
        case 7:
            let cellType = cell as! CellTypeV
            cellType.film = film
            cellType.films = recommendedFilms
            cellType.linkController(controller: self)
            return cellType
        default:
            let cellType = cell as! CellTypeIII
            if let path = film?.posterPath {
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
        case 4, 5:
            return 100
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
    
    func loadTrailer() {
        Task(priority: .high) {
            if let controller = await modelLogic.getTrailer(id: film!.id) {
                self.present(controller, animated: true)
            }
        }
    }
}
