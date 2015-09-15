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
    var chosenQuestion: Question? {
        didSet {
            print("did set chosenQuestion")
        }
    }
    
    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var answerPicker: UIPickerView!
    @IBOutlet weak var questionImage: UIImageView!
    
    var pickerData = ["doge", "cate", "marsvin"]
    
    override func viewDidLoad() {
        //Load the current question
        
        
        answerPicker.delegate = self
        answerPicker.dataSource = self
    }
    
    //TODO
    /*func loadImage() {
        if let b64Img = (self.parentViewController as! RoomPageViewController).questions[0].Img {
            let imageData = NSData(base64EncodedString: b64Img, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            let image = UIImage(data: imageData!)
            questionImage.image = image
        }
    }*/
    
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
