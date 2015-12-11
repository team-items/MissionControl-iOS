
//
//  AnalogS.swift
//  MissionControl
//
//  Created by Daniel Honies on 30.11.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import Foundation
import JSONJoy

class AnalogS : JSONJoy {
    var MaxBound:NSNumber
    var Graph:NSNumber
    var DataType:String
    var MinBound:NSNumber
    var Name:String
    var oldValues = [Double]()
    var enabled = true
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
        if let value = json["DataType"].string {
            DataType = value
        } else {
            DataType = ""
        }
        if let value = json["MinBound"].number {
            MinBound = value
        } else {
            MinBound = 0
        }
        Name = "";
    }
    init() {
        
            MaxBound = 0
            Graph = 40
            DataType = ""
            MinBound = 0
        Name = "";
    }
    
}