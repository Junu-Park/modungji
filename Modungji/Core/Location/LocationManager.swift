//
//  LocationManager.swift
//  Modungji
//
//  Created by 박준우 on 5/31/25.
//

import CoreLocation
import Combine
import UIKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager: CLLocationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        
        self.authorizationStatus = self.manager.authorizationStatus
        
        self.manager.delegate = self
    }
    
    func requestAuthorization() {
        switch self.authorizationStatus {
        case .notDetermined:
            self.manager.requestWhenInUseAuthorization()
        case .restricted:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        case .denied:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            self.manager.requestAlwaysAuthorization()
        case .authorized:
            break
        @unknown default:
            break
        }
    }
}
