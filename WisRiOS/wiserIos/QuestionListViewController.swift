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
    let pageIndex = 0
    var roomId: String?
    var questions = [Question]() {
        didSet {
            print("QuestionListViewController detected change in self.questions array")
            filter(&self.questions)
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Lifetime
    override func viewDidLoad() {
        
        print("QuestionListViewController instantiated, roomId: \(self.roomId)")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        //Load questions for room
        fetchQuestions(refreshControl)
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
    
    func fetchQuestions(refreshControl: UIRefreshControl? = nil) {
        
        if let rc = refreshControl {
            rc.beginRefreshing()
            self.tableView.setContentOffset(CGPoint(x: 0, y: -rc.frame.size.height), animated: true)
        }
        
        //"Swift Trailing Closure" syntax
        let action = "Question/GetQuestionsForRoomWithoutImages?roomId=\(self.roomId!)"
        HttpHandler.requestWithResponse(action: action, type: "GET", body: "") { (data, response, error) -> Void in
            
            var tmpQuestions = [Question]()
            if let jsonArray = try? JSONSerializer.toArray(data) {
                for question in jsonArray {
                    tmpQuestions += [Question(jsonDictionary: question as! NSDictionary)]
                }
                
                if tmpQuestions.count <= 0 {
                    let q = Question()
                    q.QuestionText = NSLocalizedString("No questions for room", comment: "")
                    q.CreatedById = "system"
                    tmpQuestions += [q]
                }
                
            } else {
                let qError = Question()
                qError.QuestionText = NSLocalizedString("Could not load questions", comment: "")
                qError.CreatedById = "system"
                tmpQuestions = [qError]
            }
            
            //http://stackoverflow.com/questions/18847438/dispatch-get-main-queue-in-main-thread
            dispatch_async(dispatch_get_main_queue()) {
                self.questions.removeAll()
                self.questions += tmpQuestions
                refreshControl?.endRefreshing()
            }
        }
    }
    
    //MARK: UIRefreshControl
    func handleRefresh(refreshControl: UIRefreshControl) {
        fetchQuestions(refreshControl)
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
        if let myVote = (question.Votes.filter() { $0.CreatedById == CurrentUser.sharedInstance._id }.first) {
            cell.userHasVoted(up: myVote.Value == 1)
        } else {
            //This needs to be done because we're using dequeueReusableCellWithIdentifier, else all will be blue after first
            cell.defaultImage()
        }
        
        //Todo cleaner?
        if let parent = (parentViewController?.parentViewController as? RoomPageViewController) {
            cell.textLabel?.textColor = UIColor.blackColor()
            if question.CreatedById == parent.room?.CreatedById {
                cell.label.font = UIFont.boldSystemFontOfSize(15.0)
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let roomPageViewController = parentViewController?.parentViewController as! RoomPageViewController
        let questionPage = roomPageViewController.viewControllerAtIndex(1, createNew: false)! as! QuestionViewController
        questionPage.question = questions[indexPath.row]
        roomPageViewController.pageViewController.setViewControllers([questionPage], direction: .Forward, animated: true, completion: nil)
    }
    
}
