//
//  Loader.swift
//
//  Created by Woddi on 6/21/19.
//

import UIKit

// MARK: - ViewWithLoader

protocol ViewWithLoader: class {
    
    var loader: Loader { get }
    
    func showLoader()
    
    func hideLoader(_ completion: (() -> Void)?)
    
    func hideLoader()
    
    func showError(text: String, completion: (() -> Void)?)
}

extension ViewWithLoader where Self: UIViewController {
    
    func showLoader() {
        view.endEditing(true)
        loader.showLoader()
    }
    
    func hideLoader(_ completion: (() -> Void)?) {
        loader.hide(completion)
    }
    
    func hideLoader() {
        loader.hide()
    }
    
    func showError(text: String, completion: (() -> Void)?) {
        hideLoader()
        showMessage(message: text, title: "Error", complition: completion)
    }

}

// MARK: - Loader.Configurator

extension Loader {
    
    struct Configurator {
        let customView: UIView?
        
        let color: UIColor?
        let positionOnView: CGPoint?
        let size: CGSize
        let isInCentr: Bool
        let cornerRadius: CGFloat
        
        init(color: UIColor? = nil,
             positionOnView: CGPoint? = .zero,
             size: CGSize,
             isInCentr: Bool = true,
             cornerRadius: CGFloat = 0) {
            self.color = color
            self.positionOnView = positionOnView
            self.size = size
            self.isInCentr = isInCentr
            self.cornerRadius = cornerRadius
            customView = nil
        }
        
        init(customView: UIView, positionOnView: CGPoint? = .zero, isInCentr: Bool = true, size: CGSize? = nil) {
            self.customView = customView
            self.positionOnView = positionOnView
            self.isInCentr = isInCentr
            if let newSize = size {
                self.size = newSize
            } else {
                self.size = customView.bounds.size
            }
            color = customView.backgroundColor
            cornerRadius = 0
        }
    }
}

final class Loader {
    
    enum PositionY {
        case `default`
        case small
        case medium
        
        case custom(value: CGFloat)
        
        var rawValue: CGFloat {
            switch self {
            case .default: return 0
            case .small: return 64
            case .medium: return 80
            case .custom(value: let value): return value
            }
        }
    }
    
    // MARK: - Public properties
    
    static var `default`: Loader {
        return Loader.loader()
    }

    static var mediumHeaderInset: Loader {
        return Loader.loader(withY: .medium)
    }

    static var smallHeaderInset: Loader {
        return Loader.loader(withY: .small)
    }
    
    // MARK: - Public properties
    
    var isLoading: Bool {
        return overlayView?.superview != nil
    }
    
    // MARK: - Private properties
    
//    private let bgColor: UIColor
    private var progressView: UIView?
    private var overlayView: UIView?
    
    private let bgConfigurator: Configurator
    private let loaderConfigurator: Configurator
        
    // MARK: - Init
    
    init(background configure: Configurator, loaderConfigure: Configurator) {
        bgConfigurator = configure
        loaderConfigurator = loaderConfigure

        setupDefaults()
    }
    
    // MARK: - Public methods
    
    static func loader(withY position: PositionY = .default) -> Loader {
        let bgConfig = Loader.Configurator(color: .clear,
                                           positionOnView: .zero,
                                           size: UIScreen.main.bounds.size,
                                           isInCentr: false)
        
        let size = CGSize(width: UIScreen.main.bounds.width, height: 10)
        let loadingView = LinearProgressBar(frame: CGRect(origin: .zero, size: size))
        let loaderConfig = Loader.Configurator(customView: loadingView, positionOnView: CGPoint(x: 0, y: position.rawValue), isInCentr: false)
        
        return Loader(background: bgConfig, loaderConfigure: loaderConfig)
    }
    
    func setPosition(_ position: PositionY) {
        overlayView?.frame.origin = CGPoint(x: 0, y: position.rawValue)
    }
    
    func showOnViewContoller(_ controller: UIViewController) {
        showLoader(on: controller.view)
    }
    
    func showLoader(on view: UIView? = nil) {
        guard !isLoading else {
            return
        }
        if let loader = progressView as? LinearProgressBar {
            loader.startAnimation()
        }
                
        if let supViewBounds = overlayView?.bounds, loaderConfigurator.isInCentr {
            progressView?.center = CGPoint(x: supViewBounds.width / 2, y: supViewBounds.height / 2)
        }
        guard let overlayView = overlayView, let progressView = progressView else {
            return
        }

        overlayView.addSubview(progressView)
        if let view = view {
            view.addSubview(overlayView)
            if bgConfigurator.isInCentr {
                overlayView.center = view.center
            } else {
                attachBGToSubView(view)
            }
            
        } else if let window = UIApplication.shared.keyWindow {
            if bgConfigurator.isInCentr {
                overlayView.center = window.center
            }
            window.addSubview(overlayView)
        }
    }
    
    func hide(_ completion: (() -> Void)? = nil) {
        if let loader = progressView as? LinearProgressBar {
            loader.stopAnimation()
        }
        
        overlayView?.removeFromSuperview()
        
        DispatchQueue.main.async {
            completion?()
        }
    }
}

// MARK: - Private methods

private extension Loader {
    
    func setupDefaults() {
        configureBG()
        configureProgress()
    }

    func configureBG() {
        overlayView = bgConfigurator.customView ?? UIView()
        overlayView?.frame = CGRect(origin: bgConfigurator.positionOnView ?? .zero, size: bgConfigurator.size)
        overlayView?.backgroundColor = bgConfigurator.color
        overlayView?.clipsToBounds = true
        overlayView?.layer.cornerRadius = bgConfigurator.cornerRadius
    }

    func configureProgress() {
        progressView = loaderConfigurator.customView ?? LoaderView(loaderColor: loaderConfigurator.color)

        progressView?.frame = CGRect(origin: loaderConfigurator.positionOnView ?? .zero, size: loaderConfigurator.size)
        progressView?.clipsToBounds = true
        progressView?.layer.cornerRadius = loaderConfigurator.cornerRadius
    }
    
    func attachBGToSubView(_ view: UIView) {
        guard let overlayView = overlayView, overlayView.superview != nil else {
            return
        }
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        let position = bgConfigurator.positionOnView ?? .zero
        
        overlayView.topAnchor.constraint(equalTo: view.topAnchor, constant: position.y).isActive = true
        view.leftAnchor.constraint(equalTo: overlayView.leftAnchor, constant: position.x).isActive = true
        
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        overlayView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
}

final class LoaderView: UIView {
    
    // MARK: - Constants
    
    private struct Constants {
        let lineRation: CGFloat = 0.2
        let loaderRatio: CGFloat = 0.128
    }
    
    // MARK: - Private properties
    
    private var shapeLayer: CAShapeLayer? {
        return layer as? CAShapeLayer
    }
    
    private static var poses: [Pose] {
        return [
            Pose(0.0, 0.000, 0.7),
            Pose(0.6, 0.500, 0.5),
            Pose(0.6, 1.000, 0.3),
            Pose(0.6, 1.500, 0.1),
            Pose(0.2, 1.875, 0.1),
            Pose(0.2, 2.250, 0.3),
            Pose(0.2, 2.625, 0.5),
            Pose(0.2, 3.000, 0.7)
        ]
    }
    
    private var loaderColor: UIColor = .lightGray
    
    // MARK: - Initializer
    
    convenience init(loaderColor: UIColor? = nil) {
        self.init()
        if let color = loaderColor {
            self.loaderColor = color
        }
    }
    
    convenience init() {
        let frame = UIScreen.main.bounds
        let loaderSize = frame.width * Constants().loaderRatio
        self.init(frame: CGRect(origin: .zero, size: CGSize(width: loaderSize, height: loaderSize)))
    }
    
    // MARK: - Life cycle
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer?.fillColor = nil
        shapeLayer?.strokeColor = loaderColor.cgColor
        shapeLayer?.lineWidth = bounds.width * 0.15
        shapeLayer?.lineCap = .round
        setPath()
    }
    
    override func didMoveToWindow() {
        animate()
    }
    
}

// MARK: - Private methods

private extension LoaderView {
    
    func setPath() {
        guard let sLayer = shapeLayer else {
            return
        }
        sLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: sLayer.lineWidth / 2, dy: sLayer.lineWidth / 2)).cgPath
    }
    
    func animate() {
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        
        let poses = type(of: self).poses
        let totalSeconds = poses.reduce(0) { $0 + $1.secondsSincePriorPose }
        
        for pose in poses {
            time += pose.secondsSincePriorPose
            times.append(time / totalSeconds)
            start = pose.start
            rotations.append(start * 2 * .pi)
            strokeEnds.append(pose.length)
        }
        
        if let lastTimes = times.last {
            times.append(lastTimes)
        }
        rotations.append(rotations[0])
        strokeEnds.append(strokeEnds[0])
        
        animateKeyPath(keyPath: "strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
        animateKeyPath(keyPath: "transform.rotation", duration: totalSeconds, times: times, values: rotations)
        
        animateStrokeHueWithDuration(duration: totalSeconds * 5)
    }
    
    func animateKeyPath(keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]?
        animation.values = values
        animation.calculationMode = .linear
        animation.duration = duration
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
    
    func animateStrokeHueWithDuration(duration: CFTimeInterval) {
        let count = 36
        let animation = CAKeyframeAnimation(keyPath: "strokeColor")
        animation.keyTimes = (0 ... count).map { NSNumber(value: CFTimeInterval($0) / CFTimeInterval(count)) }
        
        animation.duration = duration
        animation.calculationMode = .linear
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
}

// MARK: - Nested

private extension LoaderView {
    
    struct Pose {
        let secondsSincePriorPose: CFTimeInterval
        let start: CGFloat
        let length: CGFloat
        
        init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
            self.secondsSincePriorPose = secondsSincePriorPose
            self.start = start
            self.length = length
        }
    }
    
}
