//
//  SensorTableViewCell.swift
//  MissionControl
//
//  Created by Daniel Honies on 04.10.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import UIKit

class SensorTableViewCell: UITableViewCell, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate{
    var arrayOfValues = [0,382,1,1024,503,284]
    @IBOutlet weak var graph: BEMSimpleLineGraphView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        graph.dataSource = self
        graph.delegate = self
        graph.colorBackgroundYaxis = UIColor.whiteColor()
        
        
    }
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return self.arrayOfValues.count
        
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        return CGFloat( self.arrayOfValues[index])
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
