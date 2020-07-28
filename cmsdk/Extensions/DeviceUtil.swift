//
//  DeviceUtil.swift
//  position_tracking
//

import Foundation

/// Used to obtain device model
class DeviceUtil {
    func userDeviceName() -> String {
        let platform: String = {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0,  count: Int(size))
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            return String(cString: machine)
        }()

        //iPhone
        if platform == "iPhone1,1"        { return "iPhone (1st generation)" }
        else if platform == "iPhone1,2"   { return "iPhone 3G" }
        else if platform == "iPhone2,1"   { return "iPhone 3GS" }
        else if platform == "iPhone3,1"   { return "iPhone 4 (GSM)" }
        else if platform == "iPhone3,2"   { return "iPhone 4 (GSM, 2nd revision)" }
        else if platform == "iPhone3,3"   { return "iPhone 4 (CDMA)" }
        else if platform == "iPhone4,1"   { return "iPhone 4S" }
        else if platform == "iPhone5,1"   { return "iPhone 5 (GSM)" }
        else if platform == "iPhone5,2"   { return "iPhone 5 (GSM+CDMA)" }
        else if platform == "iPhone5,3"   { return "iPhone 5c (GSM)" }
        else if platform == "iPhone5,4"   { return "iPhone 5c (GSM+CDMA)" }
        else if platform == "iPhone6,1"   { return "iPhone 5s (GSM)" }
        else if platform == "iPhone6,2"   { return "iPhone 5s (GSM+CDMA)" }
        else if platform == "iPhone7,2"   { return "iPhone 6" }
        else if platform == "iPhone7,1"   { return "iPhone 6 Plus" }
        else if platform == "iPhone8,1"   { return "iPhone 6s" }
        else if platform == "iPhone8,2"   { return "iPhone 6s Plus" }
        else if platform == "iPhone8,4"   { return "iPhone SE" }
        else if platform == "iPhone9,1"   { return "iPhone 7 (GSM+CDMA)" }
        else if platform == "iPhone9,3"   { return "iPhone 7 (GSM)" }
        else if platform == "iPhone9,2"   { return "iPhone 7 Plus (GSM+CDMA)" }
        else if platform == "iPhone9,4"   { return "iPhone 7 Plus (GSM)" }
        else if platform == "iPhone10,1"  { return "iPhone 8 (GSM+CDMA)" }
        else if platform == "iPhone10,4"  { return "iPhone 8 (GSM)" }
        else if platform == "iPhone10,2"  { return "iPhone 8 Plus (GSM+CDMA)" }
        else if platform == "iPhone10,5"  { return "iPhone 8 Plus (GSM)" }
        else if platform == "iPhone10,3"  { return "iPhone X (GSM+CDMA)" }
        else if platform == "iPhone10,6"  { return "iPhone X (GSM)" }
        else if platform == "iPhone11,2"  { return "iPhone XS" }
        else if platform == "iPhone11,6"  { return "iPhone XS Max" }
        else if platform == "iPhone11,8"  { return "iPhone XR" }
        else if platform == "iPhone12,1"  { return "iPhone 11" }
        else if platform == "iPhone12,3"  { return "iPhone 11 Pro" }
        else if platform == "iPhone12,5"  { return "iPhone 11 Pro Max" }

        //iPod Touch
        else if platform == "iPod1,1"     { return "iPod Touch (1st generation)" }
        else if platform == "iPod2,1"     { return "iPod Touch (2nd generation)" }
        else if platform == "iPod3,1"     { return "iPod Touch (3rd generation)" }
        else if platform == "iPod4,1"     { return "iPod Touch (4th generation)" }
        else if platform == "iPod5,1"     { return "iPod Touch (5th generation)" }
        else if platform == "iPod7,1"     { return "iPod Touch (6th generation)" }
        else if platform == "iPod9,1"     { return "iPod Touch (7th generation)" }

        //iPad
        else if platform == "iPad1,1"     { return "iPad (1st generation)" }
        else if platform == "iPad2,1"     { return "iPad 2 (Wi-Fi)" }
        else if platform == "iPad2,2"     { return "iPad 2 (GSM)" }
        else if platform == "iPad2,3"     { return "iPad 2 (CDMA)" }
        else if platform == "iPad2,4"     { return "iPad 2 (Wi-Fi, Mid 2012)" }
        else if platform == "iPad3,1"     { return "iPad (3rd generation) (Wi-Fi)" }
        else if platform == "iPad3,2"     { return "iPad (3rd generation) (GSM+CDMA)" }
        else if platform == "iPad3,3"     { return "iPad (3rd generation) (GSM)" }
        else if platform == "iPad3,4"     { return "iPad (4th generation) (Wi-Fi)"}
        else if platform == "iPad3,5"     { return "iPad (4th generation) (GSM)" }
        else if platform == "iPad3,6"     { return "iPad (4th generation) (GSM+CDMA)" }
        else if platform == "iPad6,11"    { return "iPad (5th generation) (Wi-Fi)" }
        else if platform == "iPad6,12"    { return "iPad (5th generation) (Cellular)" }
        else if platform == "iPad7,5"     { return "iPad (6th generation) (Wi-Fi)" }
        else if platform == "iPad7,6"     { return "iPad (6th generation) (Cellular)" }
        else if platform == "iPad7,11"     { return "iPad (7th generation) (Wi-Fi)" }
        else if platform == "iPad7,12"     { return "iPad (7th generation) (Cellular)" }

        //iPad Mini
        else if platform == "iPad2,5"     { return "iPad mini (Wi-Fi)" }
        else if platform == "iPad2,6"     { return "iPad mini (GSM)" }
        else if platform == "iPad2,7"     { return "iPad mini (GSM+CDMA)" }
        else if platform == "iPad4,4"     { return "iPad mini 2 (Wi-Fi)" }
        else if platform == "iPad4,5"     { return "iPad mini 2 (Cellular)" }
        else if platform == "iPad4,6"     { return "iPad mini 2 (China)" }
        else if platform == "iPad4,7"     { return "iPad mini 3 (Wi-Fi)" }
        else if platform == "iPad4,8"     { return "iPad mini 3 (Cellular)" }
        else if platform == "iPad4,9"     { return "iPad mini 3 (China)" }
        else if platform == "iPad5,1"     { return "iPad mini 4 (Wi-Fi)" }
        else if platform == "iPad5,2"     { return "iPad mini 4 (Cellular)" }
        else if platform == "iPad11,1"    { return "iPad mini (5th generation) (Wi-Fi)" }
        else if platform == "iPad11,2"    { return "iPad mini (5th generation)  (Cellular)" }

        //iPad Air
        else if platform == "iPad4,1"     { return "iPad Air (Wi-Fi)" }
        else if platform == "iPad4,2"     { return "iPad Air (Cellular)" }
        else if platform == "iPad4,3"     { return "iPad Air (China)" }
        else if platform == "iPad5,3"     { return "iPad Air 2 (Wi-Fi)" }
        else if platform == "iPad5,4"     { return "iPad Air 2 (Cellular)" }
        else if platform == "iPad11,3"    { return "iPad Air (3rd generation) (Wi-Fi)" }
        else if platform == "iPad11,4"    { return "iPad Air (3rd generation) (Cellular)" }

        //iPad Pro
        else if platform == "iPad6,3"     { return "iPad Pro 9.7\" (Wi-Fi)" }
        else if platform == "iPad6,4"     { return "iPad Pro 9.7\" (Cellular)" }
        else if platform == "iPad6,7"     { return "iPad Pro 12.9\" (Wi-Fi)" }
        else if platform == "iPad6,8"     { return "iPad Pro 12.9\" (Cellular)" }
        else if platform == "iPad7,1"     { return "iPad Pro 12.9\" (2nd generation) (Wi-Fi)" }
        else if platform == "iPad7,2"     { return "iPad Pro 12.9\" (2nd generation) (Cellular)" }
        else if platform == "iPad7,3"     { return "iPad Pro 10.5\" (Wi-Fi)" }
        else if platform == "iPad7,4"     { return "iPad Pro 10.5\" (Cellular)" }
        else if platform == "iPad8,1"     { return "iPad Pro 11\" (Wi-Fi)" }
        else if platform == "iPad8,2"     { return "iPad Pro 11\" (Wi-Fi, 1TB)" }
        else if platform == "iPad8,3"     { return "iPad Pro 11\" (Cellular)" }
        else if platform == "iPad8,4"     { return "iPad Pro 11\" (Cellular 1TB)" }
        else if platform == "iPad8,5"     { return "iPad Pro 12.9\" (3rd generation) (Wi-Fi)" }
        else if platform == "iPad8,6"     { return "iPad Pro 12.9\" (3rd generation) (Cellular)" }
        else if platform == "iPad8,7"     { return "iPad Pro 12.9\" (3rd generation) (Wi-Fi, 1TB)" }
        else if platform == "iPad8,8"     { return "iPad Pro 12.9\" (3rd generation) (Cellular, 1TB)" }

        //Apple TV
        else if platform == "AppleTV2,1"  { return "Apple TV 2G" }
        else if platform == "AppleTV3,1"  { return "Apple TV 3" }
        else if platform == "AppleTV3,2"  { return "Apple TV 3 (2013)" }
        else if platform == "AppleTV5,3"  { return "Apple TV 4" }
        else if platform == "AppleTV6,2"  { return "Apple TV 4K" }

        //Apple Watch
        else if platform == "Watch1,1"    { return "Apple Watch (1st generation) (38mm)" }
        else if platform == "Watch1,2"    { return "Apple Watch (1st generation) (42mm)" }
        else if platform == "Watch2,6"    { return "Apple Watch Series 1 (38mm)" }
        else if platform == "Watch2,7"    { return "Apple Watch Series 1 (42mm)" }
        else if platform == "Watch2,3"    { return "Apple Watch Series 2 (38mm)" }
        else if platform == "Watch2,4"    { return "Apple Watch Series 2 (42mm)" }
        else if platform == "Watch3,1"    { return "Apple Watch Series 3 (38mm Cellular)" }
        else if platform == "Watch3,2"    { return "Apple Watch Series 3 (42mm Cellular)" }
        else if platform == "Watch3,3"    { return "Apple Watch Series 3 (38mm)" }
        else if platform == "Watch3,4"    { return "Apple Watch Series 3 (42mm)" }
        else if platform == "Watch4,1"    { return "Apple Watch Series 4 (40mm)" }
        else if platform == "Watch4,2"    { return "Apple Watch Series 4 (44mm)" }
        else if platform == "Watch4,3"    { return "Apple Watch Series 4 (40mm Cellular)" }
        else if platform == "Watch4,4"    { return "Apple Watch Series 4 (44mm Cellular)" }
        //else if platform == "Watch"    { return "Apple Watch Series 5 (40mm)" } //5,1?
        //else if platform == "Watch"    { return "Apple Watch Series 5 (44mm)" } //5,2?
        //else if platform == "Watch"    { return "Apple Watch Series 5 (40mm Cellular)" } //5,3?
        //else if platform == "Watch"    { return "Apple Watch Series 5 (44mm Cellular)" } //5,4?

        //Simulator
        else if platform == "i386"        { return "Simulator" }
        else if platform == "x86_64"      { return "Simulator"}

        return platform
    }

}

