
//
//  AnalogS.swift
//  MissionControl
//
//  Created by Daniel Honies on 30.11.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import Foundation
import JSONJoy

class AnalogS : Sensor {
    var MaxBound:NSNumber
    var Graph:NSNumber
    
    var MinBound:NSNumber
    
    var oldValues = [1.0]
    
    required init(_ json:JSONDecoder) {
        
        if let value = json["MaxBound"].number {
            MaxBound = value
        } else {
            MaxBound = 0
        }
        if let value = json["Graph"].number {
            Graph = value
        } else {
            Graph = 40
        }
        if let value = json["MinBound"].number {
            MinBound = value
        } else {
            MinBound = 0
        }
        super.init(json)
    }
    override init() {
        
            MaxBound = 0
            Graph = 40
            MinBound = 0
        super.init();
    }
    
}