//
//  ConnectViewController.swift
//  MissionControl
//
//  Created by Daniel Honies on 06.10.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import JSONJoy
class ConnectViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {

    @IBOutlet weak var connect: UIBarButtonItem!
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var hostIpField: UITextField!
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var client:TCPClient = TCPClient(addr: "items.ninja", port: 62626)
    let connREQ = "{\"ConnREQ\" : {\"HardwareType\" : \"Smartphone\",\"PreferredCrypto\" : \"None\",\"SupportedDT\" : [\"Bool\", \"String\", \"Integer\", \"Slider\", \"Button\"]}}"
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    let segmentSize = 2048
    var conLAO: JSON = JSON("{}");
    override func viewDidLoad() {
        super.viewDidLoad()
        hostIpField.delegate = self
        hostIpField.autocorrectionType = UITextAutocorrectionType.No
        navigationController!.navigationBar.barTintColor = UIColor(netHex:0xf43254)
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem!.tintColor = UIColor.whiteColor()
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        var error:NSError?
        var input: AnyObject! = try AVCaptureDeviceInput()
        do{
            input = try AVCaptureDeviceInput(device: captureDevice)
        }
        catch {
            
        }
        if (error != nil) {
            // If any error occurs, simply log the description of it and don't continue any more.
            print("\(error?.localizedDescription)")
            return
        }
        
        // Initialize the captureSession object.
        captureSession = AVCaptureSession()
        // Set the input device on the capture session.
        captureSession?.addInput(input as! AVCaptureInput) //emulator
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = supportedBarCodes
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = videoView.layer.bounds
        videoView.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession?.startRunning()
        
        // Move the message label to the top view
        view.bringSubviewToFront(messageLabel)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // Here we use filter method to check if the type of metadataObj is supported
        // Instead of hardcoding the AVMetadataObjectTypeQRCode, we check if the type
        // can be found in the array of supported bar codes.
        if supportedBarCodes.filter({ $0 == metadataObj.type }).count > 0 {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                
                launchApp(metadataObj.stringValue)
            }
        }
    }
    
    func launchApp(decodedURL: String) {
        let alertPrompt = UIAlertController(title: "Connect to Robot", message: "You're going to connect to \(decodedURL)", preferredStyle: .ActionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            self.connect(decodedURL)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        self.presentViewController(alertPrompt, animated: true, completion: nil)
        
    }
    
    func connect(url: String)->Bool{
        
        print("Trying to connect")
        client = TCPClient(addr: url, port: 62626)
        let (_, errorMsg) = client.connect(timeout: 10)
        if(errorMsg == "connect success"){
            client.send(str: connREQ)
            var data = client.read(segmentSize)
            var jsonString = NSString(bytes: data!, length: data!.count, encoding: NSUTF8StringEncoding)!
            print(jsonString)
                        var response = JSON(data: jsonString.dataUsingEncoding(NSUTF8StringEncoding)!)
            print(response)
            if let _ = response["ConnACK"].dictionary {
                
                data = client.read(segmentSize)
                var jsonString = NSString(bytes: data!, length: data!.count, encoding: NSUTF8StringEncoding)!
                
                print(jsonString)
                data = client.read(segmentSize)
                jsonString = jsonString.stringByAppendingString( NSString(bytes: data!, length: data!.count, encoding: NSUTF8StringEncoding)! as String)
                
                print(jsonString)
                data = client.read(segmentSize)
                jsonString = jsonString.stringByAppendingString( NSString(bytes: data!, length: data!.count, encoding: NSUTF8StringEncoding)! as String)
                
                print(jsonString)
                let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                conLAO = JSON(data : dataFromString!)
                client.send(str:  "{ \"ConnSTT\" : \"\" }")
                performSegueWithIdentifier("connect", sender: self)
                
            }
            return true;
        }
        return false;
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "connect" {
            let senContr = segue.destinationViewController as! TabViewController
            let controller = senContr.viewControllers![0] as! UINavigationController
            let destination = controller.visibleViewController as! SensorTableViewController
            var sensors: [Sensor] = [];
            var motors: [MotorServo] = [];
            //do conlao here
            for (sensorname,sensor)  in conLAO["ConnLAO"]["Information"]["Integer"].dictionaryValue{
                
                var asensor:AnalogS = AnalogS(JSONDecoder(sensor.stringValue))
                asensor.Name = sensorname
                sensors.append(asensor)
                
            }
            for (sensorname,sensor)  in conLAO["ConnLAO"]["Information"]["Bool"].dictionaryValue{
                var dsensor:DigitalS = DigitalS(JSONDecoder(sensor.stringValue))
                dsensor.Name = sensorname
                sensors.append(dsensor)
                
            }
            var motorS = MotorServo();
            var slname = ""
            var buttonname = ""
            for (motorname, motor)  in conLAO["ConnLAO"]["Controller"].dictionaryValue{
                for (slidername, slider)  in motor.dictionaryValue{
                    if (slider["ControlType"] == "Slider"){
                        print(slider.stringValue)
                        motorS = MotorServo(JSONDecoder(slider.stringValue))
                        motorS.Name = motorname
                        motorS.MinBound = slider["MinBound"].numberValue
                        motorS.MaxBound = slider["MaxBound"].numberValue
                        slname = slidername
                    }else if (slider["ControlType"] == "Button"){
                        buttonname = slidername
                        
                    }
                }
                
                motorS.SliderName = slname
                motorS.ButtonName = buttonname
                motors.append(motorS)
            }
            
            destination.enabledSensors = sensors
            destination.sensors = sensors
            destination.enabledMotorServos = motors;
            destination.motors = motors
            destination.client = client
        }
        
    }
    
    @IBAction func connectClicked(sender: UIBarButtonItem) {
        connect(hostIpField.text!)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        if let _ = hostIpField.text {
            if hostIpField.text!.characters.count > 0 {
            connect.enabled = true
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
}
