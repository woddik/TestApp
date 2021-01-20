//
//  UIImageView+SDWebImage.swift
//  RestaurantTestApp
//
//  Created by Woddi on 5/3/19.
//  Copyright © 2019 Woddi. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {

    func setImage(with url: URL?) {
        if let some = SDImageCache.shared.imageFromDiskCache(forKey: url?.absoluteString) {
            image = some
        } else {
            sd_setImage(with: url)
        }
    }

    func removeAndCancel() {
        image = nil
        cancelLoading()
    }
    
    func cancelLoading() {
        sd_cancelCurrentImageLoad()
    }
}
