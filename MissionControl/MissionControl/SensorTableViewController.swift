//
//  SensorTableViewController.swift
//  MissionControl
//
//  Created by Daniel Honies on 04.10.15.
//  Copyright © 2015 F-WuTS. All rights reserved.
//

import UIKit
import SwiftyJSON
class SensorTableViewController: UITableViewController, UITabBarControllerDelegate, DisconnectableProtocol {
    var sensorsexpanded = [Bool]()
    var cells = [UITableViewCell]()
    var enabledSensors: [Sensor] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    var sensors: [Sensor] = []
    var manager:NetworkManager?
    var timer = Timer();
    var enabledMotorServos: [MotorServo] = []
    var motors: [MotorServo] = []
    
    let tableCellHeightExpanded:CGFloat = 209
    let tableCellHeightCollapsed:CGFloat = 45
    let refreshRate = 0.05
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController!.delegate = self
        
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem!.tintColor = UIColor.white
        navigationController!.navigationBar.barTintColor = UIColor(netHex:0xf43254)
        tabBarController!.tabBar.tintColor = UIColor(netHex: 0xf43254)
        UINavigationBar.appearance().titleTextAttributes = [ "TextColor": UIColor.white ]
        
        navigationController!.navigationBar.barStyle = UIBarStyle.black
        
        timer = Timer.scheduledTimer(timeInterval: refreshRate, target: self, selector: #selector(SensorTableViewController.updateSensors), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        manager!.view = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return enabledSensors.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell();
        if let asensor = enabledSensors[indexPath.row] as? AnalogS {
         let cell1 = tableView.dequeueReusableCell(withIdentifier: "sensorcell", for: indexPath) as! SensorTableViewCell
        
        cell1.configWithSensor(asensor)
            cell = cell1
        }else if let dsensor = enabledSensors[indexPath.row] as? DigitalS {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "dsensorcell", for: indexPath) as! DigitalSensorTableViewCell
            
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sensorcell", for: indexPath) as! SensorTableViewCell
        
        if !sensorsexpanded[indexPath.row]{
            cell.graph.alpha = 1
        }
        else{
           cell.graph.alpha = 0
        }
        
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        print(cell.ispaused)
        if cell.ispaused{
        cell.pauseButton.setTitle("Resume", for: UIControlState())
        }
        sensorsexpanded[indexPath.row] = !sensorsexpanded[indexPath.row]
        
        tableView.beginUpdates()
        tableView.endUpdates()

    }
    
    func updateSensors(){
        let dataFromString = manager!.latest.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        var dat = JSON(data : dataFromString!)
        for (sensorname, value) in dat["Data"].dictionaryValue{
            for ind in 0 ..< enabledSensors.count{
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
        print("updated")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    
    
    @IBAction func disconnect(_ sender: UIBarButtonItem) {
        timer.invalidate()
        manager!.disconnect()
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let destination = segue.destination as! UINavigationController
            let controller = destination.visibleViewController as! EditTableViewController
            controller.sensors = self.sensors
            controller.enabledSensors = self.enabledSensors
            controller.delegate = self
        }
        
    }
   
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
      
        let dest = viewController as! UINavigationController
        if let destination = dest.viewControllers[0] as? MotorTableViewController{
            destination.enabledMotorServos = enabledMotorServos
            destination.motorServos = motors
            destination.manager = manager!
        }
        return true
    }
    
    func shouldCloseCauseServerCrash(){
        timer.invalidate()
        dismiss(animated: true, completion: nil)
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
