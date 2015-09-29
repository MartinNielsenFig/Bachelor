//
//  ResultViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 28/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import Charts

class ResultViewController: UIViewController {
    @IBOutlet var pieChartView: PieChartView!
    var options = [String]()
    
    //Instantiated by previous ViewController
    var question: Question!

    override func viewDidLoad() {
        var values = [Double](count: question.ResponseOptions.count, repeatedValue: 0)
        
        for (index, ro) in question.ResponseOptions.enumerate() {
            options += [ro.Value]
            
            for a in self.question.Result {
                if a.Value == ro.Value {
                    ++values[index]
                }
            }
            
        }
        
        setChart(options, values: values)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries = [BarChartDataEntry]()
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries += [dataEntry]
        }
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let chartData = PieChartData(xVals: options, dataSet: chartDataSet)
        self.pieChartView.data = chartData
        
        var colors = [UIColor]()
        
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        chartDataSet.colors = colors
    }
}
