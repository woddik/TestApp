//
//  MovieDetailViewController.swift
//  TestMovieProject
//
//  Created by Woddi on 20.01.2021.
//

import UIKit

final class MovieDetailViewController: BaseViewController {

    @IBOutlet private weak var lblTitle: UILabel!
    @IBOutlet private weak var imageViewPoster: UIImageView!
    @IBOutlet private weak var lblReleaseDate: UILabel!
    @IBOutlet private weak var lblDescription: UILabel!
    
    var viewModel: MovieDetailViewModeling! //swiftlint:disable:this implicitly_unwrapped_optional
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
    }

}

// MARK: - MovieDetailViewModelOutput

extension MovieDetailViewController: MovieDetailViewModelOutput {
    
    func setField(by type: MovieDetailViewModel.FieldType) {
        switch type {
        case .title(let text):
            lblTitle.text = text
        case .overview(let text):
            lblDescription.text = text
        case .poster(let url):
            imageViewPoster.setImage(with: url)
        case .releaseDate(let text):
            lblReleaseDate.text = text
        }
    }

}
