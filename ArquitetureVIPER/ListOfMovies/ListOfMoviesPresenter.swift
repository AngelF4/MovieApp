//
//  ListOfMoviesPresenter.swift
//  ArquitetureVIPER
//
//  Created by Angel Hernández Gámez on 25/03/25.
//

import Foundation

protocol ListOfMoviesUI: AnyObject {
    func update(movies: [MovieViewModel])
    func showError(_ message: String, errorFromAPI: Bool)
    func showLoading()
    func hideLoading()
}

class ListOfMoviesPresenter {
    var ui: ListOfMoviesUI?
    private let listOfMoviesInteractor: ListOfMoviesInteractor
    var viewModels: [MovieViewModel] = []
    private let mapper: MovieMapper
    
    init(listOfMoviesInteractor: ListOfMoviesInteractor, mapper: MovieMapper = MovieMapper()) {
        self.listOfMoviesInteractor = listOfMoviesInteractor
        self.mapper = mapper
    }
    
    func onViewAppear() {
        Task {
            ui?.showLoading()
            let response = await listOfMoviesInteractor.getListOfMovies()
            let models = response?.results ?? []
            viewModels = models.map(mapper.map(entity:))
            
            if viewModels.isEmpty {
                ui?.showError("No se encontraron resultados", errorFromAPI: false)
            } else {
                ui?.update(movies: viewModels)
            }
            ui?.hideLoading()
        }
    }
    
    func onRetry() {
        onViewAppear()
    }
}

extension ListOfMoviesPresenter: ListOfMoviesInteractorOutput {
    func didFailFetchingMovies(with error: Error) {
        ui?.update(movies: [])
        ui?.showError(error.localizedDescription, errorFromAPI: true)
        print("Error en Presenter: " + error.localizedDescription)
    }
}
