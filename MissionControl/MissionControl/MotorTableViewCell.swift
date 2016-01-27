//
//  MotorTableViewCell.swift
//  MissionControl
//
//  Created by Daniel Honies on 03.10.15.
//  Copyright © 2015 F-WUTS. All rights reserved.
//

import UIKit

class MotorTableViewCell: UITableViewCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var button: UIButton!
    
    var manager:NetworkManager? = nil
    var motor: MotorServo = MotorServo()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        slider.continuous = true
        
    }
    
    func configWithMotor(motor: MotorServo){
        self.motor = motor
        nameLabel.text = motor.Name
        slider.maximumValue = Float(motor.MaxBound)
        slider.minimumValue = Float(motor.MinBound)
    }
    
    //Grabs the network manager from the superview and sends message
    func sendControl(msg:String){
        let tableView:UITableView? = self.superview?.superview! as? UITableView
        let con = tableView!.dataSource as! MotorTableViewController
        manager = con.manager!

        manager!.sendAsync(msg)
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        valueLabel.text = String(Int(slider.value))
    }
    
    @IBAction func touchUp(sender: AnyObject) {
        sendControl("{\"Control\":{\"" + motor.SliderName + "\": " + String(Int(slider.value)) + "}} ")
    }
    
    @IBAction func buttonClicked(sender: UIButton) {
         sendControl("{\"Control\":{\"" + motor.ButtonName + "\": \"click\"}} ")
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }

}
