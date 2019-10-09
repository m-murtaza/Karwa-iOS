//
//  AppVersionUpdateNotifier.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/9/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation
public class AppVersionUpdateNotifier {
    static let KEY_APP_VERSION = "key_app_version"
    static let shared = AppVersionUpdateNotifier()

    private let userDefault:UserDefaults
    private var delegate:AppUpdateNotifier?

    public init() {
        self.userDefault = UserDefaults.standard
    }

    func initNotifier(_ delegate:AppUpdateNotifier) {
        self.delegate = delegate
        checkVersionAndNotify()
    }

    private func checkVersionAndNotify() {
        let versionOfLastRun = userDefault.object(forKey: AppVersionUpdateNotifier.KEY_APP_VERSION) as? Int
        let currentVersion = Int(Bundle.main.buildVersion)!

        if versionOfLastRun == nil {
            // First start after installing the app
            delegate?.onFirstLaunch()
        } else if versionOfLastRun != currentVersion {
            // App was updated since last run
            delegate?.onVersionUpdate(newVersion: currentVersion, oldVersion: versionOfLastRun!)
        } else {
            // nothing changed

        }
        userDefault.set(currentVersion, forKey: AppVersionUpdateNotifier.KEY_APP_VERSION)
    }
}

protocol AppUpdateNotifier {
    func onFirstLaunch()
    func onVersionUpdate(newVersion:Int, oldVersion:Int)
}
extension Bundle {
    var shortVersion: String {
        return infoDictionary!["CFBundleShortVersionString"] as! String
    }
    var buildVersion: String {
        return infoDictionary!["CFBundleVersion"] as! String
    }
}
