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
    @IBOutlet var pieChartView: PieChartView!
    
    //Instantiated by previous ViewController
    var question: Question!

    override func viewDidLoad() {
        //Values hold a counter for how many have votes that particular response
        var values = [Double](count: question.ResponseOptions.count, repeatedValue: 0)
        //Options holds the response options
        var options = [String]()
        
        for (index, ro) in question.ResponseOptions.enumerate() {
            options += [ro.Value]
            
            for a in self.question.Result {
                if a.Value == ro.Value {
                    ++values[index]
                }
            }
        }
        
        updateChart(options, values: values)
    }
    
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
        colors += [UIColor.redColor()]
        colors += [UIColor.blueColor()]
        colors += [UIColor.greenColor()]
        colors += [UIColor.purpleColor()]
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
