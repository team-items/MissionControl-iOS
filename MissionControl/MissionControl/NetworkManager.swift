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
    let queue = OperationQueue()
    
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
    func setServer(_ addr:String, port:Int){
        sock = TCPClient(addr: addr, port: port)
    }
    
    //Connects to server and handles handshake
    func connect(_ caller:ConnectViewController){
        queue.addOperation() {
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
                    self.connLAO = (self.connLAO as String).appending( (self.receiveString() as String)) as NSString
                    print(self.connLAO)
                    do {
                        //try to serialize json, will succeed if valid json
                        try JSONSerialization.jsonObject(with: self.connLAO.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!, options: []) as! [String: AnyObject]
                        parseable = true
                    } catch _ {
                        print("inparseable")
                    }
                }
                
                //Send ConnSTT
                self.sendString(self.connSTT)
                OperationQueue.main.addOperation() {
                    caller.performConnectedAction(true)
                }
            }
            OperationQueue.main.addOperation() {
                caller.performConnectedAction(false)
            }
        }
    }
    
    //wrapper for the socket send function
    func sendString(_ msg:String){
        sock!.send(str: msg)
    }
    
    //wrapper for the socket receive function with included stringification
    func receiveString()->NSString{
        var data:[UInt8]?
        if(!aborted){
                data = sock!.read(segmentSize)
            
                if let val = data{
                return NSString(bytes: data!, length: data!.count, encoding: String.Encoding.utf8.rawValue)!
                }
                else{
                    sock!.close()
                    view!.shouldCloseCauseServerCrash()
                    return ""
                }
            }
        
        return ""
    }
    
    //Asynchronous sends an message to the server
    func sendAsync(_ msg:String){
        queue.addOperation() {
            self.sendString(msg)
        }
    }
    
    //kicks off an async updating loop
    func updateAsync(){
        queue.addOperation() {
            while(!self.aborted){
                self.latest = self.receiveString()
                OperationQueue.main.addOperation() {
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
