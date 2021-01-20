//
//  Debouncer.swift
//
//  Created by Woddi on 7/16/19.
//  Copyright © 2019 Woddi. All rights reserved.
//

import Foundation

final class Debouncer {
    
    // MARK: - Properties
    private let queue = DispatchQueue.main
    private var workItem: DispatchWorkItem?
    
    private var searchCount: UInt?
    private var completion: () -> Void = { }
    
    var interval: TimeInterval
    
    var isEnable: Bool {
        return workItem?.isCancelled == false
    }
    
    func subRequestEnter() {
        if searchCount == nil {
            searchCount = 0
        }
        searchCount? += 1
    }
    
    func subRequestLeave() {
        searchCount? -= 1
        verifyCompletion()
    }
    
    func notify(completion: @escaping () -> Void) {
        self.completion = completion
        verifyCompletion(force: true)
    }
    
    func notifyWhenSubProcessLeave(completion: @escaping () -> Void) {
        self.completion = completion
        verifyCompletion()
    }
    
    // MARK: - Initializer
    init(seconds: TimeInterval) {
        self.interval = seconds
    }
    
    // MARK: - Debouncing function
    func debounce(action: @escaping (() -> Void)) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: { action() })
        queue.asyncAfter(deadline: .now() + interval, execute: workItem!) //swiftlint:disable:this force_unwrapping
    }
    
    func debounce(action: @escaping ((_ debouncer: Debouncer) -> Void)) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: {
            action(self)
        })
        queue.asyncAfter(deadline: .now() + interval, execute: workItem!) //swiftlint:disable:this force_unwrapping
    }
    
    func stop() {
        workItem?.cancel()
    }
}

// MARK: - Private methods

private extension Debouncer {
    
    func verifyCompletion(force: Bool = false) {
        if searchCount == 0 || force && searchCount.isEmptyOrNil {
            completion()
        }
    }
}

fileprivate extension Optional where Wrapped == UInt {
    
    var isEmptyOrNil: Bool {
        return self == nil || self == 0
    }
}
