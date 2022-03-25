//
//  NetworkLibrary.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 23/3/22.
//

import Foundation

enum NetworkErrors: Error {
    case general(Error)
    case statusCode(Int)
    case buildFailure(String)
    case generic
    
    var description: String {
        switch self {
        case .general(let error):
            return "error general: \(error)"
        case .statusCode(let error):
            return "error de status: \(error)"
        case .buildFailure(let msg):
            return "el constructor ha fallado: \(msg)"
        case .generic:
            return "error genérico"
        }
    }
}

func getNetworkData<Recieved>(url: URL,
                              builder: @escaping (Data) -> Recieved?,
                              callback: @escaping (Result<Recieved, NetworkErrors>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
            if let error = error {
                callback(.failure(.general(error)))
            } else {
                callback(.failure(.generic))
            }
            return
        }
        if response.statusCode == 200 {
            if let build = builder(data) {
                callback(.success(build))
            } else {
                callback(.failure(.generic))
            }
        } else {
            callback(.failure(.statusCode(response.statusCode)))
        }
    }.resume()
}

func getNetworkThrowingData<Recieved>(url: URL,
                              builder: @escaping (Data) throws -> Recieved,
                              callback: @escaping (Result<Recieved, NetworkErrors>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
            if let error = error {
                callback(.failure(.general(error)))
            } else {
                callback(.failure(.generic))
            }
            return
        }
        if response.statusCode == 200 {
            do {
                let build = try builder(data)
                callback(.success(build))
            } catch {
                callback(.failure(.buildFailure(error.localizedDescription)))
            }
        } else {
            callback(.failure(.statusCode(response.statusCode)))
        }
    }.resume()
}
