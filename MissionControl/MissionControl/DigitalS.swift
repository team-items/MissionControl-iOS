//
//  DigitalS.swift
//  MissionControl
//
//  Created by Daniel Honies on 30.11.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import Foundation
import JSONJoy
class DigitalS: Sensor {
    var oldValues = [0]
    var Graph:NSNumber
    required init(_ json:JSONDecoder) {
        if let value = json["Graph"].number {
            Graph = value
        } else {
            Graph = 40
        }
        super.init(json)
    }
}