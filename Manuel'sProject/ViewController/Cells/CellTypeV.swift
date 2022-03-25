//
//  CellTypeV.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 11/3/22.
//

import UIKit

class CellTypeV: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    
    let cellTypeIId = "collectionCellTypeI"
    var relatedFilms = [Film]()
    var sharedInstance = DataController.instance
    var film: Film?
    var person: Cast?
    var filmDetailsController: FilmDetailsViewController?
    var personDetailsController: PersonDetailsViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        let nibCellTypeI = UINib(nibName: "CollectionCellTypeI", bundle: nil)
        collectionView.register(nibCellTypeI, forCellWithReuseIdentifier: cellTypeIId)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let secureFilm = film {
            label.text = "Más películas como \(secureFilm.title)"
        }
        if let securePerson = person {
            label.text = "Más películas de \(securePerson.name)"
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellTypeIId, for: indexPath) as! CollectionCellTypeI
        
        cell.filmTitle.text = relatedFilms[indexPath.item].title
        if let path = relatedFilms[indexPath.item].poster_path {
            let url = URL(string: "https://image.tmdb.org/t/p/w400\(path)")!
            
            getNetworkData(url: url) { data in
                UIImage(data: data)
            } callback: { resultImage in
                if case .success(let image) = resultImage {
                    DispatchQueue.main.async {
                        cell.filmImage.image = image
                    }
                }
                if case .failure(let error) = resultImage {
                    print(error.description)
                    DispatchQueue.main.async {
                        cell.filmImage.image = UIImage(systemName: "film")!
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        relatedFilms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let instance = FilmDetailsViewController(film: relatedFilms[indexPath.item])
        if let controller = filmDetailsController {
            controller.pushView(view: instance)
        }
        if let controller = personDetailsController {
            controller.pushView(view: instance)
        }
    }
    
    func linkController(controller: FilmDetailsViewController) {
        self.filmDetailsController = controller
    }
    
    func linkController(controller: PersonDetailsViewController) {
        self.personDetailsController = controller
    }
    
}
