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
    var billboard = [Film]()
    var mainActor = Cast(id: 0, name: "", profile_path: nil)
    var director = Crew(id: 0, name: "", profile_path: nil, job: "Director")
    var film = Film(genre_ids: [1], id: 1, overview: "", popularity: 1.0, poster_path: "", release_date: "", title: "")
    var controller: DetailsViewController?
    var isDirector: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadImages { image in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
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
        if isDirector {
            label.text = "Más de \(director.name)"
        } else {
            label.text = "Más de \(mainActor.name)"
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellTypeIId, for: indexPath) as! CollectionCellTypeI
        
        cell.filmTitle.text = relatedFilms[indexPath.item].title
        cell.filmImage.image = sharedInstance.images[film.id]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        relatedFilms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let instance = DetailsViewController(film: relatedFilms[indexPath.item], billboard: billboard)
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
    
    func loadImages(completionHandler: @escaping ([UIImage]) -> Void) {
        for film in relatedFilms {
            print("entro")
            if let path = film.poster_path {
                let data = try? Data(contentsOf: URL(string: "https://image.tmdb.org/t/p/w400\(path)")!)
                self.sharedInstance.images[film.id] = UIImage(data: data!)!
            } else {
                self.sharedInstance.images[film.id] = UIImage(systemName: "film")!
            }
            
        }
    }
}
