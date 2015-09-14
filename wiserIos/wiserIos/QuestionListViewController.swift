//
//  QuestionListViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class QuestionListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Paged {
    
    let pageIndex = 1
    var roomId = String()
    
    var questions = [Question]()
    
    @IBOutlet weak var questionsTableView: UITableView!
    
    override func viewDidLoad() {
        questionsTableView.delegate = self
        questionsTableView.dataSource = self
        
        //Load questions for room
        HttpHandler.getQuestions(roomId, completionHandler: { (inout questions: [Question]) -> Void in
            self.questions += questions
            
            dispatch_async(dispatch_get_main_queue(), {
                self.questionsTableView.reloadData()
            })
        })
    }
    
    //UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "QuestionCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let question = questions[indexPath.row]
        
        cell.textLabel?.text = question.QuestionText
        return cell
    }
    
}
