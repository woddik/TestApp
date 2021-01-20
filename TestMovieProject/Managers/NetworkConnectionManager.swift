//
//  NetworkConnectionManager.swift
//  TestMovieProject
//
//  Created by Woddi on 20.01.2021.
//

import Network

final class NetworkConnectionManager {

    // MARK: - Private properties
    
    private var status: NWPath.Status = .requiresConnection {
        didSet {
            didUpdate = true
        }
    }
    
    private let monitor = NWPathMonitor()

    // MARK: - Public properties
    
    static let shared = NetworkConnectionManager()
    
    static var isReachable: Bool {
        return shared.status == .satisfied
    }
    
    static private(set) var isReachableOnCellular: Bool = true
    
    private(set) var didUpdate: Bool = false

    // MARK: - Initializer
    
    private init() {
        startMonitoring()
    }
    
    // MARK: - Public methods

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            NetworkConnectionManager.isReachableOnCellular = path.isExpensive
            
            if path.status == .satisfied {
                print("We're connected!")
            } else {
                print("No connection.")
            }
            print(path.isExpensive)
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
