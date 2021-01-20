//
//  PopularMoviesTableViewCell.swift
//  TestMovieProject
//
//  Created by Woddi on 19.01.2021.
//

import UIKit

final class PopularMoviesTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var lblTitl: UILabel!
    @IBOutlet private weak var imageViewPoster: UIImageView!
    
    // MARK: - Life cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewPoster.removeAndCancel()
        lblTitl.text = ""
    }
    
    func configureWith(viewModel: ViewModel) -> PopularMoviesTableViewCell {
        lblTitl.text = viewModel.title
        imageViewPoster.isHidden = viewModel.posterURL == nil
        imageViewPoster.setImage(with: viewModel.posterURL)
        return self
    }
}

// MARK: - PopularMoviesTableViewCell.ViewModel

extension PopularMoviesTableViewCell {
    
    struct ViewModel {
        let title: String
        let posterURL: URL?
    }
}

// MARK: - Initializer

extension PopularMoviesTableViewCell.ViewModel {
    
    init(model: DiscoverMovie) {
        title = model.title
        posterURL  = model.posterURL
    }
}

