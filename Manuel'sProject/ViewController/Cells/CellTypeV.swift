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
    var billboard = [Film]()
    var genres = [Genre]()
    var film = Film(genre_ids: [1], id: 1,  overview: "", poster_path: "", release_date: "", title: "")
    var controller: DetailsViewController?
    var director: Bool = false
    
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
        //no deberia
//        if director {
//            label.text = "Más de \(film.director)"
//        } else {
//            label.text = "Más de \(film.mainActor)"
//        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellTypeIId, for: indexPath) as! CollectionCellTypeI
        
        cell.filmTitle.text = relatedFilms[indexPath.item].title
//        cell.filmImage.image = UIImage(named: relatedFilms[indexPath.item].image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        relatedFilms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("entro")
        let instance = DetailsViewController(film: relatedFilms[indexPath.item], billboard: billboard, genres: genres)
        controller!.pushView(view: instance)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 170, height: 230)
    }
    
    func linkController(controller: DetailsViewController) {
        self.controller = controller
    }
    
}
