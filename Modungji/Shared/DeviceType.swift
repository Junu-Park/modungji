//
//  DeviceType.swift
//  Modungji
//
//  Created by 박준우 on 8/31/25.
//

import Foundation

enum DeviceType {
    case iPhone8, iPhone8Plus
    case iPhoneSE2, iPhoneSE3
    case iPhoneX, iPhoneXS, iPhoneXR
    case iPhoneXSMax
    case iPhone11, iPhone11Pro, iPhone11ProMax
    case iPhone12Mini, iPhone12, iPhone12Pro, iPhone12ProMax
    case iPhone13Mini, iPhone13, iPhone13Pro, iPhone13ProMax
    case iPhone14, iPhone14Plus, iPhone14Pro, iPhone14ProMax
    case iPhone15, iPhone15Plus, iPhone15Pro, iPhone15ProMax
    case iPhone16, iPhone16Plus, iPhone16Pro, iPhone16ProMax
    case unknown
    
    var keyboardHeight: CGFloat {
        switch self {
            // iPhone with Home Button
        case .iPhone8, .iPhoneSE2, .iPhoneSE3:
            return 216
        case .iPhone8Plus:
            return 226
            
            // iPhone X Series (Face ID)
        case .iPhoneX, .iPhoneXS, .iPhone11Pro:
            return 291
        case .iPhoneXR, .iPhone11:
            return 291
        case .iPhoneXSMax, .iPhone11ProMax:
            return 301
            
            // iPhone 12 Series
        case .iPhone12Mini:
            return 291
        case .iPhone12, .iPhone12Pro:
            return 291
        case .iPhone12ProMax:
            return 301
            
            // iPhone 13 Series
        case .iPhone13Mini:
            return 291
        case .iPhone13, .iPhone13Pro:
            return 291
        case .iPhone13ProMax:
            return 301
            
            // iPhone 14 Series
        case .iPhone14:
            return 291
        case .iPhone14Plus:
            return 301
        case .iPhone14Pro:
            return 291
        case .iPhone14ProMax:
            return 301
            
            // iPhone 15 Series
        case .iPhone15:
            return 291
        case .iPhone15Plus:
            return 301
        case .iPhone15Pro:
            return 291
        case .iPhone15ProMax:
            return 301
            
            // iPhone 16 Series
        case .iPhone16:
            return 291
        case .iPhone16Plus:
            return 301
        case .iPhone16Pro:
            return 291
        case .iPhone16ProMax:
            return 301
            
        case .unknown:
            return 291 // Default fallback
        }
    }
    
    private static func getDeviceModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    static func getDeviceType() -> Self {
        let name = DeviceType.getDeviceModelName()
        switch name {
            // iPhone 8 Series
        case "iPhone10,1", "iPhone10,4":
            return .iPhone8
        case "iPhone10,2", "iPhone10,5":
            return .iPhone8Plus
            
            // iPhone SE
        case "iPhone12,8":
            return .iPhoneSE2
        case "iPhone14,6":
            return .iPhoneSE3
            
            // iPhone X Series
        case "iPhone10,3", "iPhone10,6":
            return .iPhoneX
        case "iPhone11,2":
            return .iPhoneXS
        case "iPhone11,6":
            return .iPhoneXSMax
        case "iPhone11,8":
            return .iPhoneXR
            
            // iPhone 11 Series
        case "iPhone12,1":
            return .iPhone11
        case "iPhone12,3":
            return .iPhone11Pro
        case "iPhone12,5":
            return .iPhone11ProMax
            
            // iPhone 12 Series
        case "iPhone13,1":
            return .iPhone12Mini
        case "iPhone13,2":
            return .iPhone12
        case "iPhone13,3":
            return .iPhone12Pro
        case "iPhone13,4":
            return .iPhone12ProMax
            
            // iPhone 13 Series
        case "iPhone14,4":
            return .iPhone13Mini
        case "iPhone14,5":
            return .iPhone13
        case "iPhone14,2":
            return .iPhone13Pro
        case "iPhone14,3":
            return .iPhone13ProMax
            
            // iPhone 14 Series
        case "iPhone14,7":
            return .iPhone14
        case "iPhone14,8":
            return .iPhone14Plus
        case "iPhone15,2":
            return .iPhone14Pro
        case "iPhone15,3":
            return .iPhone14ProMax
            
            // iPhone 15 Series
        case "iPhone15,4":
            return .iPhone15
        case "iPhone15,5":
            return .iPhone15Plus
        case "iPhone16,1":
            return .iPhone15Pro
        case "iPhone16,2":
            return .iPhone15ProMax
            
            // iPhone 16 Series
        case "iPhone17,3":
            return .iPhone16
        case "iPhone17,4":
            return .iPhone16Plus
        case "iPhone17,1":
            return .iPhone16Pro
        case "iPhone17,2":
            return .iPhone16ProMax
            
        default:
            return .unknown
        }
    }
}
