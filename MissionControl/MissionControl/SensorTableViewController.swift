//
//  SensorTableViewController.swift
//  MissionControl
//
//  Created by Daniel Honies on 04.10.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import UIKit
import SwiftyJSON
class SensorTableViewController: UITableViewController, UITabBarControllerDelegate {
    var sensorsexpanded = [Bool]()
    var cells = [UITableViewCell]()
    var enabledSensors: [Sensor] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    var sensors: [Sensor] = []
    var manager:NetworkManager?
    var timer = NSTimer();
    var enabledMotorServos: [MotorServo] = []
    var motors: [MotorServo] = []
    
    let tableCellHeightExpanded:CGFloat = 209
    let tableCellHeightCollapsed:CGFloat = 45
    let refreshRate = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController!.delegate = self
        
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem!.tintColor = UIColor.whiteColor()
        navigationController!.navigationBar.barTintColor = UIColor(netHex:0xf43254)
        tabBarController!.tabBar.tintColor = UIColor(netHex: 0xf43254)
        UINavigationBar.appearance().titleTextAttributes = [ "TextColor": UIColor.whiteColor() ]
        
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        
        timer = NSTimer.scheduledTimerWithTimeInterval(refreshRate, target: self, selector: "updateSensors", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return enabledSensors.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell();
        if let asensor = enabledSensors[indexPath.row] as? AnalogS {
         let cell1 = tableView.dequeueReusableCellWithIdentifier("sensorcell", forIndexPath: indexPath) as! SensorTableViewCell
        
        cell1.configWithSensor(asensor)
            cell = cell1
        }else if let dsensor = enabledSensors[indexPath.row] as? DigitalS {
            let cell2 = tableView.dequeueReusableCellWithIdentifier("dsensorcell", forIndexPath: indexPath) as! DigitalSensorTableViewCell
            
            cell2.configWithSensor(dsensor)
            cell = cell2
        }
        if cells.count > indexPath.row{
            cells[indexPath.row] = cell
        }
        else{
            cells.append(cell)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("sensorcell", forIndexPath: indexPath) as! SensorTableViewCell
        
        if !sensorsexpanded[indexPath.row]{
            cell.graph.alpha = 1
        }
        else{
           cell.graph.alpha = 0
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        print(cell.ispaused)
        if cell.ispaused{
        cell.pauseButton.setTitle("Resume", forState: UIControlState.Normal)
        }
        sensorsexpanded[indexPath.row] = !sensorsexpanded[indexPath.row]
        
        tableView.beginUpdates()
        tableView.endUpdates()

    }
    
    func updateSensors(){
        let dataFromString = manager!.latest.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var dat = JSON(data : dataFromString!)
        for (sensorname, value) in dat["Data"].dictionaryValue{
            for (var ind = 0; ind < enabledSensors.count; ind++){
                if sensorname == enabledSensors[ind].Name{
                    if ind < cells.count{
                        if let asensor = enabledSensors[ind] as? AnalogS {
                            asensor.oldValues.append(value.doubleValue)
                            if let cell = cells[ind] as? SensorTableViewCell{
                            cell.update(value)
                            }
                        }
                        if let dsensor = enabledSensors[ind] as? DigitalS {
                            
                            if(value.boolValue){
                                dsensor.oldValues.append(1)
                            }else{
                                dsensor.oldValues.append(0)
                            }
                            if let cell = cells[ind] as? DigitalSensorTableViewCell{
                                cell.update(value)
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if sensorsexpanded.count <= indexPath.row{
            sensorsexpanded.append(false)
        }
        if sensorsexpanded[indexPath.row]{
            return tableCellHeightExpanded
        }
        else{
            return tableCellHeightCollapsed
        }
    }
    
    
    
    @IBAction func disconnect(sender: UIBarButtonItem) {
        timer.invalidate()
        manager!.disconnect()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "edit" {
            let destination = segue.destinationViewController as! UINavigationController
            let controller = destination.visibleViewController as! EditTableViewController
            controller.sensors = self.sensors
            controller.enabledSensors = self.enabledSensors
            controller.delegate = self
        }
        
    }
   
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
      
        let dest = viewController as! UINavigationController
        if let destination = dest.viewControllers[0] as? MotorTableViewController{
            destination.enabledMotorServos = enabledMotorServos
            destination.motorServos = motors
            destination.manager = manager!
        }
        return true
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    
    return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            sensorsexpanded.removeFirst()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
