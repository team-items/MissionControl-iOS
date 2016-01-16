//
//  MotorTableViewCell.swift
//  MissionControl
//
//  Created by Daniel Honies on 03.10.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import UIKit

class MotorTableViewCell: UITableViewCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var button: UIButton!
    var motor: MotorServo = MotorServo()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        slider.continuous = false
        
    }
    func configWithMotor(motor: MotorServo){
        self.motor = motor
        nameLabel.text = motor.Name
        slider.maximumValue = Float(motor.MaxBound)
    slider.minimumValue = Float(motor.MinBound)
    }
    
    @IBAction func sliderChanged(sender: UISlider) {
        valueLabel.text = String(Int(slider.value))
        var tableView = self.superview?.superview! as! UITableView
        var con = tableView.dataSource as! MotorTableViewController
        var client = con.client
        client.send(str: "{\"Control\":{\"" + motor.SliderName + "\": " + String(Int(slider.value)) + "}} ")
    }
    
    @IBAction func buttonClicked(sender: UIButton) {
        var tableView = self.superview?.superview! as! UITableView
        var con = tableView.dataSource as! MotorTableViewController
        var client = con.client
        client.send(str: "{\"Control\":{\"" + motor.ButtonName + "\": \"click\"}} ")
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
        // Configure the view for the selected state
    }

}
