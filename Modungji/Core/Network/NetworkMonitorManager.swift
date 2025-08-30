//
//  NetworkMonitorManager.swift
//  Modungji
//
//  Created by 박준우 on 8/30/25.
//

import Combine
import Network

final class NetworkMonitorManager: ObservableObject {
    static let shared: NetworkMonitorManager = .init()
    
    @Published var isConnected: Bool = false
    
    private let monitor = NWPathMonitor()
    private var status: PassthroughSubject<NWPath.Status, Never> = .init()
    private var cancellables: Set<AnyCancellable> = .init()
    
    private init() {
        self.transform()
    }
    
    private func transform() {
        self.status
            .removeDuplicates()
            .map { $0 == .satisfied }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self else { return }
                
                self.isConnected = isConnected
            }
            .store(in: &self.cancellables)
    }
    
    func startMonitor() {
        self.monitor.start(queue: .global())
        
        self.status.send(self.monitor.currentPath.status)
        
        self.monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            self.status.send(path.status)
        }
    }
    
    func endMonitor() {
        self.monitor.cancel()
        self.cancellables.removeAll()
    }
}
