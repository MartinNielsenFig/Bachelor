//
//  QuestionViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, Paged {
    
    //Paged
    let pageIndex = 0

    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var answerPicker: UIPickerView!
    
    var currentQuestion: Question? = nil
    var pickerData = ["doge", "cate", "marsvin"]
    
    override func viewDidLoad() {
        answerPicker.delegate = self
        answerPicker.dataSource = self
        
    }
    
    //UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

}
