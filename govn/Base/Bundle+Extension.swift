//
//  Bundle+Extension.swift
//  indogo
//
//  Created by mac on 2020/9/8.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

extension Bundle {

    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }

    var bundleId: String {
        return bundleIdentifier!
    }

    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }

}
