//
//  ListOfMoviesPresenter.swift
//  ArquitetureVIPER
//
//  Created by Angel Hernández Gámez on 25/03/25.
//

import Foundation

protocol ListOfMoviesUI: AnyObject {
    func update(movies: [ViewModel])
    func showError(_ message: String)
}

class ListOfMoviesPresenter {
    var ui: ListOfMoviesUI?
    private let listOfMoviesInteractor: ListOfMoviesInteractor
    var viewModels: [ViewModel] = []
    private let mapper: Mapper
    
    init(listOfMoviesInteractor: ListOfMoviesInteractor, mapper: Mapper = Mapper()) {
        self.listOfMoviesInteractor = listOfMoviesInteractor
        self.mapper = mapper
    }
    
    func onViewAppear() {
        Task {
            let models = await (listOfMoviesInteractor.getListOfMovies() != nil ? listOfMoviesInteractor.getListOfMovies()!.results : [])
            viewModels = models.map(mapper.map(entity:))
            print("Volver a llamar API")
            ui?.update(movies: viewModels)
        }
    }
    
    func onRetry() {
        onViewAppear()
    }
}

extension ListOfMoviesPresenter: ListOfMoviesInteractorOutput {
    func didFailFetchingMovies(with error: Error) {
        ui?.showError(error.localizedDescription)
        print("Error en Presenter: " + error.localizedDescription)
    }
}
