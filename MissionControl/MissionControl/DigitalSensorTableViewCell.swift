//
//  DigitalSensorTableViewCell.swift
//  MissionControl
//
//  Created by Daniel Honies on 11.1.15.
//  Copyright © 2015 Daniel Honies. All rights reserved.
//

import UIKit
import Charts
import JSONJoy
import SwiftyJSON
class DigitalSensorTableViewCell: UITableViewCell, ChartViewDelegate{
    var arrayOfValues = [ChartDataSet]()
    
    @IBOutlet weak var valueLabel: UILabel!
    var ispaused = false
    var expanded = false
    var timer = NSTimer()
    var tableView = UITableView()
    var set1: LineChartDataSet = LineChartDataSet()
    @IBOutlet weak var graph: LineChartView!
    @IBOutlet weak var sensorLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    var points = 40
    var updateRate = 20
    var visible = 40
    var sensor: DigitalS = DigitalS(JSONDecoder(""));
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if ispaused{
            pauseButton.setTitle("Resume", forState: UIControlState.Normal)
        }
        
        graph.delegate = self
        
        graph.autoScaleMinMaxEnabled = false
        graph.scaleYEnabled = false
        graph.scaleXEnabled = false
        graph.legend.enabled = false
        graph.xAxis.drawLabelsEnabled = false
        graph.gridBackgroundColor = UIColor.whiteColor()
        graph.setScaleEnabled(false)
        graph.drawBordersEnabled = true
        graph.borderColor = UIColor(netHex: 0xf43254)
        graph.gridBackgroundColor = UIColor.whiteColor()
        
        graph.highlightPerDragEnabled = true
        let axis = graph.getAxis(ChartYAxis.AxisDependency.Left)
        axis.drawGridLinesEnabled = false
        axis.drawAxisLineEnabled = false
        axis.spaceTop = 0
        let axis2 = graph.getAxis(ChartYAxis.AxisDependency.Right)
        axis2.drawGridLinesEnabled = true
        axis2.drawAxisLineEnabled = false
        axis2.spaceTop = 0
        
        graph.descriptionText = ""
        setDataCount(points, range: 1024)
        let marker: ChartMarker = ChartMarker(color: UIColor(netHex: 0xf43254), font: UIFont.systemFontOfSize(12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
        
        marker.minimumSize = CGSizeMake(80, 40)
        graph.marker = marker
        
        graph.notifyDataSetChanged();
        //timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "update", userInfo: nil, repeats: true)
        // NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
    }
    
    func configWithSensor(s:DigitalS){
        sensor = s;
        self.sensorLabel.text = sensor.Name
        self.visible = sensor.Graph.integerValue
        setDataCount(visible, range: 1)
        let leftAxis: ChartYAxis = graph.getAxis(ChartYAxis.AxisDependency.Left)
        let rightAxis:ChartYAxis = graph.getAxis(ChartYAxis.AxisDependency.Right)
        leftAxis.axisMaximum = 1
        leftAxis.axisMinimum = 0
        leftAxis.axisRange = 1
        rightAxis.axisMaximum = 1
        rightAxis.axisMinimum = 0
        rightAxis.axisRange = 1
        
    }
    
    
    func setDataCount(count: Int, range: Double) {
        var xVals: [NSObject] =  [NSObject]()
        for var i = 0; i < count; i++ {
            xVals.append(String(i))
        }
        var yVals: [ChartDataEntry] = [ChartDataEntry]()
        for var i = 0; i < count; i++ {
            //let mult: UInt32 = (UInt32(range) + 1)
            let val: Double = Double(0)
            yVals.append(ChartDataEntry(value: val, xIndex: i))
        }
        set1 = LineChartDataSet(yVals: yVals, label: "DataSet 1")
        set1.drawValuesEnabled = false
        set1.drawCirclesEnabled = false
        set1.setColor(UIColor(netHex: 0xf43254))
        set1.setCircleColor(UIColor(netHex: 0xf43254))
        set1.lineWidth = 1.0
        set1.circleRadius = 2.0
        set1.drawCircleHoleEnabled = false
        set1.fillAlpha = 65 / 255.0
        
        var dataSets: [ChartDataSet] = [ChartDataSet]()
        dataSets.append(set1)
        let data: LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        
        graph.data = data
    }
    
    @IBAction func pause(sender: UIButton) {
        ispaused = !ispaused
        if ispaused{
            let data = graph.data!
            let set = data.getDataSetByIndex(0);
            for entry in set.yVals {
                sensor.oldValues.append(Int(entry.value))
                set.removeEntry(entry)
            }
            for  (var i = 0; i < sensor.oldValues.count; i++){
                data.addXValue("")
                data.addEntry(ChartDataEntry(value: Double(sensor.oldValues[i]), xIndex: i), dataSetIndex: 0)
            }
            graph.notifyDataSetChanged()
            graph.setVisibleXRangeMaximum(CGFloat(visible));
            graph.setVisibleXRangeMinimum(0)
            graph.moveViewToX(sensor.oldValues.count - visible);
            pauseButton.setTitle("Resume", forState: UIControlState.Normal)
        }else{
            pauseButton.setTitle("Pause", forState: UIControlState.Normal)
            let data = graph.data!
            let set = data.getDataSetByIndex(0);
            print(set.yVals.count - visible)
            print(set.yVals.count)
            let vari = set.yVals.count - visible
            var vals: [ChartDataEntry] = Array(set.yVals.dropFirst(vari))
            for entry in set.yVals{
                graph.data!.removeXValue(0)
                graph.data!.getDataSetByIndex(0).removeEntry(entry)
                
            }
            for (var index = 0; index < visible; index++){
                set.addEntry(ChartDataEntry(value: Double(vals[index].value), xIndex: index))
            }
            graph.notifyDataSetChanged()
            graph.setVisibleXRangeMaximum(CGFloat(visible));
            graph.moveViewToX(0);
        }
    }
    
    func update(value: JSON){
        if (!ispaused){
            valueLabel.text = value.stringValue
            //let mult: UInt32 = (UInt32(1024) + 1)
            var val: Double = 0
            if(value.boolValue){
                val = 1
            }
            
            let data = graph.data!
            let set = data.getDataSetByIndex(0);
            data.addXValue("")
            data.removeXValue(0)
            if var _ = set.entryForXIndex(0){
                sensor.oldValues.append(Int(set.entryForXIndex(0)!.value))
            }
            set.removeEntry(xIndex: 0)
            data.addEntry(ChartDataEntry(value: val, xIndex: set.entryCount + 1),dataSetIndex: 0)
            for s in set.yVals{
                s.xIndex = s.xIndex - 1
            }
            graph.notifyDataSetChanged()
            graph.setVisibleXRangeMaximum(CGFloat(visible));
            graph.setVisibleXRangeMinimum(CGFloat(visible))
            
            // move to the latest entry
            graph.moveViewToX(0);
            
        }
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
        
        // Configure the view for the selected state
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        //
    }
    
    func chartValueNothingSelected(chartView: ChartViewBase) {
        //
    }
}

