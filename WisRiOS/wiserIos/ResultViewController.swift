//
//  ResultViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 28/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import Charts

/// Manages the resultview and uses external charts module https://github.com/danielgindi/ios-charts Based upon http://www.appcoda.com/ios-charts-api-tutorial/
class ResultViewController: UIViewController {
    
    //MARK: Properties
    
    /// Reference to the pie chart view
    @IBOutlet var pieChartView: PieChartView!
    
    /// The question this resultview represents
    var question: Question!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        
        pieChartView.descriptionText = ""
        pieChartView.legend.position = ChartLegend.ChartLegendPosition.AboveChartRight
        
        //Values hold a counter for how many have votes that particular response have
        var values = [Double](count: question.ResponseOptions.count, repeatedValue: 0)
        //Options holds the response options
        var options = [String]()
        
        let totalVotes = Double(self.question.Result.count)
        
        for (index, option) in question.ResponseOptions.enumerate() {
            for a in self.question.Result {
                if a.Value == option.Value {
                    ++values[index]
                }
            }
            
            let percentage = totalVotes == 0 ? 0 : Int(((values[index]/totalVotes)*100))
            options += [ "\(option.Value) (\(percentage)%)" ]
        }
        
        updateChart(options, values: values)
    }
    
    //MARK: Utilities
    
    /**
    Updates the chart on the ui
    - parameter dataPoints:	The datapoints to be represented
    - parameter values:			The values to be represented.
    */
    func updateChart(dataPoints: [String], values: [Double]) {
        var dataEntries = [BarChartDataEntry]()
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries += [dataEntry]
        }
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let chartData = PieChartData(xVals: dataPoints, dataSet: chartDataSet)
        self.pieChartView.data = chartData
        
        var colors = [UIColor]()
        colors += ChartColorTemplates.joyful()
        colors += ChartColorTemplates.colorful()
        colors += ChartColorTemplates.liberty()
        colors += ChartColorTemplates.pastel()
        
        let predefinedColorsCount = colors.count
        if predefinedColorsCount < dataPoints.count {
            for _ in predefinedColorsCount..<dataPoints.count {
                let red = Double(arc4random_uniform(256))
                let green = Double(arc4random_uniform(256))
                let blue = Double(arc4random_uniform(256))
                
                let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                colors.append(color)
            }
        }
        chartDataSet.colors = colors
    }
}
