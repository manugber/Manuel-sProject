//
//  FilmsDiffableDataSource.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 1/4/22.
//

import Foundation
import UIKit

let modelLogic = ModelLogic.shared

final class FilmsDiffableDataSource: UITableViewDiffableDataSource<Genre, Film> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if modelLogic.leftBarButtonTitle == .popularity {
            if modelLogic.snapshot.numberOfItems(inSection: modelLogic.genres[section]) != 0 {
                return modelLogic.genres[section].name
            }
        }
        return nil
    }
}
