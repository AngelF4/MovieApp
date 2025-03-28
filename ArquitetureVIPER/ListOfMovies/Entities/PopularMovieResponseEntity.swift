//
//  PopularMovieResponseEntity.swift
//  ArquitetureVIPER
//
//  Created by Angel Hernández Gámez on 25/03/25.
//

import Foundation

struct PopularMovieResponseEntity: Decodable {
    let results: [PopularMovieEntity]
}
