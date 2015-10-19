//
//  SensorTableViewCell.swift
//  MissionControl
//
//  Created by Daniel Honies on 04.10.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import UIKit
import Charts
class SensorTableViewCell: UITableViewCell, ChartViewDelegate{
    var arrayOfValues = [ChartDataSet]()
    var ispaused = false
    var expanded = false
    var timer = NSTimer()
    var tableView = UITableView()
    var set1: LineChartDataSet = LineChartDataSet()
    @IBOutlet weak var graph: LineChartView!
    @IBOutlet weak var sensorLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    var points = 60
    var updateRate = 20
    var visible = 30
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if ispaused{
        pauseButton.setTitle("Resume", forState: UIControlState.Normal)
        }
        
        graph.delegate = self
        graph.notifyDataSetChanged();
        graph.scaleYEnabled = false
        graph.scaleXEnabled = false
        graph.legend.enabled = false
        graph.xAxis.drawLabelsEnabled = false
       
        setDataCount(points, range: 1024)
        /*
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
        */
      //  graph.autoScaleYAxis = false
        
      
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "update", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
    }
    func setDataCount(count: Int, range: Double) {
        var xVals: [NSObject] =  [NSObject]()
        for var i = 0; i < count; i++ {
            xVals.append(String(i))
        }
        var yVals: [ChartDataEntry] = [ChartDataEntry]()
        for var i = 0; i < count; i++ {
            var mult: UInt32 = (UInt32(range) + 1)
            var val: Double = Double((arc4random_uniform(mult)) + 3)
            yVals.append(ChartDataEntry(value: val, xIndex: i))
        }
        set1 = LineChartDataSet(yVals: yVals, label: "DataSet 1")
        set1.drawValuesEnabled = false
        set1.drawCirclesEnabled = false
        set1.setColor(UIColor.blackColor())
        set1.setCircleColor(UIColor.blackColor())
        set1.lineWidth = 1.0
        set1.circleRadius = 3.0
        set1.drawCircleHoleEnabled = false
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.blackColor()
        var dataSets: [ChartDataSet] = [ChartDataSet]()
        dataSets.append(set1)
        var data: LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        
        graph.data = data
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
            var mult: UInt32 = (UInt32(1024) + 1)
            var val: Double = Double((arc4random_uniform(mult)) + 3)
            
            var data = graph.data!
            var set = data.getDataSetByIndex(0);
            data.addXValue("")
            data.removeXValue(0)
            
            set.removeEntry(xIndex: 0)
            data.addEntry(ChartDataEntry(value: val, xIndex: set.entryCount + 1),dataSetIndex: 0)
            for s in set.yVals{
                s.xIndex = s.xIndex - 1
            }
            graph.notifyDataSetChanged()
            graph.setVisibleXRangeMaximum(CGFloat(visible));
            
            
            // move to the latest entry
            graph.moveViewToX(points - visible);
            
            
        //graph.reloadGraph()
        
        }
        
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