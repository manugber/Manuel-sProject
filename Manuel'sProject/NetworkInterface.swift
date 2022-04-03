//
//  NetworkInterface.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 1/4/22.
//

import Foundation

enum HTTPMethods:String {
    case post = "POST", get = "GET", put = "PUT", delete = "DELETE"
}

extension URL {
    static let filmsBaseURL = URL(string: "https://api.themoviedb.org/3/")!
    static let imageBaseURL = URL(string: "https://image.tmdb.org/t/p/w400")!
    static let getGenres = URL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES")!
    
    //    static let getGenres = filmsBaseURL.appendingPathComponent("genre/movie/list?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES")
    //    static let getFilms = filmsBaseURL.appendingPathComponent("movie/popular?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&page=\(page)")
    //    static let getSearch = filmsBaseURL.appendingPathComponent("search/movie?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&query=\(query)&page=1")
    //    static let getSearch = filmsBaseURL.appendingPathComponent("search/movie?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&query=\(query)&page=1")
    
}

extension String {
    static let getFilms = "https://api.themoviedb.org/3/discover/movie?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&sort_by=popularity.desc&page="
    static let getCredits = "/credits?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES"
    static let getRecomendedFilms = "/recommendations?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&page=1"
    static let getRelatedFilms = "/movie_credits?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&page=1"
    static let getPersonDetails = "?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES"
    static let getTrailer = "/videos?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES"
    static let getSearch = "https://api.themoviedb.org/3/search/movie?api_key=0aa458f7c8179e3b827ce1a10e9e6482&language=es-ES&query="
}

extension URLRequest {
    static func request(url:URL, method:HTTPMethods = .get) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}

