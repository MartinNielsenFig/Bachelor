//
//  ResultViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 28/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import Charts
import JsonSerializerSwift

/// Manages the resultview and uses external charts module https://github.com/danielgindi/ios-charts Based upon http://www.appcoda.com/ios-charts-api-tutorial/
class ResultViewController: UIViewController {
    
    //MARK: Properties
    
    /// Reference to the pie chart view
    @IBOutlet var pieChartView: PieChartView!
    
    /// The question this resultview represents
    var question: Question!
    
    var updater: Updater?
    
    var colors = [UIColor]()

    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        
        pieChartView.descriptionText = ""
        pieChartView.legend.position = ChartLegend.ChartLegendPosition.AboveChartRight
        colors += ChartColorTemplates.joyful()
        colors += ChartColorTemplates.colorful()
        colors += ChartColorTemplates.liberty()
        colors += ChartColorTemplates.pastel()
        
        updateChart()
        
        updater = Updater(secondsDelay: 4, function: {
            
            if self.question._id == nil {
                self.showErrorToast()
                return
            }
            
            HttpHandler.requestWithResponse(action: "Question/GetQuestionWithoutImage?id=\(self.question._id!)", type: "GET", body: "", completionHandler: {
                (notification, response, error) -> Void in
                if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                    
                    if let data = notification.Data, json = try? JSONSerializer.toDictionary(data) {
                        let q = Question(jsonDictionary: json)
                        self.question = q
                        print("did receive question with new answers")
                    }
                    
                    self.updateChart()
                } else {
                    self.showErrorToast()
                }
            })
        }, debugName: "result updater")
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        updater?.stop()
    }
    
    //MARK: Utilities
    
    func showErrorToast() {
        Toast.showOkToast(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wrong in updating the result view. Maybe the question was deleted?", comment: ""), presenter: self)
    }
    
    /**
    Updates the chart on the ui
     
    - parameter dataPoints:	The datapoints to be represented
    - parameter values:			The values to be represented.
    */
    func updateChart() {
        
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
        
        //To graph:
        
        var dataEntries = [BarChartDataEntry]()
        for i in 0..<options.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries += [dataEntry]
        }
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let chartData = PieChartData(xVals: options, dataSet: chartDataSet)
        self.pieChartView.data = chartData
        
        let predefinedColorsCount = colors.count
        if predefinedColorsCount < options.count {
            for _ in predefinedColorsCount..<options.count {
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
