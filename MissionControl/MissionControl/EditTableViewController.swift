//
//  EditTableViewController.swift
//  MissionControl
//
//  Created by Daniel Honies on 06.10.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import UIKit

class EditTableViewController: UITableViewController {
    var senmots = [true,true,true]
    var sensors: [Sensor] = []
    var enabledSensors: [Sensor] = []
    var delegate = UITableViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        self.navigationItem.rightBarButtonItem!.tintColor = UIColor.whiteColor()
        navigationController!.navigationBar.barTintColor = UIColor(netHex:0xf43254)
       
        UINavigationBar.appearance().titleTextAttributes = [ "TextColor": UIColor.whiteColor() ]
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        //Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
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

    @IBAction func save(sender: AnyObject) {
        if let delegat = delegate as? SensorTableViewController{
            delegat.enabledSensors = self.enabledSensors
            delegat.sensors = self.sensors
            delegat.tableView.reloadData()
        }else if let deleg = delegate as? MotorTableViewController{
            deleg.enabledMotorServos = self.enabledSensors as! [MotorServo]
            deleg.motorServos = self.sensors as! [MotorServo]
            deleg.tableView.reloadData()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sensors.count
    }

    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("senmot", forIndexPath: indexPath) as! EditTableViewCell
        cell.nameLabel.text = sensors[indexPath.row].Name
        if sensors[indexPath.row].enabled{
            cell.switcher.setOn(true, animated: false)
        }else{
            cell.switcher.setOn(false, animated: false)
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("senmot", forIndexPath: indexPath) as! EditTableViewCell
        
        var i = 0;
        var found = false;
        for (var ind = 0; ind < enabledSensors.count; ind++){
            print(enabledSensors[ind].Name)
            print(cell.sensor.Name)
            if sensors[indexPath.row].Name == enabledSensors[ind].Name{
                i = ind
                found = true
                enabledSensors[ind].enabled = false
                print("sensorfound")
                enabledSensors.removeAtIndex(i)
            }
        }
        if !found{
            sensors[indexPath.row].enabled = true
            enabledSensors.append(sensors[indexPath.row])
        }
        for sensor in sensors{
            print(sensor.Name)
        }
        print("\n")
        for sensor in enabledSensors{
            print(sensor.Name)
        }
        if sensors[indexPath.row].enabled{
            cell.switcher.setOn(true, animated: true)
        }else{
            cell.switcher.setOn(false, animated: true)
        }
        tableView.reloadData()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
