//
//  Motor.swift
//  MissionControl
//
//  Created by Daniel Honies on 30.11.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import Foundation
import Foundation
import JSONJoy
class MotorServo: Sensor {
    var MaxBound:NSNumber
    var MinBound:NSNumber
    var ControlType:String
    var SliderName: String
    var ButtonName: String
    required init(_ json:JSONDecoder) {
        if let value = json["ControlType"].string {
            ControlType = value
        } else {
            ControlType = ""
        }
        if let value = json["MaxBound"].number {
            MaxBound = value
        } else {
            MaxBound = 0
        }
        if let value = json["MinBound"].number {
            MinBound = value
        } else {
            MinBound = 0
        }
        ButtonName = ""
        SliderName = ""
        super.init(json)
    }
    override init() {
        ControlType = ""
        MaxBound = 0
        MinBound = 0
        ButtonName = ""
        SliderName = ""
        super.init();
    }
}