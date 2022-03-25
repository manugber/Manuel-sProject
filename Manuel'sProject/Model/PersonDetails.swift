//
//  Person.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 24/3/22.
//

import Foundation

struct PersonDetails: Codable {
    let biography, birthday: String
    let knownForDepartment, placeOfBirth: String

    enum CodingKeys: String, CodingKey {
        case biography, birthday
        case knownForDepartment = "known_for_department"
        case placeOfBirth = "place_of_birth"
    }
}
