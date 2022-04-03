//
//  ModelLogic.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 1/4/22.
//

import Foundation
import UIKit
import YouTubePlayerKit

final class ModelLogic {
    
    enum Orden: String {
        case genre = "Género"
        case popularity = "Popularidad"
    }
    
    private init() { }
    
    static let shared = ModelLogic()
    
    var billboard = Films()
    var favourites = Films()
    var search = Films()
    var query = ""
    var genres = [Genre]()
    var page = 0
    var onlyFavs = false
    var leftBarButtonTitle: Orden = .popularity
    
    var films: Films {
        if onlyFavs {
            return favourites
        } else {
            if query.isEmpty {
                return billboard
            } else {
                return search
            }
        }
    }
    
    var snapshot: NSDiffableDataSourceSnapshot<Genre, Film> {
        var snapshot = NSDiffableDataSourceSnapshot<Genre, Film>()
        snapshot.appendSections(genres)
        if leftBarButtonTitle == .genre {
            snapshot.appendItems(films.sorted(by: { x, y in
                if let popX = x.popularity, let popY = y.popularity {
                    return popX > popY
                }
                if x.popularity == nil { return true }
                return false
            }))
        } else {
            genres.forEach { genre in
                snapshot.appendItems(films.filter { $0.genreIDS[0] == genre.id }, toSection: genre)
            }
        }
        return snapshot
    }
    
    func loadGenres() async {
        do {
            genres = try await networkGetGenres()
        } catch {
            print("error en la descarga \(error)")
        }
    }
    
    func loadFilms() async {
        do {
            billboard = try await networkGetFilms(page: page)
            billboard = films.map({ film in
                var newFilm = film
                newFilm.mainGenre = getMainGenre(genreId: film.genreIDS[0])
                newFilm.genres = getGenres(ids: newFilm.genreIDS)
                newFilm.isFavourite = isFavourite(film: newFilm)
                return newFilm
            })
        } catch {
            print("error en la descarga \(error)")
        }
    }
    
    func getCredits(id: Int) async -> (Cast, Cast) {
        let mainActor, director: Cast
        do {
            let credits = try await networkGetCredits(id: id)
            let filtered = credits.crew.filter { i in
                i.job == "Director"
            }
            if filtered.isEmpty {
                director = Cast(id: 0, name: "Desconocido", profilePath: nil, job: "Director")
            } else {
                director = filtered[0]
            }
            if credits.cast.isEmpty {
                mainActor = Cast(id: 0, name: "Desconocido", profilePath: nil, job: nil)
            } else {
                mainActor = credits.cast[0]
            }
        } catch {
            print("error en la descarga \(error)")
            mainActor = Cast(id: 0, name: "Desconocido", profilePath: nil, job: nil)
            director = Cast(id: 0, name: "Desconocido", profilePath: nil, job: "Director")
        }
        return (director, mainActor)
    }
    
    func getRecomendedFilms(id: Int) async -> Films {
        var recomendedFilms = Films()
        do {
            recomendedFilms = try await networkGetRecomendedFilms(id: id)
            recomendedFilms = recomendedFilms.map({ film in
                var newFilm = film
                newFilm.mainGenre = getMainGenre(genreId: film.genreIDS[0])
                newFilm.genres = getGenres(ids: newFilm.genreIDS)
                newFilm.isFavourite = isFavourite(film: newFilm)
                return newFilm
            })
        } catch {
            print("error en la descarga \(error)")
        }
        return recomendedFilms
    }
    
    func getPersonDetails(id: Int) async -> PersonDetails {
        do {
            return try await networkGetPersonDetails(id: id)
        } catch {
            print("error en la descarga \(error)")
            return PersonDetails(biography: "", birthday: "Desconocido", knownForDepartment: "Desconocido", placeOfBirth: "Desconocido")
        }
    }
    
    func getRelatedFilms(id: Int) async -> Films {
        var relatedFilms = Films()
        do {
            relatedFilms = try await networkGetRelatedFilms(id: id)
            relatedFilms = relatedFilms.map({ film in
                var newFilm = film
                newFilm.mainGenre = getMainGenre(genreId: film.genreIDS[0])
                newFilm.genres = getGenres(ids: newFilm.genreIDS)
                newFilm.isFavourite = isFavourite(film: newFilm)
                return newFilm
            })
        } catch {
            print("error en la descarga \(error)")
        }
        return relatedFilms
    }
    
    func getTrailer(id: Int) async -> YouTubePlayerViewController? {
        do {
            let videos = try await networkGetTrailer(id: id)
            if !videos.isEmpty {
                if videos[0].site == "YouTube" {
                    let youTubePlayer = YouTubePlayer(source: .video(id: videos[0].key), configuration: .init(autoPlay: true))
                    return await YouTubePlayerViewController(player: youTubePlayer)
                }
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    func loadSearch() async{
        do {
            search = try await networkGetSearch(query: query)
            search = films.map({ film in
                var newFilm = film
                newFilm.mainGenre = getMainGenre(genreId: film.genreIDS[0])
                newFilm.genres = getGenres(ids: newFilm.genreIDS)
                newFilm.isFavourite = isFavourite(film: newFilm)
                return newFilm
            })
        } catch {
            print("error en la descarga \(error)")
        }
    }
    
    func filmFavourited(film: Film) {
        if favourites.contains(film) {
            favourites.removeAll { i in
                return i.id == film.id
            }
            if query.isEmpty {
                billboard = billboard.map({ i in
                    var newI = i
                    if i.id == film.id {
                        newI.isFavourite = false
                    }
                    return newI
                })
            } else {
                search = search.map({ i in
                    var newI = i
                    if i.id == film.id {
                        newI.isFavourite = false
                        favourites.append(newI)
                    }
                    return newI
                })
            }
        } else {
            if query.isEmpty {
                billboard = billboard.map({ i in
                    var newI = i
                    if i.id == film.id {
                        newI.isFavourite = true
                        favourites.append(newI)
                    }
                    return newI
                })
            } else {
                search = search.map({ i in
                    var newI = i
                    if i.id == film.id {
                        newI.isFavourite = true
                        favourites.append(newI)
                    }
                    return newI
                })
            }
        }
    }
    
    func isFavourite(film: Film) -> Bool {
        return favourites.contains(where: { i in
            i.id == film.id
        })
        
    }
    
    private func getMainGenre(genreId: Int) -> String {
        let filteredGenre = genres.filter { i in
            i.id == genreId
        }
        return filteredGenre[0].name
    }
    
    private func getGenres(ids: [Int]) -> String {
        var result = ""
        for id in ids {
            let genreFiltered = modelLogic.genres.filter({ i in
                i.id == id
            })
            result += "\(genreFiltered[0].name), "
        }
        return String(result.dropLast(2))
    }
}
