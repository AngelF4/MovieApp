//
//  ListOfMoviesInteractor.swift
//  ArquitetureVIPER
//
//  Created by Angel Hernández Gámez on 25/03/25.
//

import Foundation

//c626f9d2ae573062a5acf0d1d92d4f60

class ListOfMoviesInteractor {
    
    weak var output: ListOfMoviesInteractorOutput?
    func getListOfMovies() async -> PopularMovieResponseEntity? {
        do {
            
            let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=c626f9d2ae573062a5acf0d1d92d4f60")!
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData // No usar cache
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let response = try JSONDecoder().decode(PopularMovieResponseEntity.self, from: data)
            return response
        } catch {
            print("Error al obtener la lista de películas: \(error)")
            output?.didFailFetchingMovies(with: error)
            return nil
        }
    }
}

protocol ListOfMoviesInteractorOutput: AnyObject {
    func didFailFetchingMovies(with error: Error)
}
