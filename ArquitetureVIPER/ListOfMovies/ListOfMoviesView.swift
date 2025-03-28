//
//  ListOfMoviesView.swift
//  ArquitetureVIPER
//
//  Created by Angel Hernández Gámez on 25/03/25.
//

import Foundation
import UIKit

class ListOfMoviesView: UIViewController {
    private var moviesTableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(MovieCellView.self, forCellReuseIdentifier: "MovieCellView")
        tableView.register(SkeletonCellView.self, forCellReuseIdentifier: "SkeletonCellView")
        return tableView
    }()
    
    private let errorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 13, weight: .bold, width: .standard)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "Reintentar"
        config.image = UIImage(systemName: "arrow.trianglehead.counterclockwise")
        config.buttonSize = .large
        let button = UIButton(type: .system, primaryAction: UIAction(handler: { [weak self] _ in
            self?.presenter?.onRetry()
            self?.hideError()
        }))
        button.configuration = config
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var presenter: ListOfMoviesPresenter?
    
    var isLoaded = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupErrorLabel()
        setupRefreshControl()
        presenter?.onViewAppear()
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        moviesTableView.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        presenter?.onRetry()
        sender.endRefreshing()
    }
    
    private func setupErrorLabel() {
        view.addSubview(errorLabel)
        view.addSubview(retryButton)
        view.addSubview(errorView)
        
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: errorLabel.topAnchor, constant: -12),
            errorView.bottomAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 12),
            errorView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 15),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
        
    func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorLabel.layer.removeAllAnimations()
            self.retryButton.layer.removeAllAnimations()
            self.errorView.layer.removeAllAnimations()

            self.errorLabel.text = "Ocurrió un error inesperado: \(message)"

            // Inicializa la alpha en 0 para preparar la animación
            self.errorLabel.alpha = 0
            self.retryButton.alpha = 0
            self.errorView.alpha = 0

            // Asegúrate de que las vistas estén visibles
            self.errorLabel.isHidden = false
            self.retryButton.isHidden = false
            self.errorView.isHidden = false

            self.view.bringSubviewToFront(self.errorLabel)
            self.view.bringSubviewToFront(self.retryButton)

            // Animación de fade in
            UIView.animate(withDuration: 0.3) {
                self.errorLabel.alpha = 1.0
                self.retryButton.alpha = 1.0
                self.errorView.alpha = 1.0
            }
        }
    }

    func hideError() {
        DispatchQueue.main.async {
            self.errorLabel.layer.removeAllAnimations()
            self.retryButton.layer.removeAllAnimations()
            self.errorView.layer.removeAllAnimations()

            UIView.animate(withDuration: 0.3, animations: {
                self.errorLabel.alpha = 0
                self.retryButton.alpha = 0
                self.errorView.alpha = 0
            })
        }
    }
    
    private func setupTableView() {
        view.addSubview(moviesTableView)
        
        NSLayoutConstraint.activate([
            moviesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            moviesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            moviesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            moviesTableView.topAnchor.constraint(equalTo: view.topAnchor),
            
        ])
        
        moviesTableView.dataSource = self
    }
}

extension ListOfMoviesView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoaded && presenter!.viewModels.isEmpty {
             return 5 // o el número de celdas de skeleton que desees mostrar
        } else if isLoaded {
             return presenter!.viewModels.count
        } else {
             return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoaded && !presenter!.viewModels.isEmpty {
             let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellView", for: indexPath) as! MovieCellView
             let model = presenter!.viewModels[indexPath.row]
             cell.configure(model: model)
             return cell
        } else {
             let cell = tableView.dequeueReusableCell(withIdentifier: "SkeletonCellView", for: indexPath) as! SkeletonCellView
             return cell
        }
    }
}

extension ListOfMoviesView: ListOfMoviesUI {
    func update(movies: [ViewModel]) {
        print("Datos recibidos \(movies)")
        DispatchQueue.main.async {
            self.isLoaded = true
            self.moviesTableView.reloadData()
        }
    }
}
