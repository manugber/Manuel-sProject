//
//  CellTypeV.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 11/3/22.
//

import UIKit

final class CellTypeV: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    
    let cellTypeIId = "collectionCellTypeI"
    var films = Films()
    var film: Film?
    var filmDetailsController: FilmDetailsViewController?
    var person: Cast?
    var personDetailsController: PersonDetailsViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        let nibCellTypeI = UINib(nibName: "CollectionCellTypeI", bundle: nil)
        collectionView.register(nibCellTypeI, forCellWithReuseIdentifier: cellTypeIId)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellTypeIId, for: indexPath) as! CollectionCellTypeI
        
        cell.filmTitle.text = films[indexPath.item].title
        if let path = films[indexPath.item].posterPath {
            Task { cell.filmImage.image = await getFilmImage(path: path) }
        } else {
            Task { cell.filmImage.image = UIImage(systemName: "film") }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        films.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let instance = FilmDetailsViewController(nibName: "FilmDetailsViewController", bundle: nil)
        instance.film = films[indexPath.item]
        if let controller = filmDetailsController {
            controller.pushView(view: instance)
        }
        if let controller = personDetailsController {
            controller.pushView(view: instance)
        }
    }
    
    func linkController(controller: FilmDetailsViewController) {
        self.filmDetailsController = controller
        if let secureFilm = film {
            label.text = "Más películas como \(secureFilm.title)"
        }
    }
    
    func linkController(controller: PersonDetailsViewController) {
        self.personDetailsController = controller
        if let securePerson = person {
            label.text = "Más películas de \(securePerson.name)"
        }
    }
    
}
