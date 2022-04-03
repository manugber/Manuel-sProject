//
//  NetworkPersistence.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 1/4/22.
//

import Foundation
import UIKit

func networkGetGenres() async throws -> [Genre] {
    let (data, response) = try await URLSession.shared.data(for: .request(url: .getGenres))
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    var json = try JSONDecoder().decode(ResponseGenres.self, from: data)
    json.genres.append(Genre(id: 0, name: "Desconocido"))
    return json.genres
}

func networkGetFilms(page: Int) async throws -> Films {
    var result = Films()
    for i in 1...5 {
        let (data, response) = try await URLSession.shared.data(for: .request(url: URL(string: .getFilms + "\(i + page)")!))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let json = try JSONDecoder().decode(ResponseFilms.self, from: data)
        result += json.results
    }
    return result.map({ film in
        var newFilm = film
        if newFilm.genreIDS.isEmpty {
            newFilm.genreIDS.append(0)
        }
        return newFilm
    })
}

func networkGetCredits(id: Int) async throws -> Credits {
    let (data, response) = try await URLSession.shared.data(for: .request(url: URL(string: "https://api.themoviedb.org/3/movie/\(id)" + .getCredits)!))
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    return try JSONDecoder().decode(Credits.self, from: data)
}

func networkGetRecomendedFilms(id: Int) async throws -> Films {
    var result = Films()
    let (data, response) = try await URLSession.shared.data(for: .request(url: URL(string: "https://api.themoviedb.org/3/movie/\(id)" + .getRecomendedFilms)!))
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    result = try JSONDecoder().decode(ResponseFilms.self, from: data).results
    return result.map({ film in
        var newFilm = film
        if newFilm.genreIDS.isEmpty {
            newFilm.genreIDS.append(0)
        }
        return newFilm
    })
}

func networkGetPersonDetails(id: Int) async throws -> PersonDetails {
    let (data, response) = try await URLSession.shared.data(for: .request(url: URL(string: "https://api.themoviedb.org/3/person/\(id)" + .getPersonDetails)!))
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    return try JSONDecoder().decode(PersonDetails.self, from: data)
}

func networkGetRelatedFilms(id: Int) async throws -> Films {
    var result = Films()
    let (data, response) = try await URLSession.shared.data(for: .request(url: URL(string: "https://api.themoviedb.org/3/person/\(id)" + .getRelatedFilms)!))
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    result = try JSONDecoder().decode(ResponseRelatedFilms.self, from: data).cast
    return result.map({ film in
        var newFilm = film
        if newFilm.genreIDS.isEmpty {
            newFilm.genreIDS.append(0)
        }
        return newFilm
    })
}

func networkGetTrailer(id: Int) async throws -> [Trailer] {
    let (data, response) = try await URLSession.shared.data(for: .request(url: URL(string: "https://api.themoviedb.org/3/movie/\(id)" + .getTrailer)!))
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    return try JSONDecoder().decode(ResponseTrailer.self, from: data).results
}

func networkGetSearch(query: String) async throws -> Films {
    let (data, response) = try await URLSession.shared.data(for: .request(url: URL(string: .getSearch + query + "&page=1")!))
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    return try JSONDecoder().decode(ResponseFilms.self, from: data).results.map({ film in
        var newFilm = film
        if newFilm.genreIDS.isEmpty {
            newFilm.genreIDS.append(0)
        }
        return newFilm
    })
}

func getFilmImage(path: String) async -> UIImage? {
    do {
        let (data, _) = try await URLSession.shared.data(from: .imageBaseURL.appendingPathComponent(path))
        return UIImage(data: data)?.resizeImage(width: 400)
    } catch {
        print("Error bajando la imagen")
        return nil
    }
}
