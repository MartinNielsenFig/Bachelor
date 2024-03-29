//
//  QuestionListViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import JsonSerializerSwift

/// A sub-ViewController of RoomPageViewController. This shows the available questions for the room.
class QuestionListViewController: UITableViewController, Paged {
    
    //MARK: Properties
    
    /// The index of this view on the RoomPageViewController
    let pageIndex = 0
    /// The roomId of the room this QuestionList resides in.
    var roomId: String?
    /// The questions on the list
    var questions = [Question]() {
        didSet {
            print("QuestionListViewController detected change in self.questions array")
            filter(&self.questions)
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        
        print("QuestionListViewController instantiated, roomId: \(self.roomId)")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        //Load questions for room
        fetchQuestions(refreshControl, manualRefresh: false)
        
        //Add gesture recognizer for long press
        let gesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        gesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(gesture)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        filter(&self.questions)
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
        super.viewDidAppear(true)
    }
    
    //MARK: Utilities
    
    /**
    //Inspired by http://stackoverflow.com/questions/3924446/long-press-on-uitableview handles long press on a Question for either edit or deletion.
    
    - parameter gesture:	The gesture recognizer
    */
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        print("long press detected")
        
        if gesture.state != .Began {
            return
        }
        
        let p = gesture.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(p)
        
        if let indexPath = indexPath, cell = tableView.cellForRowAtIndexPath(indexPath) {
            
            let q = questions[indexPath.row]
            if CurrentUser.sharedInstance._id == nil || q.CreatedById != CurrentUser.sharedInstance._id! {
                print("not logged in or question created by is unknown")
                return
            }
            
            //Build alert
            let deleteTitle = NSLocalizedString("Delete question", comment: "")
            let deleteMessage = NSLocalizedString("Editing a question will delete currently active question and its responses.", comment: "")
            let cancel = NSLocalizedString("Cancel", comment: "")
            let deleteAndEdit = NSLocalizedString("Delete current and edit", comment: "")
            let couldNotDelete = NSLocalizedString("Could not delete question", comment: "")
            let deleted = NSLocalizedString("Question was deleted", comment: "")
            let deleteOnly = NSLocalizedString("Delete only", comment: "")
            
            func deleteThen(edit edit: Bool) {
                if let parent = (self.parentViewController?.parentViewController as? RoomPageViewController) {
                    HttpHandler.requestWithResponse(action: "Question/DeleteQuestion?id=\(q._id!)", type: "DELETE", body: "", completionHandler: {
                        (notification, response, error) in
                        
                        if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                            if edit {
                                parent.editQuestion(q)
                            } else {
                                Toast.showToast(deleted, durationMs: 2000, presenter: self)
                                self.fetchQuestions(manualRefresh: false)
                            }
                        } else {
                            Toast.showOkToast(NSLocalizedString("Error", comment: ""), message: couldNotDelete, presenter: self)
                        }
                    })
                } else {
                    print("could not retrieve parent as roompageviewcontroller could not delete/edit")
                }
            }
            
            let alert = UIAlertController(title: deleteTitle, message: deleteMessage, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: cancel, style: .Cancel, handler: { action in
                //Do nothing
            }))
            alert.addAction(UIAlertAction(title: deleteAndEdit, style: .Destructive, handler: { action in
                deleteThen(edit: true)
            }))
            alert.addAction(UIAlertAction(title: deleteOnly, style: .Destructive, handler: { (action) in
                deleteThen(edit: false)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    /**
     Filters the questions in the room by concatenated up-/downvotes. So that upvotes are positive, and downvotes are negative.
     
     - parameter questions:	The questions array to be filtered in-place.
     */
    func filter(inout questions: [Question]) {
        if questions.count <= 1 {
            return
        }
        questions.sortInPlace { (el1, el2) -> Bool in
            let t1 = upDownVotesCount(el1)
            let t2 = upDownVotesCount(el2)
            
            let c1 = t1.upvotes - t1.downvotes
            let c2 = t2.upvotes - t2.downvotes
            
            return c1 > c2
        }
    }
    
    /**
     Determines the number of up- and down-votes for a specific question.
     
     - parameter question:	The question to count the down-upvotes for.
     - returns: A tuple with down and upvotes.
     */
    func upDownVotesCount(question: Question) -> (downvotes: Int, upvotes: Int) {
        let noDownvotes = question.Votes.filter { (element) -> Bool in
            return element.Value == -1
            }.count
        
        let noUpvotes = question.Votes.filter { (element) -> Bool in
            return element.Value == 1
            }.count
        
        return (noDownvotes, noUpvotes)
    }
    
    /**
     Downloads the questions for the curret room without the images from the database to display on the list.
     
     - parameter refreshControl:	An optional refreshcontrol to show loading
     - parameter manualRefresh:	If called with manual refresh true, it means it was called by the user swiping down. In this case the UI is already responding to it. But if it's called by code, manualRefresh should be false to scroll down the view to show the UIRefreshControl
     */
    func fetchQuestions(refreshControl: UIRefreshControl? = nil, manualRefresh: Bool) {
        
        if let rc = refreshControl where !manualRefresh {
            rc.beginRefreshing()
            self.tableView.setContentOffset(CGPoint(x: 0, y: -rc.frame.size.height), animated: true)
        }
        
        //"Swift Trailing Closure" syntax
        let action = "Question/GetQuestionsForRoomWithoutImages?roomId=\(self.roomId!)"
        HttpHandler.requestWithResponse(action: action, type: "GET", body: "") {
            (notification, response, error) in
            
            var tmpQuestions = [Question]()
            if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                
                if let data = notification.Data, jsonArray = try? JSONSerializer.toArray(data) {
                    for question in jsonArray {
                        tmpQuestions += [Question(jsonDictionary: question as! NSDictionary)]
                    }
                    
                    if tmpQuestions.count <= 0 {
                        let q = Question()
                        q.QuestionText = NSLocalizedString("No questions for room", comment: "")
                        q.CreatedById = "system"
                        tmpQuestions += [q]
                    }
                }
            } else {
                let qError = Question()
                qError.QuestionText = NSLocalizedString("Could not load questions", comment: "")
                qError.CreatedById = "system"
                tmpQuestions = [qError]
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.questions.removeAll()
                self.questions += tmpQuestions
                refreshControl?.endRefreshing()
            }
        }
    }
    
    //MARK: UIRefreshControl
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        fetchQuestions(refreshControl, manualRefresh: true)
    }
    
    //MARK: UITableViewController
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let question = questions[indexPath.row]
        
        if question.CreatedById == "system" {
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "Default")
            cell.textLabel?.text = question.QuestionText
            return cell
        }
        
        let cellIdentifier = "QuestionCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! QuestionViewCell
        
        //If question string is too long shorten it
        cell.label.text = StringExtractor.shortenString(question.QuestionText!, maxLength: 30)
        
        let votesCount = upDownVotesCount(question)
        cell.upvoteCounter.text = String(votesCount.upvotes)
        cell.downvoteCounter.text = String(votesCount.downvotes)
        
        //If already voted
        if let myId = CurrentUser.sharedInstance._id, myVote = (question.Votes.filter() { $0.CreatedById == myId }.first) {
            cell.userHasVoted(up: myVote.Value == 1)
        } else {
            //This needs to be done because we're using dequeueReusableCellWithIdentifier, else all will be blue after first
            cell.defaultImage()
        }
        
        //Mark questions made by room creator
        if let parent = (parentViewController?.parentViewController as? RoomPageViewController) {
            cell.textLabel?.textColor = UIColor.blackColor()
            if question.CreatedById == parent.room?.CreatedById {
                cell.label.font = UIFont.boldSystemFontOfSize(16.0)
            } else {
                cell.label.font = UIFont.systemFontOfSize(16.0);
            }
        } else {
            print("could not get parent view controller 67823409")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let roomPageViewController = parentViewController?.parentViewController as! RoomPageViewController
        let questionPage = roomPageViewController.viewControllerAtIndex(1, createNew: false)! as! QuestionViewController
        questionPage.question = questions[indexPath.row]
        roomPageViewController.pageViewController.setViewControllers([questionPage], direction: .Forward, animated: true, completion: nil)
        questionPage.viewDidAppear(true)
    }
}
