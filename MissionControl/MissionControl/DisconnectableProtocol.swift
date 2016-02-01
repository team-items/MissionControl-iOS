//
//  DataViewController.swift
//  MissionControl
//
//  Created by Daniel Maximilian Swoboda on 01.02.16.
//  Copyright © 2016 F-WuTS. All rights reserved.
//

public protocol DisconnectableProtocol: class {
    func shouldCloseCauseServerCrash()
}