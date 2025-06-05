//
//  LocationManager.swift
//  Modungji
//
//  Created by 박준우 on 5/31/25.
//

import Combine
import CoreLocation
import UIKit

struct LocationManager {
    
    func getAuthorizationState() -> CLAuthorizationStatus {
        return CLLocationManager().authorizationStatus
    }
    
    func requestWhenInUseAuthorization() {
        CLLocationManager().requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        CLLocationManager().requestAlwaysAuthorization()
    }
    
    func openAppSetting() async {
        let url = URL(string: UIApplication.openSettingsURLString)!
        await UIApplication.shared.open(url)
    }
}
