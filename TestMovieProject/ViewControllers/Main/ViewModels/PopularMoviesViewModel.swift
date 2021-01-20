//
//  PopularMoviesViewModel.swift
//  TestMovieProject
//
//  Created by Woddi on 19.01.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import Combine

protocol PopularMoviesViewModelOutput: ViewWithLoader, ListUpdating {
    
    func showDetailWith(viewModel: MovieDetailViewModeling)

}

protocol PopularMoviesViewModeling: ListSource {

    var output: PopularMoviesViewModelOutput? { get set }
    
    func viewDidLoad()
    
    func item(at indexPath: IndexPath) -> PopularMoviesTableViewCell.ViewModel
    
    func loadNextBatch()
    
    func startSearchWith(query: String)
    
    func searchControllerStartSearching(isStart: Bool)
    
    func itemAtIndexPathWasSelected(_ indexPath: IndexPath)
    
}

final class PopularMoviesViewModel {

    // MARK: - Public properties
    
    weak var output: PopularMoviesViewModelOutput?

    // MARK: - Private properties
    
    private let api: NetworkService
    
    private var currentPage: Int = 1
    private var currentSearchPage: Int = 1

    private let dataSource = DataSource<[DiscoverMovie]>()
    private let searchDataSource = DataSource<[DiscoverMovie]>()

    private var isSearchState: Bool = false

    private let debouncer = Debouncer(seconds: 0.5)
    private var query: String = ""
    
    // MARK: - Initializer
    
    init(api: NetworkService = NetworkService()) {
        self.api = api
    }
}

// MARK: - Business logic

extension PopularMoviesViewModel: PopularMoviesViewModeling {
    
    func viewDidLoad() {
        guard NetworkConnectionManager.shared.didUpdate else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.viewDidLoad()
            }
            return
        }
        if NetworkConnectionManager.isReachable {
            loadPopularMovies()
        } else {
            dataSource.replaceSection(to: CDMovie.getObjectsWith().convert(to: DiscoverMovie.self) ?? [])
            output?.reloadListData()
        }
    }
    
    func item(at indexPath: IndexPath) -> PopularMoviesTableViewCell.ViewModel {
        let model = source.item(at: indexPath)
        return .init(model: model)
    }
    
    func numberOfSections() -> Int {
        return source.numberOfSections()
    }
    
    func numberOfItems(in section: Int) -> Int {
        return source.numberOfItems(in: section)
    }
    
    func loadNextBatch() {
        page += 1
        
        isSearchState ? loadSearch() : loadPopularMovies()
    }

    func startSearchWith(query: String) {
        self.query = query
        
        debouncer.debounce { [query, weak self] in
            guard query.count > 3 else {
                self?.clearSearch()
                return
            }
            self?.loadSearch()
        }
    }

    func searchControllerStartSearching(isStart: Bool) {
        isSearchState = isStart
        clearSearch()
        output?.reloadListData()
    }

    func itemAtIndexPathWasSelected(_ indexPath: IndexPath) {
        let item = source.item(at: indexPath)
        let viewModel = MovieDetailViewModel(movieID: item.identifier)
        output?.showDetailWith(viewModel: viewModel)
    }

}

// MARK: - Private methods

private extension PopularMoviesViewModel {
    
    var page: Int {
        get {
            isSearchState ? currentSearchPage : currentPage
        }
        set {
            if isSearchState {
                currentSearchPage = newValue
            } else {
                currentPage = newValue
            }
        }
    }
    
    var source: DataSource<[DiscoverMovie]> {
        isSearchState ? searchDataSource : dataSource
    }
    
    func clearSearch() {
        currentSearchPage = 1
        searchDataSource.removeAll()
        output?.reloadListData()
    }
    
    func handle(movies: [DiscoverMovie]) {
        movies.forEach({ _ = $0.toCoreDataItem() })
        CoreDataService.saveAllContexts()
        
        source.appendItems(movies, toSectionAt: 0)
        output?.reloadListData()
    }
    
    func handle(error: NetworkError) {
        output?.showError(text: error.description, completion: nil)
    }
}

// MARK: - API

private extension PopularMoviesViewModel {
    
    func loadPopularMovies() {
        output?.showLoader()
        api.getPopularMovies(page: currentPage) { [weak self] movies in
            self?.handle(movies: movies)
            self?.output?.hideLoader()
        } failure: { [weak self] error in
            self?.handle(error: error)
        }
    }
    
    func loadSearch() {
        api.searchMovies(page: currentSearchPage, query: query, success: { [weak self] movies in
            self?.handle(movies: movies)
            self?.output?.hideLoader()
            
        }, failure: { [weak self] error in
            self?.handle(error: error)
        })
    }
}
