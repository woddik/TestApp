//
//  Loader.swift
//
//  Created by Woddi on 6/21/19.
//

import UIKit

final class LinearProgressBar: UIView {
    
    // MARK: - Variables
    
    private var heightForLinearBar: CGFloat = 10
    private var widthForLinearBar: CGFloat = 0
    
    private var screenSize: CGRect = UIScreen.main.bounds
    private var isAnimationRunning = false
    private var progressBarIndicator: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))

    // MARK: - ViewController LifeCycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.screenSize = UIScreen.main.bounds
        
        if widthForLinearBar == 0 || widthForLinearBar == screenSize.height {
            widthForLinearBar = screenSize.width
        }
        
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: widthForLinearBar, height: frame.height)
    }

    // MARK: - Public Functions
    
    func startAnimation() {
        configureColors()
        
        if !isAnimationRunning {
            isAnimationRunning = true
            isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                self.frame = CGRect(x: 0, y: self.frame.origin.y, width: self.widthForLinearBar, height: self.heightForLinearBar)
                
            }, completion: { animationFinished in
                self.addSubview(self.progressBarIndicator)
                self.configureAnimation()
            })
        }
    }
    
    func stopAnimation() {
        isAnimationRunning = false
        isHidden = true
    }
}

// MARK: - Private methods

private extension LinearProgressBar {
    
    func configureColors() {
        backgroundColor = .loaderBGColor
        progressBarIndicator.backgroundColor = .loaderColor
    }
    
    func configureAnimation() {
        progressBarIndicator.frame = CGRect(x: 0, y: 0, width: 0, height: heightForLinearBar)
        
        UIView.animate(withDuration: 0.5, delay:0, options: [], animations: {
            self.progressBarIndicator.frame = CGRect(x: 0,
                                                     y: 0,
                                                     width: self.widthForLinearBar * 0.7,
                                                     height: self.heightForLinearBar)
            
        })
        
        UIView.animate(withDuration: 0.4, delay:0.4, options: [], animations: {
            self.progressBarIndicator.frame = CGRect(x: self.frame.width, y: 0, width: 0, height: self.heightForLinearBar)
            
        }, completion: { animationFinished in
            if self.isAnimationRunning {
                self.configureAnimation()
            }
        })
    }
}
