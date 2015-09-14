//
//  RoomPageViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

class RoomPageViewController: UIViewController, UIPageViewControllerDataSource {
    
    //Gets instantiated by previous caller
    var room: Room? = nil
    
    //Callback instantiated
    var questions = [Question]()
    
    var pageViewController: UIPageViewController!
    let pageCount = 3
    
    //https://www.veasoftware.com/tutorials/2015/4/2/uipageviewcontroller-in-swift-xcode-62-ios-82-tutorial
    override func viewDidLoad() {
        
        //Setup the page view controller
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.dataSource = self
        
        //Set initial page
        let startVC = viewControllerAtIndex(0)!
        pageViewController.setViewControllers([startVC], direction: .Forward, animated: true, completion: nil)
        pageViewController.view.frame = CGRect(x: 0, y: 30, width: view.frame.size.width, height: view.frame.size.height - 30)
        
        //Add it to the current viewcontroller
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
        
        //Load questions for room
        HttpHandler.getQuestions(room?._id, completionHandler: { (inout questions: [Question]) -> Void in
            self.questions += questions
        })
    }
    
    
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        if index == 0 {
            let currentQuestionViewController = storyboard?.instantiateViewControllerWithIdentifier("QuestionViewController") as! QuestionViewController
            currentQuestionViewController.questions = self.questions
            return currentQuestionViewController
        }
        else if index == 1 {
            let questionListViewController = storyboard?.instantiateViewControllerWithIdentifier("QuestionListViewController") as! QuestionListViewController
            questionListViewController.questions = self.questions
            return questionListViewController
        }
        else if index == 2 {
            let chatViewController = storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            chatViewController.questions = self.questions
            return chatViewController
        }
        
        return nil
    }
    
    //UIPageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let pagedVC = viewController as? Paged {
            var index = pagedVC.pageIndex
            return self.viewControllerAtIndex(--index)
        }
        else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let pagedVC = viewController as? Paged {
            var index = pagedVC.pageIndex
            return self.viewControllerAtIndex(++index)
        }
        else {
            return nil
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageCount
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
