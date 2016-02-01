//
//  NetworkManager.swift
//  MissionControl
//  Asynchronous Networking Manager for MissionControl iOS
//
//  Created by Daniel Maximilian Swoboda on 24.01.16.
//  Copyright © 2016 F-WuTS. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class NetworkManager {
    //lets
    let queue = NSOperationQueue()
    
    let connectTimeout = 2
    let segmentSize = 2048
    
    let connREQ = "{\"ConnREQ\" : {\"HardwareType\" : \"Smartphone\",\"PreferredCrypto\" : \"None\",\"SupportedDT\" : [\"Bool\", \"String\", \"Integer\", \"Slider\", \"Button\"]}}"
    let connSTT = "{ \"ConnSTT\" : {} }"
    
    //vars
    var sock:TCPClient? = nil
    
    var connACK:NSString = ""
    var connLAO:NSString = ""
    var latest:NSString = ""
    var aborted:Bool = false
    var view:DisconnectableProtocol? = nil
    
    //Sets the ip and port of the server it will connect to
    func setServer(addr:String, port:Int){
        sock = TCPClient(addr: addr, port: port)
    }
    
    //Connects to server and handles handshake
    func connect(caller:ConnectViewController){
        queue.addOperationWithBlock() {
            let (_, errorMsg) = self.sock!.connect(timeout: self.connectTimeout)
            if(errorMsg == "connect success"){
                //Send connREQ Message
                self.sendString(self.connREQ)
                
                //Receive Answer (ConnACK or ConnREJ) from Server
                self.connACK = self.receiveString()
                
                //receives parts of connlao until it is parseable
                var parseable = false
                while (!parseable){
                    usleep(10000)
                    print("connLAO")
                    self.connLAO = (self.connLAO as String) + (self.receiveString() as String)
                    print(self.connLAO)
                    do {
                        //try to serialize json, will succeed if valid json
                        try NSJSONSerialization.JSONObjectWithData(self.connLAO.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, options: []) as! [String: AnyObject]
                        parseable = true
                    } catch _ {
                        print("inparseable")
                    }
                }
                
                //Send ConnSTT
                self.sendString(self.connSTT)
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    caller.performConnectedAction(true)
                }
            }
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                caller.performConnectedAction(false)
            }
        }
    }
    
    //wrapper for the socket send function
    func sendString(msg:String){
        sock!.send(str: msg)
    }
    
    //wrapper for the socket receive function with included stringification
    func receiveString()->NSString{
        var data:[UInt8]?
        if(!aborted){
            data = sock!.read(segmentSize)
            if(data == nil){
                sock!.close()
                view!.shouldCloseCauseServerCrash()
                return ""
            } else {
                return NSString(bytes: data!, length: data!.count, encoding: NSUTF8StringEncoding)!
            }
        }
        return ""
    }
    
    //Asynchronous sends an message to the server
    func sendAsync(msg:String){
        queue.addOperationWithBlock() {
            self.sendString(msg)
        }
    }
    
    //kicks off an async updating loop
    func updateAsync(){
        queue.addOperationWithBlock() {
            while(!self.aborted){
                self.latest = self.receiveString()
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    //add operation to main queue
                }
            }
            self.sock!.close()
        }
    }
    
    func disconnect(){
        aborted = true
        queue.cancelAllOperations()
    }
}