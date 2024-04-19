//
//  NetworkMonitor.swift
//  Async Image Loading
//
//  Created by Akshay Kumar on 16/04/24.
//

import UIKit
import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let monitor: NWPathMonitor
    
    private(set) var isConnected = false
    private(set) var isExpensive = false
    private(set) var currentConnectionType: NWInterface.InterfaceType?
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.isExpensive = path.isExpensive
            self?.currentConnectionType = NWInterface.InterfaceType.allCases.filter { path.usesInterfaceType($0) }.first
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

extension NWInterface.InterfaceType: CaseIterable {
    public static var allCases: [NWInterface.InterfaceType] = [
        .other,
        .wifi,
        .cellular,
        .loopback,
        .wiredEthernet
    ]
}
