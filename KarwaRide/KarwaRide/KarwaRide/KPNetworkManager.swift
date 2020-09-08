//
//  KPNetworkManager.swift
//  KarwaRide
//
//  Created by Sam Ash on 9/8/20.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class KPNetworkManager {

    var Manager: SessionManager?

    init() {
        let serverTrustPolicies: [String: ServerTrustPolicy] =
            [
                "https://*.karwatechnologies.com": .pinCertificates(
                    certificates: ServerTrustPolicy.certificates(),
                    validateCertificateChain: true,
                    validateHost: true),
                "insecure.expired-apis.com": .disableEvaluation
            ]

        Manager = SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }
}
