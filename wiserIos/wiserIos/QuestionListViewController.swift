//
//  QuestionListViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class QuestionListViewController: UIViewController, Paged {
    
    //Gets instantiated
    var room: Room? = nil
    
    let pageIndex = 1
    
    override func viewDidLoad() {
        HttpHandler.getQuestions(
            {
                newQuestions in
                for q in newQuestions {
                    print(q)
                }
            }, roomId: room?._id)
    }
}
