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
    
    //Sets the ip and port of the server it will connect to
    func setServer(addr:String, port:Int){
        sock = TCPClient(addr: addr, port: port)
    }
    
    //Connects to server and handles handshake
    func connect() -> Bool{
        
        let (_, errorMsg) = sock!.connect(timeout: connectTimeout)
        if(errorMsg == "connect success"){
            //Send connREQ Message
            sendString(connREQ)
            
            //Receive Answer (ConnACK or ConnREJ) from Server
            connACK = receiveString()

            //receives parts of connlao until it is parseable
            var parseable = false
            while (!parseable){
                connLAO = (connLAO as String) + (receiveString() as String)
                do {
                    //try to serialize json, will succeed if valid json
                    try NSJSONSerialization.JSONObjectWithData(self.connLAO.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, options: []) as! [String: AnyObject]
                    parseable = true
                } catch _ {
                    print("inparseable")
                }
            }
            
            //Send ConnSTT
            sendString(connSTT)
            
            return true
        }
        
        return false
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
                //in this case server crashed, change view controller then
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
                    // when done, update your UI and/or model on the main queue
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