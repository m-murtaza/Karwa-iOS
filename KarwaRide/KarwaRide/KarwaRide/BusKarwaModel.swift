//
//  BusKarwaModel.swift
//  KarwaRide
//
//  Created by Apple on 25/01/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import Foundation

struct KarwaBusRoute: Codable {
    var requestParameters: RequestParameters?
    var plan: Plan?
    var metadata: Metadata?
    var debugOutput: DebugOutput?
    var elevationMetaData: ElevationMetadata?
    
//    enum CodingKeys: CodingKey {
//        case requestParameters, plan, metadata, debugOutput, elevationMetaData
//    }

//
//    init(from decoder: Decoder) throws {
//            let container: try decoder.container(keyedBy: CodingKeys.self)
//            name: try container.decode(String.self, forKey: .name)
//            age: try container.decode(Int.self, forKey: .age)
//            if let detail: try container.decodeIfPresent(Detail.self, forKey: .detail) {
//                self.detail: detail
//            } else {
//                let data: try Data(contentsOf: Bundle.main.url(forResource: "mockupDetail", withExtension: "json")!)
//                self.detail: try JSONDecoder().decode(Detail.self, from: data)
//            }
//        }
}

// MARK: - RequestParameters
struct RequestParameters: Codable {
    var mode, arriveBy, wheelchair, debugItineraryFilter: String?
    var fromPlace, toPlace, maxWalkDistance, locale: String?
}

// MARK: - DebugOutput
struct DebugOutput: Codable {
    let precalculationTime, directStreetRouterTime, transitRouterTime, filteringTime: Int?
    let renderingTime, totalTime: Int?
    let transitRouterTimes: TransitRouterTimes?
}

// MARK: - TransitRouterTimes
struct TransitRouterTimes: Codable {
    let tripPatternFilterTime, accessEgressTime, raptorSearchTime, itineraryCreationTime: Int?
}

// MARK: - Metadata
struct Metadata: Codable {
    let searchWindowUsed, nextDateTime, prevDateTime: Int?
}

// MARK: - ElevationMetadata
struct ElevationMetadata: Codable {
//    let ellipsoidToGeoidDifference: Float?
    let geoidElevation: Bool?
}

// MARK: - Plan
struct Plan: Codable {
    let date: Int?
    let from, to: PlanFromTo?
    let itineraries: [Itinerary]?
}

// MARK: - PlanFrom
struct PlanFromTo: Codable {
    let name: String?
    let lon, lat: Double?
    let vertexType: String?
}

// MARK: - Itinerary
struct Itinerary: Codable {
    let duration, startTime, endTime, walkTime: Int?
    let transitTime, waitingTime: Int?
    let walkDistance: Double?
    let walkLimitExceeded: Bool?
    let elevationLost, elevationGained, transfers: Int?
//    let fare: Fare?
    let legs: [Leg]?
    let tooSloped: Bool?
}

// MARK: - Fare
struct Fare: Codable {
    let fare, details: Details?
}

// MARK: - Details
struct Details: Codable {
}

// MARK: - Leg
struct Leg: Codable {
    let startTime, endTime, departureDelay, arrivalDelay: Int?
    let realTime: Bool?
    let distance: Double?
    let pathway: Bool?
    let mode: String?
    let transitLeg: Bool?
    let route: String?
    let agencyTimeZoneOffset: Int?
    let interlineWithPreviousLeg: Bool?
    let from, to: LegFrom?
    let legGeometry: LegGeometry?
    let steps: [Step]?
    let rentedBike: Bool?
    let duration: Int?
    let agencyName: String?
    let agencyUrl: String?
    let routeColor, routeId, routeTextColor, headsign: String?
    let agencyId, tripId, serviceDate: String?
    let intermediateStops: [String]?
    let routeShortName: String?
    let routeLongName: String?
}

// MARK: - LegFrom
struct LegFrom: Codable {
    let name: String?
    let lon, lat: Double?
    let departure: Int?
    let vertexType: String?
    let stopID: String?
    let arrival, stopIndex: Int?

    enum CodingKeys: String, CodingKey {
        case name, lon, lat, departure, vertexType
        case stopID = "stopId"
        case arrival, stopIndex
    }
}

// MARK: - LegGeometry
struct LegGeometry: Codable {
    let points: String?
    let length: Int?
}

// MARK: - Step
struct Step: Codable {
    let distance: Double?
    let relativeDirection: RelativeDirection?
    let streetName: String?
    let absoluteDirection: AbsoluteDirection?
    let stayOn, area, bogusName: Bool?
    let lon, lat: Double?
    let elevation: String?
}

enum AbsoluteDirection: String, Codable {
    case east = "EAST"
    case north = "NORTH"
    case northeast = "NORTHEAST"
    case northwest = "NORTHWEST"
    case south = "SOUTH"
    case southeast = "SOUTHEAST"
    case southwest = "SOUTHWEST"
    case west = "WEST"
}

enum RelativeDirection: String, Codable {
    case depart = "DEPART"
    case relativeDirectionCONTINUE = "CONTINUE"
    case relativeDirectionLEFT = "LEFT"
    case relativeDirectionRIGHT = "RIGHT"
    case slightlyLeft = "SLIGHTLY_LEFT"
    case slightlyRight = "SLIGHTLY_RIGHT"
}

let mockRoute: [String: [String: Any]] = [
    "requestParameters": [
      "mode": "TRANSIT,WALK",
      "arriveBy": "false",
      "wheelchair": "false",
      "debugItineraryFilter": "false",
      "fromPlace": "25.19251511519153,51.503562927246094",
      "toPlace": "25.2468696669746,51.56261444091796",
      "maxWalkDistance": "4828.032",
      "locale": "en"
    ],
    "plan": [
      "date": 1642511541000,
      "from": [
        "name": "Origin",
        "lon": 51.503562927246094,
        "lat": 25.19251511519153,
        "vertexType": "NORMAL"
      ],
      "to": [
        "name": "Destination",
        "lon": 51.56261444091796,
        "lat": 25.2468696669746,
        "vertexType": "NORMAL"
      ],
      "itineraries": [
        [
          "duration": 8662,
          "startTime": 1642511541000,
          "endTime": 1642520203000,
          "walkTime": 8662,
          "transitTime": 0,
          "waitingTime": 0,
          "walkDistance": 11299.841999999999,
          "walkLimitExceeded": true,
          "elevationLost": 0,
          "elevationGained": 0,
          "transfers": 0,
          "fare": [
            "fare": [],
            "details": []
          ],
          "legs": [
            [
              "startTime": 1642511541000,
              "endTime": 1642520203000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 11299.841999999999,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Origin",
                "lon": 51.503562927246094,
                "lat": 25.19251511519153,
                "departure": 1642511541000,
                "vertexType": "NORMAL"
              ],
              "to": [
                "name": "Destination",
                "lon": 51.56261444091796,
                "lat": 25.2468696669746,
                "arrival": 1642520203000,
                "vertexType": "NORMAL"
              ],
              "legGeometry": [
                "points": "[lwxCyijyH]@`@ED?H~@tCi@Pm@cBqBz@eCfAsClAuClAcCdAoBx@_ByEGUcAyCEMMIOCI?[CrAaAb@QGIGEGmBuFg@[@wCcJK[EOiF]Oe@q@WSSEQG]A_@BkBv@c@NuKjEoUhJqAd@WJIYmNzFeBn@uCbAqBt@s@`@sAhAcA|@[@r@]Rc@Nu@Ny@BaAM_A[k@Ys@a@gBuAsEsDcKeIcDeCaAk@_BgAeE_DgDgCgB[AeA_ASWaAcA_@_@_AeAaDoDeEqFaEqFuAkB[@aAu@i@kA[@y@o@m@g@c@[US[[A?[a@w@[@OScCuC_@g@W_@GGYg@iA[AuAaBo@[@oBgC_ByBcB]BcBwB_@u@So@Ko@Cy@Bm@N]@\\_A~AuCd@qBDe@Bk@?q@EcBEo@Ik@Wy@e@[@qA]BYa@[i@[k@Wo@]cAOc@GSI[Ii@ESG_@UcBKiBIuBSwC[mEM[BOcCQiDQaDCi@y@kOU]DMeCIqBSuFQ_EKoBW[E[sFOkBGq@OOEIAMEk@kA_P]oBc@qHM]AQcB[@cHQi@MWMKWCk@RODo@Ta@JMDa@NoBkJq@wDSgAIa@wDz@i@NWHm@Po@PSkAy@kEOw@Qq@WiACEq@aCu@\\cA_EU]@u@uC]uA",
                "length": 193
              ],
              "steps": [
                [
                  "distance": 155.685,
                  "relativeDirection": "DEPART",
                  "streetName": "road",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.50381230435444,
                  "lat": 25.192624941464175,
                  "elevation": ""
                ],
                [
                  "distance": 56.139,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1125",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5027223,
                  "lat": 25.1928528,
                  "elevation": ""
                ],
                [
                  "distance": 486.661,
                  "relativeDirection": "LEFT",
                  "streetName": "Street 1132",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.503220500000005,
                  "lat": 25.193080100000003,
                  "elevation": ""
                ],
                [
                  "distance": 251.787,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1127",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5011449,
                  "lat": 25.1970333,
                  "elevation": ""
                ],
                [
                  "distance": 137.065,
                  "relativeDirection": "SLIGHTLY_LEFT",
                  "streetName": "Street 1121",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5032593,
                  "lat": 25.198125400000002,
                  "elevation": ""
                ],
                [
                  "distance": 198.585,
                  "relativeDirection": "RIGHT",
                  "streetName": "link",
                  "absoluteDirection": "NORTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.5026596,
                  "lat": 25.1992322,
                  "elevation": ""
                ],
                [
                  "distance": 524.355,
                  "relativeDirection": "CONTINUE",
                  "streetName": "Street 1138",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5043086,
                  "lat": 25.2001506,
                  "elevation": ""
                ],
                [
                  "distance": 105.923,
                  "relativeDirection": "CONTINUE",
                  "streetName": "link",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.509014400000005,
                  "lat": 25.202177300000002,
                  "elevation": ""
                ],
                [
                  "distance": 1803.0639999999999,
                  "relativeDirection": "SLIGHTLY_LEFT",
                  "streetName": "Street 1115",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5094234,
                  "lat": 25.2029846,
                  "elevation": ""
                ],
                [
                  "distance": 3680.165,
                  "relativeDirection": "CONTINUE",
                  "streetName": "road",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.5031218,
                  "lat": 25.2175531,
                  "elevation": ""
                ],
                [
                  "distance": 1774.151,
                  "relativeDirection": "CONTINUE",
                  "streetName": "E Ring Road",
                  "absoluteDirection": "EAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.529625,
                  "lat": 25.237218700000003,
                  "elevation": ""
                ],
                [
                  "distance": 382.988,
                  "relativeDirection": "SLIGHTLY_LEFT",
                  "streetName": "link",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.54711270000001,
                  "lat": 25.2392423,
                  "elevation": ""
                ],
                [
                  "distance": 405.367,
                  "relativeDirection": "CONTINUE",
                  "streetName": "E Ring Road",
                  "absoluteDirection": "EAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.550810000000006,
                  "lat": 25.2399214,
                  "elevation": ""
                ],
                [
                  "distance": 175.432,
                  "relativeDirection": "CONTINUE",
                  "streetName": "Marwan Bin Al Hakam Street",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.554774300000005,
                  "lat": 25.240561900000003,
                  "elevation": ""
                ],
                [
                  "distance": 290.053,
                  "relativeDirection": "RIGHT",
                  "streetName": "Mohammed Bin Shehab",
                  "absoluteDirection": "EAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5547782,
                  "lat": 25.2418693,
                  "elevation": ""
                ],
                [
                  "distance": 55.295,
                  "relativeDirection": "CONTINUE",
                  "streetName": "path",
                  "absoluteDirection": "EAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.5575193,
                  "lat": 25.2426794,
                  "elevation": ""
                ],
                [
                  "distance": 200.73499999999999,
                  "relativeDirection": "LEFT",
                  "streetName": "Tadmur Street",
                  "absoluteDirection": "NORTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.558044,
                  "lat": 25.2428279,
                  "elevation": ""
                ],
                [
                  "distance": 317.809,
                  "relativeDirection": "RIGHT",
                  "streetName": "Labeed Bin Rabya",
                  "absoluteDirection": "EAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5574324,
                  "lat": 25.2445455,
                  "elevation": ""
                ],
                [
                  "distance": 34.008,
                  "relativeDirection": "LEFT",
                  "streetName": "Al Rawdha Street",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.56041080000001,
                  "lat": 25.2454915,
                  "elevation": ""
                ],
                [
                  "distance": 264.575,
                  "relativeDirection": "RIGHT",
                  "streetName": "Amr Bin Othman",
                  "absoluteDirection": "EAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.560266500000004,
                  "lat": 25.245768100000003,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 8662
            ]
          ],
          "tooSloped": false
        ],
        [
          "duration": 3590,
          "startTime": 1642511827000,
          "endTime": 1642515417000,
          "walkTime": 1727,
          "transitTime": 1680,
          "waitingTime": 183,
          "walkDistance": 2234.411,
          "walkLimitExceeded": false,
          "elevationLost": 0,
          "elevationGained": 0,
          "transfers": 1,
          "legs": [
            [
              "startTime": 1642511827000,
              "endTime": 1642512055000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 281.293,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Origin",
                "lon": 51.503562927246094,
                "lat": 25.19251511519153,
                "departure": 1642511827000,
                "vertexType": "NORMAL"
              ],
              "to": [
                "name": "Street 1131",
                "stopId": "1=56006",
                "lon": 51.502455,
                "lat": 25.19191,
                "arrival": 1642512055000,
                "departure": 1642512055000,
                "stopIndex": 6,
                "vertexType": "TRANSIT"
              ],
              "legGeometry": [
                "points": "[lwxCyijyH~@a@NAFF^bAd@SbA`DBJ?LAFEPmAf@AA",
                "length": 13
              ],
              "steps": [
                [
                  "distance": 116.41999999999999,
                  "relativeDirection": "DEPART",
                  "streetName": "road",
                  "absoluteDirection": "SOUTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.50381230435444,
                  "lat": 25.192624941464175,
                  "elevation": ""
                ],
                [
                  "distance": 116.733,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1123",
                  "absoluteDirection": "SOUTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.503713700000006,
                  "lat": 25.191834800000002,
                  "elevation": ""
                ],
                [
                  "distance": 48.14,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1131",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.502647,
                  "lat": 25.1915134,
                  "elevation": ""
                ],
                [
                  "distance": 0,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1131",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": true,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.50244849236183,
                  "lat": 25.191907314734404,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 228
            ],
            [
              "startTime": 1642512055000,
              "endTime": 1642513435000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 15687.449330992957,
              "pathway": false,
              "mode": "BUS",
              "transitLeg": true,
              "route": "Free Zone Station-Circular",
              "agencyName": "Mowasalat",
              "agencyUrl": "http=//mowasalat.com",
              "agencyTimeZoneOffset": 0,
              "routeColor": "ED2427",
              "routeId": "1=02140",
              "routeTextColor": "FFFFFF",
              "headsign": "Free Zone Station - via Barwa City - Messaimer - Religious Complex",
              "agencyId": "1=1",
              "tripId": "1=31905",
              "serviceDate": "2022-01-18",
              "from": [
                "name": "Street 1131",
                "stopId": "1=56006",
                "lon": 51.502455,
                "lat": 25.19191,
                "arrival": 1642512055000,
                "departure": 1642512055000,
                "stopIndex": 6,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Free Zone Station",
                "stopId": "1=50500",
                "lon": 51.57708,
                "lat": 25.227664,
                "arrival": 1642513435000,
                "departure": 1642513435000,
                "stopIndex": 18,
                "vertexType": "TRANSIT"
              ],
              "intermediateStops": [],
              "legGeometry": [
                "points": "khwxCiajyHwB`AINxAlE?NGHKHeGfC??cNzFQAGC]@uC??Ww@EGOCKBaEfBW@ICGGaCmH??aP]e@??eEeMeQii@iFsOe@_BaB_Ho@_D[cB??yAoIi@]BeAeGGQQKOEWAmWbGwAd@mFjASHOREV@ZfBjJj@`D??xA|I@TCf@?NLNT?LGHIDINKrHcBZEd@HTANOBYEMa@o@w@qE??qAuH??qA[H@_@L]LSVOjGcB|DkAlDq@PI\\a@Bc@sBuL??yKmo@?SFq@AUKKMISAUD[^_@N]_@nIc@Fs@GWFMLET@RNTPNHP~DfV??jBbL@^ENBVjBlK\\xA??`A`EAd@K^_@`@[Bh@qDj@OFUNqG^]Fg@Ri@Lg@BYCOIKOQi@R]F?sH_@qHi@cHg@[DqAsI]Jal@sLqs@[EiX]Igi@mEqV_BeLyAkLs@iIk@mHM_C_A[Kk@sDqBcL[mACc@H[V[nAq@pIkDXAVDZh@LDN?d@O",
                "length": 163
              ],
              "steps": [],
              "routeShortName": "M140",
              "routeLongName": "Free Zone Station-Circular",
              "duration": 1380
            ],
            [
              "startTime": 1642513435000,
              "endTime": 1642514212000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 1034.873,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Free Zone Station",
                "stopId": "1=50500",
                "lon": 51.57708,
                "lat": 25.227664,
                "arrival": 1642513435000,
                "departure": 1642513435000,
                "stopIndex": 18,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Nabina Trading",
                "stopId": "1=4835",
                "lon": 51.573792,
                "lat": 25.236031,
                "arrival": 1642514212000,
                "departure": 1642514395000,
                "stopIndex": 1,
                "vertexType": "TRANSIT"
              ],
              "legGeometry": [
                "points": "[g~xCwsxyHEMgAb@_@NOs@GGQGM?cA\\QH_C|@qCrA]@d@QLIRKCGAQJQFgAf@MDUFIN?JSC]DcAh@g@Hg@LILML[@\\eBv@_DtAg@RMDQHkCjAwAl@g@[A",
                "length": 40
              ],
              "steps": [
                [
                  "distance": 43.844,
                  "relativeDirection": "DEPART",
                  "streetName": "service road",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.57715933554725,
                  "lat": 25.227696484847893,
                  "elevation": ""
                ],
                [
                  "distance": 19.413,
                  "relativeDirection": "CONTINUE",
                  "streetName": "G Ring Cycle Path",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5769796,
                  "lat": 25.228055700000002,
                  "elevation": ""
                ],
                [
                  "distance": 336.145,
                  "relativeDirection": "RIGHT",
                  "streetName": "G Ring Cycle Path",
                  "absoluteDirection": "EAST",
                  "stayOn": true,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5768994,
                  "lat": 25.2282145,
                  "elevation": ""
                ],
                [
                  "distance": 11.471,
                  "relativeDirection": "RIGHT",
                  "streetName": "F Ring Cycle Path",
                  "absoluteDirection": "NORTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5759472,
                  "lat": 25.230749000000003,
                  "elevation": ""
                ],
                [
                  "distance": 221.322,
                  "relativeDirection": "LEFT",
                  "streetName": "bike path",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.575974,
                  "lat": 25.2308492,
                  "elevation": ""
                ],
                [
                  "distance": 402.678,
                  "relativeDirection": "SLIGHTLY_LEFT",
                  "streetName": "Al Matar Street",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.575125400000005,
                  "lat": 25.232605000000003,
                  "elevation": ""
                ],
                [
                  "distance": 0,
                  "relativeDirection": "RIGHT",
                  "streetName": "Nabina Trading",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.57333179408837,
                  "lat": 25.235830701405906,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 777
            ],
            [
              "startTime": 1642514395000,
              "endTime": 1642514695000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 2040.2890758935919,
              "pathway": false,
              "mode": "BUS",
              "transitLeg": true,
              "route": "New Airport-Circular",
              "agencyName": "Mowasalat",
              "agencyUrl": "http=//mowasalat.com",
              "agencyTimeZoneOffset": 0,
              "routeColor": "F6545E",
              "routeId": "1=00757",
              "routeTextColor": "FFFFFF",
              "headsign": "Hamad International Airport - Mansoura Circular Via Al Matar Al Qadeem",
              "agencyId": "1=1",
              "tripId": "1=32176",
              "serviceDate": "2022-01-18",
              "from": [
                "name": "Nabina Trading",
                "stopId": "1=4835",
                "lon": 51.573792,
                "lat": 25.236031,
                "arrival": 1642514212000,
                "departure": 1642514395000,
                "stopIndex": 1,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Al Rawnaq Trading",
                "stopId": "1=4827",
                "lon": 51.56484,
                "lat": 25.252496,
                "arrival": 1642514695000,
                "departure": 1642514695000,
                "stopIndex": 3,
                "vertexType": "TRANSIT"
              ],
              "intermediateStops": [],
              "legGeometry": [
                "points": "w[_yCe~wyHqf@jT??su@n\\yGvC",
                "length": 5
              ],
              "steps": [],
              "routeShortName": "757",
              "routeLongName": "New Airport-Circular",
              "duration": 300
            ],
            [
              "startTime": 1642514695000,
              "endTime": 1642515417000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 918.2450000000001,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Al Rawnaq Trading",
                "stopId": "1=4827",
                "lon": 51.56484,
                "lat": 25.252496,
                "arrival": 1642514695000,
                "departure": 1642514695000,
                "stopIndex": 3,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Destination",
                "lon": 51.56261444091796,
                "lat": 25.2468696669746,
                "arrival": 1642515417000,
                "vertexType": "NORMAL"
              ],
              "legGeometry": [
                "points": "accyCggvyHZbAx@[NIzEsBd@QlAk@VKNAFDFN~@vCLEr@|Bd@|A~@tC~@xCzCcAnC]@|@[Rt@",
                "length": 21
              ],
              "steps": [
                [
                  "distance": 0,
                  "relativeDirection": "DEPART",
                  "streetName": "Al Rawnaq Trading",
                  "absoluteDirection": "SOUTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.56484,
                  "lat": 25.252496,
                  "elevation": ""
                ],
                [
                  "distance": 267.651,
                  "relativeDirection": "LEFT",
                  "streetName": "road",
                  "absoluteDirection": "SOUTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.564500119855985,
                  "lat": 25.252352425993166,
                  "elevation": ""
                ],
                [
                  "distance": 405.38700000000006,
                  "relativeDirection": "SLIGHTLY_RIGHT",
                  "streetName": "Oqba Bin Nafie Street",
                  "absoluteDirection": "SOUTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5656497,
                  "lat": 25.2501816,
                  "elevation": ""
                ],
                [
                  "distance": 216.386,
                  "relativeDirection": "LEFT",
                  "streetName": "Al Yaqoubi Street",
                  "absoluteDirection": "SOUTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5621942,
                  "lat": 25.248545,
                  "elevation": ""
                ],
                [
                  "distance": 28.821,
                  "relativeDirection": "RIGHT",
                  "streetName": "Amr Bin Othman",
                  "absoluteDirection": "WEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.562981300000004,
                  "lat": 25.246733900000002,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 722
            ]
          ],
          "tooSloped": false
        ],
        [
          "duration": 3028,
          "startTime": 1642512671000,
          "endTime": 1642515699000,
          "walkTime": 1468,
          "transitTime": 1560,
          "waitingTime": 0,
          "walkDistance": 1859.7910000000002,
          "walkLimitExceeded": false,
          "elevationLost": 0,
          "elevationGained": 0,
          "transfers": 0,
          "legs": [
            [
              "startTime": 1642512671000,
              "endTime": 1642513495000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 1049.963,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Origin",
                "lon": 51.503562927246094,
                "lat": 25.19251511519153,
                "departure": 1642512671000,
                "vertexType": "NORMAL"
              ],
              "to": [
                "name": "Barwa City Stop 4",
                "stopId": "1=559",
                "lon": 51.500112,
                "lat": 25.19809,
                "arrival": 1642513495000,
                "departure": 1642513495000,
                "stopIndex": 9,
                "vertexType": "TRANSIT"
              ],
              "legGeometry": [
                "points": "[lwxCyijyH]@`@ED?H~@tCi@Pm@cBqBz@eCfAsClAuClAcCdAoBx@f@xAVx@\\hAq@X[CtAMDKBIAUMIYg@yAFE",
                "length": 25
              ],
              "steps": [
                [
                  "distance": 155.685,
                  "relativeDirection": "DEPART",
                  "streetName": "road",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.50381230435444,
                  "lat": 25.192624941464175,
                  "elevation": ""
                ],
                [
                  "distance": 56.139,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1125",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5027223,
                  "lat": 25.1928528,
                  "elevation": ""
                ],
                [
                  "distance": 486.661,
                  "relativeDirection": "LEFT",
                  "streetName": "Street 1132",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.503220500000005,
                  "lat": 25.193080100000003,
                  "elevation": ""
                ],
                [
                  "distance": 123.042,
                  "relativeDirection": "LEFT",
                  "streetName": "Street 1127",
                  "absoluteDirection": "SOUTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5011449,
                  "lat": 25.1970333,
                  "elevation": ""
                ],
                [
                  "distance": 163.32299999999998,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1130",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.500039400000006,
                  "lat": 25.196560400000003,
                  "elevation": ""
                ],
                [
                  "distance": 65.113,
                  "relativeDirection": "SLIGHTLY_RIGHT",
                  "streetName": "Street 1138",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.4995047,
                  "lat": 25.197882,
                  "elevation": ""
                ],
                [
                  "distance": 0,
                  "relativeDirection": "RIGHT",
                  "streetName": "Barwa City Stop 4",
                  "absoluteDirection": "SOUTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.50008909255974,
                  "lat": 25.198133568381618,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 824
            ],
            [
              "startTime": 1642513495000,
              "endTime": 1642515055000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 13700.8802940405,
              "pathway": false,
              "mode": "BUS",
              "transitLeg": true,
              "route": "Mowasalat-Hamad International Airport",
              "agencyName": "Mowasalat",
              "agencyUrl": "http=//mowasalat.com",
              "agencyTimeZoneOffset": 0,
              "routeColor": "9C6A3F",
              "routeId": "1=00737",
              "routeTextColor": "FFFFFF",
              "headsign": "Karwa City Station - Hamad International Airport via Al Matar Al Qadeem",
              "agencyId": "1=1",
              "tripId": "1=18332",
              "serviceDate": "2022-01-18",
              "from": [
                "name": "Barwa City Stop 4",
                "stopId": "1=559",
                "lon": 51.500112,
                "lat": 25.19809,
                "arrival": 1642513495000,
                "departure": 1642513495000,
                "stopIndex": 9,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Al Zahar Supermarket",
                "stopId": "1=4581",
                "lon": 51.556209,
                "lat": 25.246806,
                "arrival": 1642515055000,
                "departure": 1642515055000,
                "stopIndex": 20,
                "vertexType": "TRANSIT"
              ],
              "intermediateStops": [],
              "legGeometry": [
                "points": "ioxxCoriyHyAoEwAmEi@eBM]m@iBsFuPK[kAmD??s@wBc@sAaCoHCECMGQM_@s@[BcNea@m@aBWq@iC[HCG]@eDiAoEm@qCi@mCE]Y]ACU??a@mCk@kDm@uDi@_DAICOG]SqAq@yDcCsNwHgd@Ki@CWCYFKBM?MAM?AEKIIMGMAK?C@KDIJWVQLuAXg]nH]F]@MEMAMBKFILEL?PDN@@DHJHJLPr@nAtHv@xEn@tD??hAxGZlBdCxNHX??nAzE@`@@H?NI\\?@OVONSHUFq@ZC@iDp@uBVoFLA@UBYDWH_@NSDq@BOAICICGEAACECIG[G]AFoB@gD?k@AyC[kIk@kHi@oEAEcAgG_BiJ]A_JcBwJsA_IeD_SwCwQ[kBkIug@[@uIs@]D_AqF_@uAU]@Q_@QOSOGECAy@ZMHe@ZiCnBaFtD??yAdAcClBcIdG??u@h@]ExDUNiA|@g@`@IFGDo@b@WRw@n@kG|E??ID[ElDoDpCg@ZeAr@_@Ty@b@_@ROJc@XeDrBcBdA[C|BED??_EbDuIxGq@Xa@JC@I@K?WOOa@G[@GgB??E]@[[E@KBQBE?G?GCIGEISC]a@mH[sFOgC[sCUaB??Ii@?]DG@E?G?EAECECCCCEAEOCQOaBk@oGEq@QsDAg@EkAM]BCw@AO",
                "length": 232
              ],
              "steps": [],
              "routeShortName": "737",
              "routeLongName": "Mowasalat-Hamad International Airport",
              "duration": 1560
            ],
            [
              "startTime": 1642515055000,
              "endTime": 1642515699000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 809.8280000000001,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Al Zahar Supermarket",
                "stopId": "1=4581",
                "lon": 51.556209,
                "lat": 25.246806,
                "arrival": 1642515055000,
                "departure": 1642515055000,
                "stopIndex": 20,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Destination",
                "lon": 51.56261444091796,
                "lat": 25.2468696669746,
                "arrival": 1642515699000,
                "vertexType": "NORMAL"
              ],
              "legGeometry": [
                "points": "o_byCgqtyH??Ec@Iw@BEBG?C?C?ECCAEEAEMEMKiAu@mFW_BUiArC_APIgA]C|DaCU]@u@uC]uA",
                "length": 25
              ],
              "steps": [
                [
                  "distance": 0,
                  "relativeDirection": "DEPART",
                  "streetName": "Al Zahar Supermarket",
                  "absoluteDirection": "SOUTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.556209,
                  "lat": 25.246806,
                  "elevation": ""
                ],
                [
                  "distance": 336.48100000000005,
                  "relativeDirection": "LEFT",
                  "streetName": "Oqba Bin Nafie Street",
                  "absoluteDirection": "EAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.55620928959127,
                  "lat": 25.246804475275137,
                  "elevation": ""
                ],
                [
                  "distance": 99.476,
                  "relativeDirection": "RIGHT",
                  "streetName": "Al Rawdha Street",
                  "absoluteDirection": "SOUTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5594119,
                  "lat": 25.247527100000003,
                  "elevation": ""
                ],
                [
                  "distance": 89.29,
                  "relativeDirection": "LEFT",
                  "streetName": "Umm Al Rabee Street",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.559780700000005,
                  "lat": 25.2466972,
                  "elevation": ""
                ],
                [
                  "distance": 123.733,
                  "relativeDirection": "RIGHT",
                  "streetName": "Al Mutasim",
                  "absoluteDirection": "SOUTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.560576000000005,
                  "lat": 25.247054100000003,
                  "elevation": ""
                ],
                [
                  "distance": 160.84799999999998,
                  "relativeDirection": "LEFT",
                  "streetName": "Amr Bin Othman",
                  "absoluteDirection": "EAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5612263,
                  "lat": 25.246109500000003,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 644
            ]
          ],
          "tooSloped": false
        ],
        [
          "duration": 3950,
          "startTime": 1642513267000,
          "endTime": 1642517217000,
          "walkTime": 1727,
          "transitTime": 1680,
          "waitingTime": 543,
          "walkDistance": 2234.411,
          "walkLimitExceeded": false,
          "elevationLost": 0,
          "elevationGained": 0,
          "transfers": 1,
          "legs": [
            [
              "startTime": 1642513267000,
              "endTime": 1642513495000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 281.293,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Origin",
                "lon": 51.503562927246094,
                "lat": 25.19251511519153,
                "departure": 1642513267000,
                "vertexType": "NORMAL"
              ],
              "to": [
                "name": "Street 1131",
                "stopId": "1=56006",
                "lon": 51.502455,
                "lat": 25.19191,
                "arrival": 1642513495000,
                "departure": 1642513495000,
                "stopIndex": 6,
                "vertexType": "TRANSIT"
              ],
              "legGeometry": [
                "points": "[lwxCyijyH~@a@NAFF^bAd@SbA`DBJ?LAFEPmAf@AA",
                "length": 13
              ],
              "steps": [
                [
                  "distance": 116.41999999999999,
                  "relativeDirection": "DEPART",
                  "streetName": "road",
                  "absoluteDirection": "SOUTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.50381230435444,
                  "lat": 25.192624941464175,
                  "elevation": ""
                ],
                [
                  "distance": 116.733,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1123",
                  "absoluteDirection": "SOUTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.503713700000006,
                  "lat": 25.191834800000002,
                  "elevation": ""
                ],
                [
                  "distance": 48.14,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1131",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.502647,
                  "lat": 25.1915134,
                  "elevation": ""
                ],
                [
                  "distance": 0,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1131",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": true,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.50244849236183,
                  "lat": 25.191907314734404,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 228
            ],
            [
              "startTime": 1642513495000,
              "endTime": 1642514875000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 15687.449330992957,
              "pathway": false,
              "mode": "BUS",
              "transitLeg": true,
              "route": "Free Zone Station-Circular",
              "agencyName": "Mowasalat",
              "agencyUrl": "http=//mowasalat.com",
              "agencyTimeZoneOffset": 0,
              "routeColor": "ED2427",
              "routeId": "1=02140",
              "routeTextColor": "FFFFFF",
              "headsign": "Free Zone Station - via Barwa City - Messaimer - Religious Complex",
              "agencyId": "1=1",
              "tripId": "1=31907",
              "serviceDate": "2022-01-18",
              "from": [
                "name": "Street 1131",
                "stopId": "1=56006",
                "lon": 51.502455,
                "lat": 25.19191,
                "arrival": 1642513495000,
                "departure": 1642513495000,
                "stopIndex": 6,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Free Zone Station",
                "stopId": "1=50500",
                "lon": 51.57708,
                "lat": 25.227664,
                "arrival": 1642514875000,
                "departure": 1642514875000,
                "stopIndex": 18,
                "vertexType": "TRANSIT"
              ],
              "intermediateStops": [],
              "legGeometry": [
                "points": "khwxCiajyHwB`AINxAlE?NGHKHeGfC??cNzFQAGC]@uC??Ww@EGOCKBaEfBW@ICGGaCmH??aP]e@??eEeMeQii@iFsOe@_BaB_Ho@_D[cB??yAoIi@]BeAeGGQQKOEWAmWbGwAd@mFjASHOREV@ZfBjJj@`D??xA|I@TCf@?NLNT?LGHIDINKrHcBZEd@HTANOBYEMa@o@w@qE??qAuH??qA[H@_@L]LSVOjGcB|DkAlDq@PI\\a@Bc@sBuL??yKmo@?SFq@AUKKMISAUD[^_@N]_@nIc@Fs@GWFMLET@RNTPNHP~DfV??jBbL@^ENBVjBlK\\xA??`A`EAd@K^_@`@[Bh@qDj@OFUNqG^]Fg@Ri@Lg@BYCOIKOQi@R]F?sH_@qHi@cHg@[DqAsI]Jal@sLqs@[EiX]Igi@mEqV_BeLyAkLs@iIk@mHM_C_A[Kk@sDqBcL[mACc@H[V[nAq@pIkDXAVDZh@LDN?d@O",
                "length": 163
              ],
              "steps": [],
              "routeShortName": "M140",
              "routeLongName": "Free Zone Station-Circular",
              "duration": 1380
            ],
            [
              "startTime": 1642514875000,
              "endTime": 1642515652000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 1034.873,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Free Zone Station",
                "stopId": "1=50500",
                "lon": 51.57708,
                "lat": 25.227664,
                "arrival": 1642514875000,
                "departure": 1642514875000,
                "stopIndex": 18,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Nabina Trading",
                "stopId": "1=4835",
                "lon": 51.573792,
                "lat": 25.236031,
                "arrival": 1642515652000,
                "departure": 1642516195000,
                "stopIndex": 1,
                "vertexType": "TRANSIT"
              ],
              "legGeometry": [
                "points": "[g~xCwsxyHEMgAb@_@NOs@GGQGM?cA\\QH_C|@qCrA]@d@QLIRKCGAQJQFgAf@MDUFIN?JSC]DcAh@g@Hg@LILML[@\\eBv@_DtAg@RMDQHkCjAwAl@g@[A",
                "length": 40
              ],
              "steps": [
                [
                  "distance": 43.844,
                  "relativeDirection": "DEPART",
                  "streetName": "service road",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.57715933554725,
                  "lat": 25.227696484847893,
                  "elevation": ""
                ],
                [
                  "distance": 19.413,
                  "relativeDirection": "CONTINUE",
                  "streetName": "G Ring Cycle Path",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5769796,
                  "lat": 25.228055700000002,
                  "elevation": ""
                ],
                [
                  "distance": 336.145,
                  "relativeDirection": "RIGHT",
                  "streetName": "G Ring Cycle Path",
                  "absoluteDirection": "EAST",
                  "stayOn": true,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5768994,
                  "lat": 25.2282145,
                  "elevation": ""
                ],
                [
                  "distance": 11.471,
                  "relativeDirection": "RIGHT",
                  "streetName": "F Ring Cycle Path",
                  "absoluteDirection": "NORTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5759472,
                  "lat": 25.230749000000003,
                  "elevation": ""
                ],
                [
                  "distance": 221.322,
                  "relativeDirection": "LEFT",
                  "streetName": "bike path",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.575974,
                  "lat": 25.2308492,
                  "elevation": ""
                ],
                [
                  "distance": 402.678,
                  "relativeDirection": "SLIGHTLY_LEFT",
                  "streetName": "Al Matar Street",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.575125400000005,
                  "lat": 25.232605000000003,
                  "elevation": ""
                ],
                [
                  "distance": 0,
                  "relativeDirection": "RIGHT",
                  "streetName": "Nabina Trading",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.57333179408837,
                  "lat": 25.235830701405906,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 777
            ],
            [
              "startTime": 1642516195000,
              "endTime": 1642516495000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 2040.2890758935919,
              "pathway": false,
              "mode": "BUS",
              "transitLeg": true,
              "route": "New Airport-Circular",
              "agencyName": "Mowasalat",
              "agencyUrl": "http=//mowasalat.com",
              "agencyTimeZoneOffset": 0,
              "routeColor": "F6545E",
              "routeId": "1=00757",
              "routeTextColor": "FFFFFF",
              "headsign": "Hamad International Airport - Mansoura Circular Via Al Matar Al Qadeem",
              "agencyId": "1=1",
              "tripId": "1=32177",
              "serviceDate": "2022-01-18",
              "from": [
                "name": "Nabina Trading",
                "stopId": "1=4835",
                "lon": 51.573792,
                "lat": 25.236031,
                "arrival": 1642515652000,
                "departure": 1642516195000,
                "stopIndex": 1,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Al Rawnaq Trading",
                "stopId": "1=4827",
                "lon": 51.56484,
                "lat": 25.252496,
                "arrival": 1642516495000,
                "departure": 1642516495000,
                "stopIndex": 3,
                "vertexType": "TRANSIT"
              ],
              "intermediateStops": [],
              "legGeometry": [
                "points": "w[_yCe~wyHqf@jT??su@n\\yGvC",
                "length": 5
              ],
              "steps": [],
              "routeShortName": "757",
              "routeLongName": "New Airport-Circular",
              "duration": 300
            ],
            [
              "startTime": 1642516495000,
              "endTime": 1642517217000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 918.2450000000001,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Al Rawnaq Trading",
                "stopId": "1=4827",
                "lon": 51.56484,
                "lat": 25.252496,
                "arrival": 1642516495000,
                "departure": 1642516495000,
                "stopIndex": 3,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Destination",
                "lon": 51.56261444091796,
                "lat": 25.2468696669746,
                "arrival": 1642517217000,
                "vertexType": "NORMAL"
              ],
              "legGeometry": [
                "points": "accyCggvyHZbAx@[NIzEsBd@QlAk@VKNAFDFN~@vCLEr@|Bd@|A~@tC~@xCzCcAnC]@|@[Rt@",
                "length": 21
              ],
              "steps": [
                [
                  "distance": 0,
                  "relativeDirection": "DEPART",
                  "streetName": "Al Rawnaq Trading",
                  "absoluteDirection": "SOUTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.56484,
                  "lat": 25.252496,
                  "elevation": ""
                ],
                [
                  "distance": 267.651,
                  "relativeDirection": "LEFT",
                  "streetName": "road",
                  "absoluteDirection": "SOUTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.564500119855985,
                  "lat": 25.252352425993166,
                  "elevation": ""
                ],
                [
                  "distance": 405.38700000000006,
                  "relativeDirection": "SLIGHTLY_RIGHT",
                  "streetName": "Oqba Bin Nafie Street",
                  "absoluteDirection": "SOUTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5656497,
                  "lat": 25.2501816,
                  "elevation": ""
                ],
                [
                  "distance": 216.386,
                  "relativeDirection": "LEFT",
                  "streetName": "Al Yaqoubi Street",
                  "absoluteDirection": "SOUTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5621942,
                  "lat": 25.248545,
                  "elevation": ""
                ],
                [
                  "distance": 28.821,
                  "relativeDirection": "RIGHT",
                  "streetName": "Amr Bin Othman",
                  "absoluteDirection": "WEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.562981300000004,
                  "lat": 25.246733900000002,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 722
            ]
          ],
          "tooSloped": false
        ],
        [
          "duration": 2792,
          "startTime": 1642514707000,
          "endTime": 1642517499000,
          "walkTime": 878,
          "transitTime": 1680,
          "waitingTime": 234,
          "walkDistance": 1100.1060000000002,
          "walkLimitExceeded": false,
          "elevationLost": 0,
          "elevationGained": 0,
          "transfers": 1,
          "legs": [
            [
              "startTime": 1642514707000,
              "endTime": 1642514935000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 281.293,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Origin",
                "lon": 51.503562927246094,
                "lat": 25.19251511519153,
                "departure": 1642514707000,
                "vertexType": "NORMAL"
              ],
              "to": [
                "name": "Street 1131",
                "stopId": "1=56006",
                "lon": 51.502455,
                "lat": 25.19191,
                "arrival": 1642514935000,
                "departure": 1642514935000,
                "stopIndex": 6,
                "vertexType": "TRANSIT"
              ],
              "legGeometry": [
                "points": "[lwxCyijyH~@a@NAFF^bAd@SbA`DBJ?LAFEPmAf@AA",
                "length": 13
              ],
              "steps": [
                [
                  "distance": 116.41999999999999,
                  "relativeDirection": "DEPART",
                  "streetName": "road",
                  "absoluteDirection": "SOUTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.50381230435444,
                  "lat": 25.192624941464175,
                  "elevation": ""
                ],
                [
                  "distance": 116.733,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1123",
                  "absoluteDirection": "SOUTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.503713700000006,
                  "lat": 25.191834800000002,
                  "elevation": ""
                ],
                [
                  "distance": 48.14,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1131",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.502647,
                  "lat": 25.1915134,
                  "elevation": ""
                ],
                [
                  "distance": 0,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1131",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": true,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.50244849236183,
                  "lat": 25.191907314734404,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 228
            ],
            [
              "startTime": 1642514935000,
              "endTime": 1642515175000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 1840.0572740438556,
              "pathway": false,
              "mode": "BUS",
              "transitLeg": true,
              "route": "Free Zone Station-Circular",
              "agencyName": "Mowasalat",
              "agencyUrl": "http=//mowasalat.com",
              "agencyTimeZoneOffset": 0,
              "routeColor": "ED2427",
              "routeId": "1=02140",
              "routeTextColor": "FFFFFF",
              "headsign": "Free Zone Station - via Barwa City - Messaimer - Religious Complex",
              "agencyId": "1=1",
              "tripId": "1=33697",
              "serviceDate": "2022-01-18",
              "from": [
                "name": "Street 1131",
                "stopId": "1=56006",
                "lon": 51.502455,
                "lat": 25.19191,
                "arrival": 1642514935000,
                "departure": 1642514935000,
                "stopIndex": 6,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Street 1138 East",
                "stopId": "1=56009",
                "lon": 51.507305,
                "lat": 25.20115,
                "arrival": 1642515175000,
                "departure": 1642515175000,
                "stopIndex": 10,
                "vertexType": "TRANSIT"
              ],
              "intermediateStops": [],
              "legGeometry": [
                "points": "khwxCiajyHwB`AINxAlE?NGHKHeGfC??cNzFQAGC]@uC??Ww@EGOCKBaEfBW@ICGGaCmH??aP]e@",
                "length": 25
              ],
              "steps": [],
              "routeShortName": "M140",
              "routeLongName": "Free Zone Station-Circular",
              "duration": 240
            ],
            [
              "startTime": 1642515175000,
              "endTime": 1642515181000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 8.985,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Street 1138 East",
                "stopId": "1=56009",
                "lon": 51.507305,
                "lat": 25.20115,
                "arrival": 1642515175000,
                "departure": 1642515175000,
                "stopIndex": 10,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Barwa City Stop 5",
                "stopId": "1=557",
                "lon": 51.507182,
                "lat": 25.201195,
                "arrival": 1642515181000,
                "departure": 1642515415000,
                "stopIndex": 10,
                "vertexType": "TRANSIT"
              ],
              "legGeometry": [
                "points": "ebyxCs_kyHMFFNA?",
                "length": 4
              ],
              "steps": [
                [
                  "distance": 8.985,
                  "relativeDirection": "DEPART",
                  "streetName": "Street 1138",
                  "absoluteDirection": "SOUTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.507265650968314,
                  "lat": 25.20122406509305,
                  "elevation": ""
                ],
                [
                  "distance": 0,
                  "relativeDirection": "RIGHT",
                  "streetName": "Barwa City Stop 5",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5071851586395,
                  "lat": 25.201189054624837,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 6
            ],
            [
              "startTime": 1642515415000,
              "endTime": 1642516855000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 12910.212863658384,
              "pathway": false,
              "mode": "BUS",
              "transitLeg": true,
              "route": "Mowasalat-Hamad International Airport",
              "agencyName": "Mowasalat",
              "agencyUrl": "http=//mowasalat.com",
              "agencyTimeZoneOffset": 0,
              "routeColor": "9C6A3F",
              "routeId": "1=00737",
              "routeTextColor": "FFFFFF",
              "headsign": "Karwa City Station - Hamad International Airport via Al Matar Al Qadeem",
              "agencyId": "1=1",
              "tripId": "1=18333",
              "serviceDate": "2022-01-18",
              "from": [
                "name": "Barwa City Stop 5",
                "stopId": "1=557",
                "lon": 51.507182,
                "lat": 25.201195,
                "arrival": 1642515181000,
                "departure": 1642515415000,
                "stopIndex": 10,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Al Zahar Supermarket",
                "stopId": "1=4581",
                "lon": 51.556209,
                "lat": 25.246806,
                "arrival": 1642516855000,
                "departure": 1642516855000,
                "stopIndex": 20,
                "vertexType": "TRANSIT"
              ],
              "intermediateStops": [],
              "legGeometry": [
                "points": "mbyxC[~jyHs@wBc@sAaCoHCECMGQM_@s@[BcNea@m@aBWq@iC[HCG]@eDiAoEm@qCi@mCE]Y]ACU??a@mCk@kDm@uDi@_DAICOG]SqAq@yDcCsNwHgd@Ki@CWCYFKBM?MAM?AEKIIMGMAK?C@KDIJWVQLuAXg]nH]F]@MEMAMBKFILEL?PDN@@DHJHJLPr@nAtHv@xEn@tD??hAxGZlBdCxNHX??nAzE@`@@H?NI\\?@OVONSHUFq@ZC@iDp@uBVoFLA@UBYDWH_@NSDq@BOAICICGEAACECIG[G]AFoB@gD?k@AyC[kIk@kHi@oEAEcAgG_BiJ]A_JcBwJsA_IeD_SwCwQ[kBkIug@[@uIs@]D_AqF_@uAU]@Q_@QOSOGECAy@ZMHe@ZiCnBaFtD??yAdAcClBcIdG??u@h@]ExDUNiA|@g@`@IFGDo@b@WRw@n@kG|E??ID[ElDoDpCg@ZeAr@_@Ty@b@_@ROJc@XeDrBcBdA[C|BED??_EbDuIxGq@Xa@JC@I@K?WOOa@G[@GgB??E]@[[E@KBQBE?G?GCIGEISC]a@mH[sFOgC[sCUaB??Ii@?]DG@E?G?EAECECCCCEAEOCQOaBk@oGEq@QsDAg@EkAM]BCw@AO",
                "length": 223
              ],
              "steps": [],
              "routeShortName": "737",
              "routeLongName": "Mowasalat-Hamad International Airport",
              "duration": 1440
            ],
            [
              "startTime": 1642516855000,
              "endTime": 1642517499000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 809.8280000000001,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Al Zahar Supermarket",
                "stopId": "1=4581",
                "lon": 51.556209,
                "lat": 25.246806,
                "arrival": 1642516855000,
                "departure": 1642516855000,
                "stopIndex": 20,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Destination",
                "lon": 51.56261444091796,
                "lat": 25.2468696669746,
                "arrival": 1642517499000,
                "vertexType": "NORMAL"
              ],
              "legGeometry": [
                "points": "o_byCgqtyH??Ec@Iw@BEBG?C?C?ECCAEEAEMEMKiAu@mFW_BUiArC_APIgA]C|DaCU]@u@uC]uA",
                "length": 25
              ],
              "steps": [
                [
                  "distance": 0,
                  "relativeDirection": "DEPART",
                  "streetName": "Al Zahar Supermarket",
                  "absoluteDirection": "SOUTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.556209,
                  "lat": 25.246806,
                  "elevation": ""
                ],
                [
                  "distance": 336.48100000000005,
                  "relativeDirection": "LEFT",
                  "streetName": "Oqba Bin Nafie Street",
                  "absoluteDirection": "EAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.55620928959127,
                  "lat": 25.246804475275137,
                  "elevation": ""
                ],
                [
                  "distance": 99.476,
                  "relativeDirection": "RIGHT",
                  "streetName": "Al Rawdha Street",
                  "absoluteDirection": "SOUTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5594119,
                  "lat": 25.247527100000003,
                  "elevation": ""
                ],
                [
                  "distance": 89.29,
                  "relativeDirection": "LEFT",
                  "streetName": "Umm Al Rabee Street",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.559780700000005,
                  "lat": 25.2466972,
                  "elevation": ""
                ],
                [
                  "distance": 123.733,
                  "relativeDirection": "RIGHT",
                  "streetName": "Al Mutasim",
                  "absoluteDirection": "SOUTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.560576000000005,
                  "lat": 25.247054100000003,
                  "elevation": ""
                ],
                [
                  "distance": 160.84799999999998,
                  "relativeDirection": "LEFT",
                  "streetName": "Amr Bin Othman",
                  "absoluteDirection": "EAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5612263,
                  "lat": 25.246109500000003,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 644
            ]
          ],
          "tooSloped": false
        ],
        [
          "duration": 3590,
          "startTime": 1642515427000,
          "endTime": 1642519017000,
          "walkTime": 1727,
          "transitTime": 1680,
          "waitingTime": 183,
          "walkDistance": 2234.411,
          "walkLimitExceeded": false,
          "elevationLost": 0,
          "elevationGained": 0,
          "transfers": 1,
          "legs": [
            [
              "startTime": 1642515427000,
              "endTime": 1642515655000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 281.293,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Origin",
                "lon": 51.503562927246094,
                "lat": 25.19251511519153,
                "departure": 1642515427000,
                "vertexType": "NORMAL"
              ],
              "to": [
                "name": "Street 1131",
                "stopId": "1=56006",
                "lon": 51.502455,
                "lat": 25.19191,
                "arrival": 1642515655000,
                "departure": 1642515655000,
                "stopIndex": 6,
                "vertexType": "TRANSIT"
              ],
              "legGeometry": [
                "points": "[lwxCyijyH~@a@NAFF^bAd@SbA`DBJ?LAFEPmAf@AA",
                "length": 13
              ],
              "steps": [
                [
                  "distance": 116.41999999999999,
                  "relativeDirection": "DEPART",
                  "streetName": "road",
                  "absoluteDirection": "SOUTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.50381230435444,
                  "lat": 25.192624941464175,
                  "elevation": ""
                ],
                [
                  "distance": 116.733,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1123",
                  "absoluteDirection": "SOUTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.503713700000006,
                  "lat": 25.191834800000002,
                  "elevation": ""
                ],
                [
                  "distance": 48.14,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1131",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.502647,
                  "lat": 25.1915134,
                  "elevation": ""
                ],
                [
                  "distance": 0,
                  "relativeDirection": "RIGHT",
                  "streetName": "Street 1131",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": true,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.50244849236183,
                  "lat": 25.191907314734404,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 228
            ],
            [
              "startTime": 1642515655000,
              "endTime": 1642517035000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 15687.449330992957,
              "pathway": false,
              "mode": "BUS",
              "transitLeg": true,
              "route": "Free Zone Station-Circular",
              "agencyName": "Mowasalat",
              "agencyUrl": "http=//mowasalat.com",
              "agencyTimeZoneOffset": 0,
              "routeColor": "ED2427",
              "routeId": "1=02140",
              "routeTextColor": "FFFFFF",
              "headsign": "Free Zone Station - via Barwa City - Messaimer - Religious Complex",
              "agencyId": "1=1",
              "tripId": "1=33698",
              "serviceDate": "2022-01-18",
              "from": [
                "name": "Street 1131",
                "stopId": "1=56006",
                "lon": 51.502455,
                "lat": 25.19191,
                "arrival": 1642515655000,
                "departure": 1642515655000,
                "stopIndex": 6,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Free Zone Station",
                "stopId": "1=50500",
                "lon": 51.57708,
                "lat": 25.227664,
                "arrival": 1642517035000,
                "departure": 1642517035000,
                "stopIndex": 18,
                "vertexType": "TRANSIT"
              ],
              "intermediateStops": [],
              "legGeometry": [
                "points": "khwxCiajyHwB`AINxAlE?NGHKHeGfC??cNzFQAGC]@uC??Ww@EGOCKBaEfBW@ICGGaCmH??aP]e@??eEeMeQii@iFsOe@_BaB_Ho@_D[cB??yAoIi@]BeAeGGQQKOEWAmWbGwAd@mFjASHOREV@ZfBjJj@`D??xA|I@TCf@?NLNT?LGHIDINKrHcBZEd@HTANOBYEMa@o@w@qE??qAuH??qA[H@_@L]LSVOjGcB|DkAlDq@PI\\a@Bc@sBuL??yKmo@?SFq@AUKKMISAUD[^_@N]_@nIc@Fs@GWFMLET@RNTPNHP~DfV??jBbL@^ENBVjBlK\\xA??`A`EAd@K^_@`@[Bh@qDj@OFUNqG^]Fg@Ri@Lg@BYCOIKOQi@R]F?sH_@qHi@cHg@[DqAsI]Jal@sLqs@[EiX]Igi@mEqV_BeLyAkLs@iIk@mHM_C_A[Kk@sDqBcL[mACc@H[V[nAq@pIkDXAVDZh@LDN?d@O",
                "length": 163
              ],
              "steps": [],
              "routeShortName": "M140",
              "routeLongName": "Free Zone Station-Circular",
              "duration": 1380
            ],
            [
              "startTime": 1642517035000,
              "endTime": 1642517812000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 1034.873,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Free Zone Station",
                "stopId": "1=50500",
                "lon": 51.57708,
                "lat": 25.227664,
                "arrival": 1642517035000,
                "departure": 1642517035000,
                "stopIndex": 18,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Nabina Trading",
                "stopId": "1=4835",
                "lon": 51.573792,
                "lat": 25.236031,
                "arrival": 1642517812000,
                "departure": 1642517995000,
                "stopIndex": 1,
                "vertexType": "TRANSIT"
              ],
              "legGeometry": [
                "points": "[g~xCwsxyHEMgAb@_@NOs@GGQGM?cA\\QH_C|@qCrA]@d@QLIRKCGAQJQFgAf@MDUFIN?JSC]DcAh@g@Hg@LILML[@\\eBv@_DtAg@RMDQHkCjAwAl@g@[A",
                "length": 40
              ],
              "steps": [
                [
                  "distance": 43.844,
                  "relativeDirection": "DEPART",
                  "streetName": "service road",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.57715933554725,
                  "lat": 25.227696484847893,
                  "elevation": ""
                ],
                [
                  "distance": 19.413,
                  "relativeDirection": "CONTINUE",
                  "streetName": "G Ring Cycle Path",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5769796,
                  "lat": 25.228055700000002,
                  "elevation": ""
                ],
                [
                  "distance": 336.145,
                  "relativeDirection": "RIGHT",
                  "streetName": "G Ring Cycle Path",
                  "absoluteDirection": "EAST",
                  "stayOn": true,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5768994,
                  "lat": 25.2282145,
                  "elevation": ""
                ],
                [
                  "distance": 11.471,
                  "relativeDirection": "RIGHT",
                  "streetName": "F Ring Cycle Path",
                  "absoluteDirection": "NORTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5759472,
                  "lat": 25.230749000000003,
                  "elevation": ""
                ],
                [
                  "distance": 221.322,
                  "relativeDirection": "LEFT",
                  "streetName": "bike path",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.575974,
                  "lat": 25.2308492,
                  "elevation": ""
                ],
                [
                  "distance": 402.678,
                  "relativeDirection": "SLIGHTLY_LEFT",
                  "streetName": "Al Matar Street",
                  "absoluteDirection": "NORTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.575125400000005,
                  "lat": 25.232605000000003,
                  "elevation": ""
                ],
                [
                  "distance": 0,
                  "relativeDirection": "RIGHT",
                  "streetName": "Nabina Trading",
                  "absoluteDirection": "NORTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.57333179408837,
                  "lat": 25.235830701405906,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 777
            ],
            [
              "startTime": 1642517995000,
              "endTime": 1642518295000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 2040.2890758935919,
              "pathway": false,
              "mode": "BUS",
              "transitLeg": true,
              "route": "New Airport-Circular",
              "agencyName": "Mowasalat",
              "agencyUrl": "http=//mowasalat.com",
              "agencyTimeZoneOffset": 0,
              "routeColor": "F6545E",
              "routeId": "1=00757",
              "routeTextColor": "FFFFFF",
              "headsign": "Hamad International Airport - Mansoura Circular Via Al Matar Al Qadeem",
              "agencyId": "1=1",
              "tripId": "1=32178",
              "serviceDate": "2022-01-18",
              "from": [
                "name": "Nabina Trading",
                "stopId": "1=4835",
                "lon": 51.573792,
                "lat": 25.236031,
                "arrival": 1642517812000,
                "departure": 1642517995000,
                "stopIndex": 1,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Al Rawnaq Trading",
                "stopId": "1=4827",
                "lon": 51.56484,
                "lat": 25.252496,
                "arrival": 1642518295000,
                "departure": 1642518295000,
                "stopIndex": 3,
                "vertexType": "TRANSIT"
              ],
              "intermediateStops": [],
              "legGeometry": [
                "points": "w[_yCe~wyHqf@jT??su@n\\yGvC",
                "length": 5
              ],
              "steps": [],
              "routeShortName": "757",
              "routeLongName": "New Airport-Circular",
              "duration": 300
            ],
            [
              "startTime": 1642518295000,
              "endTime": 1642519017000,
              "departureDelay": 0,
              "arrivalDelay": 0,
              "realTime": false,
              "distance": 918.2450000000001,
              "pathway": false,
              "mode": "WALK",
              "transitLeg": false,
              "route": "",
              "agencyTimeZoneOffset": 10800000,
              "interlineWithPreviousLeg": false,
              "from": [
                "name": "Al Rawnaq Trading",
                "stopId": "1=4827",
                "lon": 51.56484,
                "lat": 25.252496,
                "arrival": 1642518295000,
                "departure": 1642518295000,
                "stopIndex": 3,
                "vertexType": "TRANSIT"
              ],
              "to": [
                "name": "Destination",
                "lon": 51.56261444091796,
                "lat": 25.2468696669746,
                "arrival": 1642519017000,
                "vertexType": "NORMAL"
              ],
              "legGeometry": [
                "points": "accyCggvyHZbAx@[NIzEsBd@QlAk@VKNAFDFN~@vCLEr@|Bd@|A~@tC~@xCzCcAnC]@|@[Rt@",
                "length": 21
              ],
              "steps": [
                [
                  "distance": 0,
                  "relativeDirection": "DEPART",
                  "streetName": "Al Rawnaq Trading",
                  "absoluteDirection": "SOUTHWEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.56484,
                  "lat": 25.252496,
                  "elevation": ""
                ],
                [
                  "distance": 267.651,
                  "relativeDirection": "LEFT",
                  "streetName": "road",
                  "absoluteDirection": "SOUTHEAST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": true,
                  "lon": 51.564500119855985,
                  "lat": 25.252352425993166,
                  "elevation": ""
                ],
                [
                  "distance": 405.38700000000006,
                  "relativeDirection": "SLIGHTLY_RIGHT",
                  "streetName": "Oqba Bin Nafie Street",
                  "absoluteDirection": "SOUTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5656497,
                  "lat": 25.2501816,
                  "elevation": ""
                ],
                [
                  "distance": 216.386,
                  "relativeDirection": "LEFT",
                  "streetName": "Al Yaqoubi Street",
                  "absoluteDirection": "SOUTH",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.5621942,
                  "lat": 25.248545,
                  "elevation": ""
                ],
                [
                  "distance": 28.821,
                  "relativeDirection": "RIGHT",
                  "streetName": "Amr Bin Othman",
                  "absoluteDirection": "WEST",
                  "stayOn": false,
                  "area": false,
                  "bogusName": false,
                  "lon": 51.562981300000004,
                  "lat": 25.246733900000002,
                  "elevation": ""
                ]
              ],
              "rentedBike": false,
              "duration": 722
            ]
          ],
          "tooSloped": false
        ]
      ]
    ],
    "metadata": [
      "searchWindowUsed": 4200,
      "nextDateTime": 1642515741000,
      "prevDateTime": 1642507341000
    ],
    "debugOutput": [
      "precalculationTime": 0,
      "directStreetRouterTime": 0,
      "transitRouterTime": 31,
      "filteringTime": 0,
      "renderingTime": 0,
      "totalTime": 31,
      "transitRouterTimes": [
        "tripPatternFilterTime": 15,
        "accessEgressTime": 0,
        "raptorSearchTime": 16,
        "itineraryCreationTime": 0
      ]
    ],
    "elevationMetadata": [
      "ellipsoidToGeoidDifference": -11.835138090815272,
      "geoidElevation": false
    ]
  ]
 
