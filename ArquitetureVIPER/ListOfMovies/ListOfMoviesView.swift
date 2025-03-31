//
//  ListOfMoviesView.swift
//  ArquitetureVIPER
//
//  Created by Angel Hernández Gámez on 25/03/25.
//

import Foundation
import UIKit

class ListOfMoviesView: UIViewController {
    private var movies: [MovieViewModel] = []
    private var isShowingError = false
    
    private var moviesTableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(MovieCellView.self, forCellReuseIdentifier: "MovieCellView")
        tableView.register(SkeletonCellView.self, forCellReuseIdentifier: "SkeletonCellView")
        return tableView
    }()
    
    private let errorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .systemGray6
        stackView.layer.cornerRadius = 8
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.isHidden = true
        return stackView
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 13, weight: .bold, width: .standard)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.borderedTinted()
        config.title = "Reintentar"
        config.image = UIImage(systemName: "arrow.trianglehead.counterclockwise")
        config.buttonSize = .large
        config.imagePadding = 12
        let button = UIButton(type: .system, primaryAction: UIAction(handler: { [weak self] _ in
            self?.presenter?.onRetry()
            self?.hideError()
            self?.errorLabel.text = ""
        }))
        button.configuration = config
        button.clipsToBounds = true
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    var presenter: ListOfMoviesPresenter?
    
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
        setupLoadingIndicator()
        setupRefreshControl()
        presenter?.onViewAppear()
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        moviesTableView.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        presenter?.onRetry()
        errorLabel.text = ""
        hideError()
        sender.endRefreshing()
    }
    
    private func setupErrorLabel() {
        // Agrega errorLabel y retryButton al errorStackView
        errorStackView.addArrangedSubview(errorLabel)
        errorStackView.addArrangedSubview(retryButton)
        
        // Agrega errorStackView a la vista principal
        view.addSubview(errorStackView)
        errorStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        errorStackView.isLayoutMarginsRelativeArrangement = true
        
        NSLayoutConstraint.activate([
            errorStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            errorStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
        
    func showError(_ message: String, errorFromAPI: Bool) {
        DispatchQueue.main.async {
            self.errorLabel.layer.removeAllAnimations()
            self.retryButton.layer.removeAllAnimations()
            self.errorStackView.layer.removeAllAnimations()

            self.errorLabel.text = "Ocurrió un error inesperado: \(message)"
            self.isShowingError = errorFromAPI
            
            // Inicializa la alpha en 0 para preparar la animación
            self.errorLabel.alpha = 0
            self.retryButton.alpha = 0
            self.errorStackView.alpha = 0

            // Asegúrate de que las vistas estén visibles
            self.errorLabel.isHidden = false
            self.retryButton.isHidden = false
            self.errorStackView.isHidden = false

            self.view.bringSubviewToFront(self.errorStackView)

            // Animación de fade in
            UIView.animate(withDuration: 0.3) {
                self.errorLabel.alpha = 1.0
                self.retryButton.alpha = 1.0
                self.errorStackView.alpha = 1.0
            }
        }
    }

    func hideError() {
        DispatchQueue.main.async {
            self.errorLabel.layer.removeAllAnimations()
            self.retryButton.layer.removeAllAnimations()
            self.errorStackView.layer.removeAllAnimations()

            UIView.animate(withDuration: 0.3, animations: {
                self.errorLabel.alpha = 0
                self.retryButton.alpha = 0
                self.errorStackView.alpha = 0
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
        if isShowingError {
            return 5
        } else {
            return movies.isEmpty ? 0 : movies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !movies.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellView", for: indexPath) as! MovieCellView
            let model = movies[indexPath.row]
            cell.configure(model: model)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SkeletonCellView", for: indexPath) as! SkeletonCellView
            return cell
        }
    }
}

extension ListOfMoviesView: ListOfMoviesUI {
    func update(movies: [MovieViewModel]) {
        //print("Datos recibidos \(movies)")
        DispatchQueue.main.async {
            self.movies = movies
            self.isShowingError = false
            self.moviesTableView.reloadData()
        }
    }
    
    func showLoading() {
        DispatchQueue.main.async {
             self.loadingIndicator.startAnimating()
             self.view.bringSubviewToFront(self.loadingIndicator)
        }
    }

    func hideLoading() {
        DispatchQueue.main.async {
             self.loadingIndicator.stopAnimating()
        }
    }
}
