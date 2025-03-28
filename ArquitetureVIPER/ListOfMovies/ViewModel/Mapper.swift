//
//  Mapper.swift
//  ArquitetureVIPER
//
//  Created by Angel Hernández Gámez on 26/03/25.
//

import Foundation

struct Mapper {
    func map(entity: PopularMovieEntity) -> ViewModel {
        ViewModel(title: entity.title,
                  overview: entity.overview,
                  imageURL: entity.imageURL)
    }
}
