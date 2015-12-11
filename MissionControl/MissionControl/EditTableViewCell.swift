//
//  EditTableViewCell.swift
//  MissionControl
//
//  Created by Daniel Honies on 10.12.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import UIKit

class EditTableViewCell: UITableViewCell {

    @IBOutlet weak var switcher: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    var sensor: AnalogS = AnalogS()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func conwithsensor(sensor:AnalogS){
        self.sensor = sensor
     }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)

        // Configure the view for the selected state
    }

}
