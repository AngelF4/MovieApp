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
    var isTestMode: Bool = false
    
    func getListOfMovies() async -> MovieResponseEntity? {
        if isTestMode {
            // Retorna un MovieResponseEntity con un arreglo vacío para pruebas
            return MovieResponseEntity(results: [])
        }
        
        do {
            let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=c626f9d2ae573062a5acf0d1d92d4f60")!
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData // No usar cache
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let response = try JSONDecoder().decode(MovieResponseEntity.self, from: data)
            
            // Guardar la respuesta en UserDefaults
            if let encodedResponse = try? JSONEncoder().encode(response) {
                UserDefaults.standard.set(encodedResponse, forKey: "popularMovies")
            }
            
            return response
        } catch {
            print("Error al obtener la lista de películas: \(error)")
            
            // Intentar cargar los datos almacenados en UserDefaults
            if let savedData = UserDefaults.standard.data(forKey: "popularMovies"),
               let savedResponse = try? JSONDecoder().decode(MovieResponseEntity.self, from: savedData) {
                return savedResponse
            }
            
            output?.didFailFetchingMovies(with: error)
            return nil
        }
    }
}

protocol ListOfMoviesInteractorOutput: AnyObject {
    func didFailFetchingMovies(with error: Error)
}
