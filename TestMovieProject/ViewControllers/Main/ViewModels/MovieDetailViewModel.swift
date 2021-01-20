//
//  MovieDetailViewModel.swift
//  TestMovieProject
//
//  Created by Woddi on 20.01.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

protocol MovieDetailViewModelOutput: ViewWithLoader {
    
    func setField(by type: MovieDetailViewModel.FieldType)

}

protocol MovieDetailViewModeling: AnyObject {

    var output: MovieDetailViewModelOutput? { get set }
    
    func viewDidLoad()
    
}

final class MovieDetailViewModel {

    enum FieldType {
        case title(String)
        case overview(String)
        case poster(URL?)
        case releaseDate(String)
    }
    // MARK: - Public properties
    
    weak var output: MovieDetailViewModelOutput?

    // MARK: - Private properties
    
    private let api: NetworkService
    private let movieID: Int

    // MARK: - Initializer
    
    init(api: NetworkService = NetworkService(), movieID: Int) {
        self.api = api
        self.movieID = movieID
    }
}

// MARK: - Business logic

extension MovieDetailViewModel: MovieDetailViewModeling {

    func viewDidLoad() {
        getDetails()
    }
}

// MARK: - Private methods

private extension MovieDetailViewModel {
    
    func handle(details: MovieDetail) {
        output?.setField(by: .title(details.title))
        output?.setField(by: .poster(details.posterURL))
        output?.setField(by: .releaseDate(DateFormatter.publicDateFormatter.string(from: details.releaseDate)))
        output?.setField(by: .overview(details.overview))
    }
    
    func handle(error: NetworkError) {
        if let details = CoreDataService.getMovieDetail(by: movieID) {
            handle(details: details)
        }
        output?.showError(text: error.description, completion: nil)
    }
}

// MARK: - API

private extension MovieDetailViewModel {
    
    func getDetails() {
        output?.showLoader()
        api.getMovieDetail(by: movieID) { [weak self] movieDetail in
            guard let self = self else {
                return
            }
            CoreDataService.updateMovie(by: self.movieID, with: movieDetail)
            self.handle(details: movieDetail)
            self.output?.hideLoader()
        } failure: { [weak self] error in
            self?.handle(error: error)
        }
    }
}
