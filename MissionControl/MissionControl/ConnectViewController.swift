//
//  ConnectViewController.swift
//  MissionControl
//
//  Created by Daniel Honies on 06.10.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import UIKit
import AVFoundation
class ConnectViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        captureSession?.addInput(input as! AVCaptureInput)
        
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
            
            if let url = NSURL(string: decodedURL) {
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        self.presentViewController(alertPrompt, animated: true, completion: nil)
        
    }
    


}
