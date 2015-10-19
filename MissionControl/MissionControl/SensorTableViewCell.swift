//
//  SensorTableViewCell.swift
//  MissionControl
//
//  Created by Daniel Honies on 04.10.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import UIKit

class SensorTableViewCell: UITableViewCell, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate{
    var arrayOfValues = [0]
    var ispaused = false
    var expanded = false
    
    var tableView = UITableView()
    @IBOutlet weak var graph: BEMSimpleLineGraphView!
    
    @IBOutlet weak var sensorLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if ispaused{
        pauseButton.setTitle("Resume", forState: UIControlState.Normal)
        }
        for (var i = 1; i < 50; i++){
            arrayOfValues.append(Int(arc4random_uniform(1025)))
        }
        graph.dataSource = self
        graph.delegate = self
        graph.enableReferenceAxisFrame = true
        graph.enableRightReferenceAxisFrameLine = true
        graph.enableTopReferenceAxisFrameLine = true
        graph.enablePopUpReport = true
        graph.colorPoint = UIColor(netHex: 0xf43254)
        graph.colorBackgroundPopUplabel = UIColor(netHex: 0xf43254)
        graph.animationGraphEntranceTime = 0
        graph.clearsContextBeforeDrawing = false
        graph.animationGraphStyle = BEMLineAnimation.None
        
      //  graph.autoScaleYAxis = false
        
      
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "update", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
    }
    func maxValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        return 1024
    }
    func minValueForLineGraph(graph: BEMSimpleLineGraphView) -> CGFloat {
        return 0
    }
    @IBAction func pause(sender: UIButton) {
        ispaused = !ispaused
        if ispaused{
            pauseButton.setTitle("Resume", forState: UIControlState.Normal)
        }else{
pauseButton.setTitle("Pause", forState: UIControlState.Normal)        }
    }
    
    func update(){
        if (!ispaused){
    
        arrayOfValues.append(Int(arc4random_uniform(1025)))
        arrayOfValues.removeFirst()
        graph.reloadGraph()
        
        }
        
    }
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return self.arrayOfValues.count
        
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        return CGFloat( self.arrayOfValues[index])
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)

        // Configure the view for the selected state
    }
    
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
}