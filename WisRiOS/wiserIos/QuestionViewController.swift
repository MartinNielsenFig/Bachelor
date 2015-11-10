//
//  QuestionViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import JsonSerializerSwift

/// A sub-ViewController of RoomPageViewController. This shows the selected Question that the user can answer.
class QuestionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate, Paged {
    
    //MARK: Properties
    
    let pageIndex = 1
    var roomId: String?
    var firstProgressBarUpdate = true
    var progressTimerUpdater: Updater?
    var selectedAnswerPickerIndex = -1
    var indicator: UIActivityIndicatorView?
    
    //Get instantiated by QuestionListViewController
    var question = Question()
    
    var timeLabel = UILabel()
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var answerPicker: UIPickerView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var questionImageView: UIImageView!
    
    var pickerData = [String]()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        print("QuestionViewController instantiated, roomId: \(self.roomId)")
        super.viewDidLoad()
        
        imageScrollView.delegate = self
        imageScrollView.maximumZoomScale = 6
        imageScrollView.minimumZoomScale = 0.1
        
        answerPicker.delegate = self
        answerPicker.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        
        print("QuestionViewController viewDidAppear")
        
        //Stop any indicator
        indicator?.stopAnimating()
        indicator?.removeFromSuperview()
        
        //Show UI
        if self.question._id == nil {
            return
            //todo display something nice to user :-)
        }
        
        //Progress bar
        updateProgressbar()
        progressTimerUpdater = Updater(secondsDelay: 0.75, function: {
            self.updateProgressbar()
        })
        
        //Picker
        pickerData.removeAll()
        for r in question.ResponseOptions {
            pickerData.append(r.Value)
        }
        answerPicker.reloadAllComponents()
        
        //Text
        questionText.text = question.QuestionText
        
        //Image
        loadImage()
        
        //Answer
        highlightSelectedAnswer()
        
        //Vote btns
        var hasVote = false
        for v in question.Votes {
            if v.CreatedById == CurrentUser.sharedInstance._id! {
                hasVote = true
                updateVoteUI(v.Value == 1)
                break
            }
        }
        if !hasVote {
            resetVoteUI()
        }
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.progressTimerUpdater?.stop()
        super.viewWillDisappear(animated)
    }
    
    
    //MARK: Actions
    
    @IBAction func upvoteBtnPressed(sender: AnyObject) {
        vote(true, button: sender as! UIButton)
    }
    
    @IBAction func downvoteBtnPressed(sender: AnyObject) {
        vote(false, button: sender as! UIButton)
    }
    
    //MARK: Utilities
    
    /**
    Sends a response to the Question to the RestAPI. The answer has the users ID to ensure that he can only respond once (handled by RestAPI)
    - parameter sender:	The button pressed
    */
    @IBAction func sendResponse(sender: AnyObject) {
        
        guard question._id != nil && pickerData.count > 0 else {
            return
        }
        
        let index = answerPicker.selectedRowInComponent(0)
        let answerPickerText = pickerData[index]
        
        //Todo handle if not logged in
        let answer = Answer(value: answerPickerText, userId: CurrentUser.sharedInstance._id!, userDisplayName: CurrentUser.sharedInstance.DisplayName ?? "Anonymous")
        let answerJson = JSONSerializer.toJson(answer)
        let body = "response=\(answerJson)&questionId=\(question._id!)"
        
        HttpHandler.requestWithResponse(action: "Question/AddQuestionResponse", type: "POST", body: body) {
            (notification, response, error) in
            
            if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                if let myResponse = (self.question.Result.filter() { $0.UserId == CurrentUser.sharedInstance._id! }.first) {
                    myResponse.Value = answer.Value
                } else {
                    self.question.Result += [answer]
                }
                
                let youVoted = NSLocalizedString("You voted", comment: "")
                Toast.showToast(youVoted + " \(answer.Value)", durationMs: 2000, presenter: self)
                self.highlightSelectedAnswer(index)
            } else if notification.Errors.contains(ErrorCode.QuestionExpired) {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertController(title: NSLocalizedString("An error has occurred", comment: ""),
                        message: NSLocalizedString("Cannot respond to a question where timer has run out", comment: ""),
                        preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Cancel) { action in
                        //Do nothing
                        })
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } else {
                print("error in adding response to question")
                print(notification.Errors)
            }
        }
    }
    /**
     Highlights the selected answer in the Answer Picker.
     - parameter index:	The index on the selected answer from the user. If it's nil, this function will find it.
     */
    func highlightSelectedAnswer(index: Int? = nil) {
        if let index = index {
            selectedAnswerPickerIndex = index
        } else {
            if let myAnswer = (question.Result.filter() { $0.UserId == CurrentUser.sharedInstance._id! }.first) {
                selectedAnswerPickerIndex = pickerData.indexOf(myAnswer.Value) ?? -1
            } else {
                selectedAnswerPickerIndex = -1
            }
        }
        
        //Will call pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int)
        dispatch_async(dispatch_get_main_queue(), {
            self.answerPicker.reloadAllComponents()
        })
    }
    
    func updateVoteUI(up: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            self.upvoteButton.imageView!.image = up ? UIImage(named: "ThumbsUpBlue") : UIImage(named: "ThumbsUp")
            self.downvoteButton.imageView!.image = !up ? UIImage(named: "ThumbsDownBlue") : UIImage(named: "ThumbsDown")
        }
    }
    
    func resetVoteUI() {
        self.upvoteButton.imageView?.image = UIImage(named: "ThumbsUp")
        self.downvoteButton.imageView?.image = UIImage(named: "ThumbsDown")
    }
    
    /**
     Up- or downvotes the current showing question.
     - parameter up:	If true upvotes, if false downvotes.
     */
    func vote(up: Bool, button: UIButton) {
        
        guard question._id != nil else {
            return
        }
        
        updateVoteUI(up)
        let voteValue = up ? 1 : -1
        let vote = Vote(createdById: CurrentUser.sharedInstance._id!, value: voteValue)
        let voteJson = JSONSerializer.toJson(vote)
        let body = "vote=\(voteJson)&type=MultipleChoiceQuestion&id=\(question._id!)"
        
        HttpHandler.requestWithResponse(action: "Question/AddVote", type: "POST", body: body) {
            (notification, response, error) in
            
            if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                if let myVote = (self.question.Votes.filter() { $0.CreatedById == CurrentUser.sharedInstance._id! }.first) {
                    myVote.Value = voteValue
                } else {
                    self.question.Votes += [vote]
                }
                
                print(up ? "VOTED" : "DOWNVOTED")
            } else {
                self.resetVoteUI()
                print("could not upvote or downvote problem")
                print(notification.Errors)
            }
        }
    }
    
    /**
     Updates the progress bar with time left.
     */
    func updateProgressbar() {
        
        if let startStr = question.CreationTimestamp?.stringByReplacingOccurrencesOfString(",", withString: "."), endStr = question.ExpireTimestamp?.stringByReplacingOccurrencesOfString(",", withString: "."), start = Double(startStr), end = Double(endStr) {
            //Time left progress
            let totalDurationMs = end - start
            let nowMs = Double(NSDate().timeIntervalSince1970*1000)
            let elapsedMs = nowMs - start
            let part = Float(elapsedMs)/Float(totalDurationMs)
            let tLeftMs = totalDurationMs - elapsedMs
            
            progressBar.setProgress(part, animated: !firstProgressBarUpdate)
            
            //Text
            timeLabel.removeFromSuperview()
            timeLabel = UILabel(frame: CGRectMake(0, 0, progressBar.frame.size.width, progressBar.frame.size.height))
            timeLabel.textAlignment = .Center
            
            let tLeftS = NSTimeInterval(tLeftMs/1000)
            let tLeftComponents = DateTimeHelper.getComponents(tLeftS, flags: [.Hour, .Minute, .Second])
            
            //let timeLeft = NSLocalizedString("Time left: ", comment: "")
            timeLabel.text = "\(tLeftComponents.hour):\(tLeftComponents.minute):\(tLeftComponents.second)"
            progressBar.clipsToBounds = false
            progressBar.addSubview(timeLabel)
            
            if part >= 1 {
                progressTimerUpdater?.stop()
                timeLabel.removeFromSuperview()
                return
            }
            firstProgressBarUpdate = false
        }
        else {
            print("could not parse question creationtime or endtime")
        }
    }
    
    /**
     Loads the image for this Question either from cache or from database. Then shows it inside a ImageScrollView so user can pan around and zoom.
     */
    func loadImage() {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicator!.center = self.view.center
        indicator!.startAnimating()
        self.view.addSubview(indicator!)
        
        //Helper function
        func updateImgGui(b64Img: String) {
            let imageData = NSData(base64EncodedString: b64Img, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            guard imageData != nil else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.indicator!.stopAnimating()
                    self.indicator!.removeFromSuperview()
                }
                return
            }
            let questionImage = UIImage(data: imageData!)
            dispatch_async(dispatch_get_main_queue()) {
                self.indicator!.stopAnimating()
                self.indicator!.removeFromSuperview()
                //Add image to image scroll view
                if let questionImage = questionImage where questionImage.size != CGSize(width: 0, height: 0) {
                    self.questionImageView.image = questionImage
                    self.imageScrollView.contentSize = questionImage.size
                    let minimumZoomLevel = self.imageScrollView.frame.size.width/questionImage.size.width
                    self.imageScrollView.minimumZoomScale = minimumZoomLevel
                    self.imageScrollView.zoomScale = minimumZoomLevel
                    self.questionImageView!.reloadInputViews()
                }
            }
        }
        
        //Don't reload image if already loaded
        if let b64Img = self.question.Img {
            updateImgGui(b64Img)
        } else {
            self.questionImageView.image = nil
            HttpHandler.requestWithResponse(action: "Question/GetImageByQuestionId?questionId=\(self.question._id!)", type: "GET", body: "") {
                (notification, response, error) in
                
                if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                    if let data = notification.Data {
                        self.question.Img = data    //this saves the image for later use
                        updateImgGui(data)
                    } else {
                        print("did receive response but did not receive an image")
                    }
                } else {
                    print("error getting image for question")
                    print(notification.Errors)
                }
            }
        }
    }
    
    //MARK: UIPickerViewDelegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if row == selectedAnswerPickerIndex {
            let title = pickerData[row]
            let attributedTitle = NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName:UIColor.blueColor()])
            return attributedTitle
        }
        return nil
    }
    
    //MARK: UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return questionImageView
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowResult" {
            let resultViewController = segue.destinationViewController as! ResultViewController
            resultViewController.question = self.question
        }
    }
}
