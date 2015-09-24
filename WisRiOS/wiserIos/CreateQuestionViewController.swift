//
//  CreateQuestionViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 21/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class CreateQuestionViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Properties
    //Gets instantiated by RoomPageViewController in prepareForSegue
    var room: Room!
    
    var responseOptions = [ResponseOption]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    var questionText: TextInputCell? = nil
    var durationInput: NumberInputCell? = nil
    var imageTableCell: UITableViewCell? = nil
    var selectedImage: UIImage?
    var addResponseCell: TextButtonInputCell? = nil
    
    var photoSelected = false {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    //Lifecycle
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addQuestion")
    }
    
    //Utilities
    func addQuestion() {
        let q = Question()
        q.CreatedById = CurrentUser.sharedInstance._id
        
        //http://stackoverflow.com/questions/11251340/convert-uiimage-to-base64-string-in-objective-c-and-swift
        if let selectedImage = selectedImage {
            let imageData = UIImageJPEGRepresentation(selectedImage, 0.8)
            if let imageData = imageData {
                let imageSizeMb = (imageData.length)/(1024*1024)
                print("IMAGE SIZE: \(imageSizeMb) MB")
                
                let b64 = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
                
                let b64ImageSizeMb = b64.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)/(1024*1024)
                print("BASE64 IMAGE SIZE \(b64ImageSizeMb) MB")
                
                q.Img = b64
            }
        }
        
        q.ResponseOptions = responseOptions
        q.QuestionText = questionText?.inputField.text
        q.RoomId = room._id
        
        if let input = durationInput?.inputField.text where input != "" {
            let duration = Int(input)!/60
            q.ExpireTimestamp = String(duration)
        } else {
            q.ExpireTimestamp = "1"
        }
        
        let jsonQ = JSONSerializer.toJson(q)
        let body = "roomId=\(room._id!)&question=\(jsonQ)&type=MultipleChoiceQuestion"
        HttpHandler.requestWithResponse(action: "Question/CreateQuestion", type: "POST", body: body) { (data, response, error) -> Void in
            
        }
    }
    
    func AddResponseOption() {
        if let responseText = addResponseCell?.inputField.text {
            let r = ResponseOption(value: responseText, weight: 1)
            responseOptions += [r]
        }
    }
    
    //UITableViewController
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Question parameters"
        }
        else {
            return "Reponse options"
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        else {
            return responseOptions.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                let cellIdentifier = "TextInputCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextInputCell
                cell.label.text = "Question text"
                questionText = cell
                cell.selectionStyle = .None
                return cell
            }
            else if indexPath.row == 1 {
                let cellIdentifier = "NumberInputCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! NumberInputCell
                cell.label.text = "Duration (s)"
                durationInput = cell
                cell.selectionStyle = .None
                return cell
            }
            else if indexPath.row == 2 {
                let cell = UITableViewCell()
                imageTableCell = cell
                cell.textLabel?.text = "Select image"
                if selectedImage != nil {
                    cell.imageView?.image = selectedImage
                }
                cell.selectionStyle = .None
                return cell
            }
            else if indexPath.row == 3 {
                let cellIdentifier = "TextButtonInputCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextButtonInputCell
                cell.label.text = "Add Response"
                cell.button.addTarget(self, action: "AddResponseOption", forControlEvents: .TouchUpInside)
                addResponseCell = cell
                cell.selectionStyle = .None
                return cell
            }
        }
        else {
            let cell = UITableViewCell()
            cell.textLabel?.text = responseOptions[indexPath.row].Value
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 2 && photoSelected {
            return CGFloat(64*3)
        }
        else {
            return CGFloat(64)
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 2 {
            questionText?.resignFirstResponder()    //hide keyboard
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                imagePickerController.sourceType = .Camera
            }
            else {
                imagePickerController.sourceType = .PhotoLibrary
            }
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { action in
                imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
                imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }))
            
            //http://stackoverflow.com/questions/25759885/uiactionsheet-from-popover-with-ios8-gm
            //iPad support
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
            
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.photoSelected = true
        selectedImage = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        imageTableCell?.imageView?.image = selectedImage
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
}