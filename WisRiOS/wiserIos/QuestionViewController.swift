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
    let pageIndex = 1
    var roomId: String?
    
    //Get instantiated by QuestionListViewController
    var question = Question()
    
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var answerPicker: UIPickerView!
    @IBOutlet weak var questionImage: UIImageView!
    
    var pickerData = [String]()
    
    func showQuestionUI() {
        //Picker
        pickerData.removeAll()
        for r in question.ResponseOptions {
            pickerData.append(r.Value)
        }
        answerPicker.reloadAllComponents()
        
        //Text
        questionText.text = question.QuestionText
        
        //Image
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicator.center = self.questionImage.center

        indicator.startAnimating()
        self.view.addSubview(indicator)
        
        HttpHandler.requestWithResponse(action: "Question/GetImageByQuestionId?questionId=\(self.question._id!)", type: "GET", body: "") {
            (data, response, error) -> Void in
            self.question.Img = data
            
            if let b64Img = self.question.Img {
                let imageData = NSData(base64EncodedString: b64Img, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                let image = UIImage(data: imageData!)
                
                dispatch_async(dispatch_get_main_queue()) {
                    indicator.stopAnimating()
                    indicator.removeFromSuperview()
                    self.questionImage.image = image
                    self.questionImage.reloadInputViews()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        answerPicker.delegate = self
        answerPicker.dataSource = self
        showQuestionUI()
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
