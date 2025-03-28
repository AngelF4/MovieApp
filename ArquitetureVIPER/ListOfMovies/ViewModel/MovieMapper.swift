//
//  Mapper.swift
//  ArquitetureVIPER
//
//  Created by Angel Hernández Gámez on 26/03/25.
//

import Foundation

struct MovieMapper {
    func map(entity: MovieEntity) -> MovieViewModel {
        MovieViewModel(title: entity.title,
                  overview: entity.overview,
                  imageURL: entity.imageURL)
    }
}
