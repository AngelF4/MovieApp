//
//  ListOfMoviesRouter.swift
//  ArquitetureVIPER
//
//  Created by Angel Hernández Gámez on 25/03/25.
//

import Foundation
import UIKit

class ListOfMoviesRouter {
    func showListOfMovies(window: UIWindow?) {
        let view = ListOfMoviesView()
        let interactor = ListOfMoviesInteractor()
        let presenter = ListOfMoviesPresenter(listOfMoviesInteractor: interactor)
        presenter.ui = view
        interactor.output = presenter
        view.presenter = presenter
        
        
        window?.rootViewController = view
        window?.makeKeyAndVisible()
    }
}
