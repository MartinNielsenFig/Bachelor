//
//  CreateQuestionViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 21/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class CreateQuestionViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Gets instantiated by RoomPageViewController in prepareForSegue
    var room: Room!
    
    var questionText: TextInputCell? = nil
    var durationInput: NumberInputCell? = nil
    var imageTableCell: UITableViewCell? = nil
    var selectedImage: UIImage?
    
    var photoSelected = false {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addQuestion")
    }
    
    func addQuestion() {
        let q = Question()
        q.CreatedById = CurrentUser.sharedInstance._id
        
        //http://stackoverflow.com/questions/11251340/convert-uiimage-to-base64-string-in-objective-c-and-swift
        if let image = selectedImage {
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            let b64 = imageData?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            q.Img = b64
        }
        
        q.QuestionText = questionText?.textLabel?.text
        q.RoomId = room._id
        
        let duration = durationInput?.textLabel?.text ?? "0"
        q.ExpireTimestamp = String(Int(duration)!/60)
        
        let jsonQ = JSONSerializer.toJson(q)
        let body = "roomId=\(room._id)&question=\(jsonQ)&type=MultipleChoiceQuestion"
        HttpHandler.requestWithResponse(action: "Question/CreateQuestion", type: "POST", body: body) { (data, response, error) -> Void in
            NSLog("error 2837")
        }
    }
    
    //UITableViewController
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cellIdentifier = "TextInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextInputCell
            cell.label.text = "Question text"
            questionText = cell
            return cell
        }
        else if indexPath.row == 1 {
            let cellIdentifier = "NumberInputCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! NumberInputCell
            cell.label.text = "Duration (s)"
            durationInput = cell
            return cell
        }
        else if indexPath.row == 2 {
            let cell = UITableViewCell()
            imageTableCell = cell
            cell.textLabel?.text = "Select image"
            if selectedImage != nil {
                cell.imageView?.image = selectedImage
            }
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 2 && photoSelected {
            return CGFloat(64*3)
        }
        else {
            return CGFloat(64)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 2 {
            questionText?.resignFirstResponder()    //hide keyboard
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .Camera
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { action in
                imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
                imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }))
            
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