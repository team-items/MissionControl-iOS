//
//  MotorTableViewController.swift
//  MissionControl
//
//  Created by Daniel Honies on 03.10.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import UIKit

class MotorTableViewController: UITableViewController, UITabBarControllerDelegate, DisconnectableProtocol {
    var enabledMotorServos: [MotorServo] = [] {
        didSet{
            //tableView.reloadData()
        }
    }
    var motorServos: [MotorServo] = []
    var manager:NetworkManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController!.delegate = self
        navigationController!.navigationBar.barTintColor = UIColor(netHex:0xf43254)
        tabBarController!.tabBar.tintColor = UIColor(netHex: 0xf43254)
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem!.tintColor = UIColor.whiteColor()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        manager!.view = self
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
        return enabledMotorServos.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("motorcell", forIndexPath: indexPath) as! MotorTableViewCell
        cell.configWithMotor(enabledMotorServos[indexPath.row])
        // Configure the cell...

        return cell
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
            enabledMotorServos[indexPath.row].enabled = false
            enabledMotorServos.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editm" {
            let destination = segue.destinationViewController as! UINavigationController
            let controller = destination.visibleViewController as! EditTableViewController
            controller.sensors = self.motorServos
            controller.enabledSensors = self.enabledMotorServos
            controller.delegate = self
        }
    }
    
    @IBAction func disc(sender: UIBarButtonItem) {
        manager!.disconnect()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shouldCloseCauseServerCrash(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if let destination = viewController as? SensorTableViewController{
            destination.enabledMotorServos = enabledMotorServos
            destination.motors = motorServos
        }
        return true
    }

}
