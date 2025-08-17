//
//  AppDelegate.swift
//  Modungji
//
//  Created by 박준우 on 6/13/25.
//

import SwiftUI

import FirebaseCore
import FirebaseMessaging
import iamport_ios

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        Task {
            do {
                try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
            } catch {
                print(error)
            }
        }

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 영문 입력 상태에서 Option + Shift + K 누르면 애플 로고 나온당!
        print(" APNs device token: \(deviceToken.map { String(format: "%02x", $0) }.joined())")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Iamport.shared.receivedURL(url)
        
        return true
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("🔥 FCM registration token: \(fcmToken ?? "nil")")
        
        if let fcmToken {
            try? KeychainManager().save(tokenType: .deviceToken, token: fcmToken)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        
        return [.badge, .banner, .list, .sound]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
    }
}
