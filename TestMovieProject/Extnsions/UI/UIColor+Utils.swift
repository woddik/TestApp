//
//  UIColor+Utils.swift
//  TestMovieProject
//
//  Created by Woddi on 19.01.2021.
//

import UIKit

extension UIColor {
    
    static var loaderColor: UIColor {
        return colorForMode(dark: 0x3EA8FF, light: 0xFF9948)
    }
    
    static var defaultBG: UIColor {
        return colorForMode(dark: 0x191919, light: 0xFFFFFF)
    }
    
    static var loaderBGColor: UIColor {
        return colorForMode(dark: 0x6AD5E5, light: 0x000000, lA: 0.2)
    }
    
}

// MARK: - Initializer

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    convenience init(rgb: Int, alpha: CGFloat = 1) {
        self.init(red: (rgb >> 16) & 0xFF,
                  green: (rgb >> 8) & 0xFF,
                  blue: rgb & 0xFF, alpha: alpha)
    }
    
    static func colorForMode(dark: Int, dA: CGFloat = 1, light: Int, lA: CGFloat = 1) -> UIColor {
        return colorForMode(dark: UIColor(rgb: dark, alpha: dA), light: UIColor(rgb: light, alpha: lA))
    }
    
    static func colorForMode(dark: UIColor, light: UIColor) -> UIColor {
        return UIColor { [dark, light] trait -> UIColor in
            trait.userInterfaceStyle == .dark ? dark : light
        }
    }
    
}
