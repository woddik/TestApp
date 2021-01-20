//
//  PopularMoviesViewController.swift
//  TestMovieProject
//
//  Created by Woddi on 19.01.2021.
//

import UIKit

final class PopularMoviesViewController: BaseViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private properties
        
    private lazy var viewModel: PopularMoviesViewModeling = {
        var viewModel = PopularMoviesViewModel()
        viewModel.output = self
        return viewModel
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        configureUI()
    }

}

// MARK: - Private methods

private extension PopularMoviesViewController {
    
    func configureUI() {
        navigationController?.navigationBar.backgroundColor = .clear
        
        registerCells()
        addSearch()
    }

    func registerCells() {
        tableView.registerCell(PopularMoviesTableViewCell.self)
    }

    func addSearch() {
        
        let search = UISearchController(searchResultsController: nil)
        search.delegate = self
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search movies"
        navigationItem.searchController = search
    }
}

// MARK: - PopularMoviesViewModelOutput

extension PopularMoviesViewController: PopularMoviesViewModelOutput {
    
    func reloadListData() {
        tableView.reloadData()
    }
    
    func showDetailWith(viewModel: MovieDetailViewModeling) {
        NavigationManager(navigationController).pushToMovieDetailViewController(with: viewModel)
    }

}

// MARK: - UITableViewDataSource

extension PopularMoviesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(with: PopularMoviesTableViewCell.self,
                                             for: indexPath)
            .configureWith(viewModel: viewModel.item(at: indexPath))
    }
}

// MARK: - UITableViewDelegate

extension PopularMoviesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.numberOfItems(in: indexPath.section) - 10 == indexPath.row {
            viewModel.loadNextBatch()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.itemAtIndexPathWasSelected(indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UISearchResultsUpdating

extension PopularMoviesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        viewModel.startSearchWith(query: text)
    }

}

// MARK: - UISearchControllerDelegate

extension PopularMoviesViewController: UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        viewModel.searchControllerStartSearching(isStart: true)
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        viewModel.searchControllerStartSearching(isStart: false)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: false)

    }
}
