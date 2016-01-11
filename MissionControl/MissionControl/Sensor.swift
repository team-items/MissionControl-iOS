//
//  Sensor.swift
//  MissionControl
//
//  Created by Daniel Honies on 11.01.16.
//  Copyright © 2016 Daniel Honies. All rights reserved.
//

import Foundation
import JSONJoy

class Sensor : JSONJoy {
    var DataType:String
    var Name:String
    var enabled = true
    required init(_ json:JSONDecoder) {
        
        if let value = json["DataType"].string {
            DataType = value
        } else {
            DataType = ""
        }
        Name = "";
    }
    init() {
        DataType = "";
        Name = "";
    }
    
}
