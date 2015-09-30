//
//  QuestionListViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

/// A sub-ViewController of RoomPageViewController. This shows the available questions for the room.
class QuestionListViewController: UITableViewController, Paged {
    
    //Properties
    let pageIndex = 0
    var roomId: String?
    var questions = [Question]() {
        didSet {
            filter(&self.questions)
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        }
    }
    
    //Utility
    /**
    Filters the questions in the room by concatenated up-/downvotes. So that upvotes are positive, and downvotes are negative.
    - parameter questions:	The questions array to be filtered in-place.
    */
    func filter(inout questions: [Question]) {
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
    
    //Lifetime
    override func viewDidLoad() {
        
        print("QuestionListViewController instantiated, roomId: \(self.roomId)")

        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        let loadingQuestion = Question()
        loadingQuestion.QuestionText = "Loading questions..."
        questions += [loadingQuestion]
        
        //Load questions for room
        updateQuestions()
    }
    
    func updateQuestions(refreshControl: UIRefreshControl? = nil) {
        //"Swift Trailing Closure" syntax
        let action = "Question/GetQuestionsForRoomWithoutImages?roomId=\(self.roomId!)"
        HttpHandler.requestWithResponse(action: action, type: "GET", body: "") { (data, response, error) -> Void in
            
            var tmpQuestions = [Question]()
            
            if let data = data, jsonArray = try? JSONSerializer.toArray(data) {
                for question in jsonArray {
                    tmpQuestions += [Question(jsonDictionary: question as! NSDictionary)]
                }
                
                self.questions.removeAll()
                
                if tmpQuestions.count <= 0 {
                    let q = Question()
                    q.QuestionText = "No questions for room"
                    q.CreatedById = "system"
                    tmpQuestions += [q]
                }
                
            } else {
                let qError = Question()
                qError.QuestionText = "Could not load questions"
                qError.CreatedById = "system"
                tmpQuestions += [qError]
            }
            self.questions += tmpQuestions
            refreshControl?.endRefreshing()
        }
    }
    
    //UITableViewController
    func handleRefresh(refreshControl: UIRefreshControl) {
        updateQuestions(refreshControl)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "QuestionCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! QuestionViewCell
        
        let question = questions[indexPath.row]
        cell.label.text = question.QuestionText
        
        
        let votesCount = upDownVotesCount(question)
        cell.upvoteCounter.text = String(votesCount.upvotes)
        cell.downvoteCounter.text = String(votesCount.downvotes)
        
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
        let questionPage = roomPageViewController.viewControllerAtIndex(1)! as! QuestionViewController
        questionPage.question = questions[indexPath.row]
        roomPageViewController.pageViewController.setViewControllers([questionPage], direction: .Forward, animated: true, completion: nil)
    }
    
}
