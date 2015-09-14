//
//  QuestionListViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class QuestionListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Paged {
    
    //Gets instantiated by RoomPageViewController
    var questions: [Question]?
    var room: Room?
    
    let pageIndex = 1
    @IBOutlet weak var questionsTableView: UITableView!
    
    func questionsDidLoad() {
        self.questions = (self.parentViewController as! RoomPageViewController).questions
        self.questionsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        
        questionsTableView.delegate = self
        questionsTableView.dataSource = self
    }
    
    //UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "QuestionCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let question = questions![indexPath.row]
        
        cell.textLabel?.text = question.QuestionText
        return cell
    }
    
}
