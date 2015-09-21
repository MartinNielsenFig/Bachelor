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
    var room: Room!
    
    var pageViewController: UIPageViewController!
    let pageCount = 3
    var currentPage = 0
    
    //https://www.veasoftware.com/tutorials/2015/4/2/uipageviewcontroller-in-swift-xcode-62-ios-82-tutorial
    override func viewDidLoad() {
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ask Question", style: .Plain, target: self, action: "addQuestion")
        
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
    }
    
    func addQuestion() {
        NSLog("add question pressed")
        performSegueWithIdentifier("CreateQuestion", sender: self)
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        currentPage = index
        if index == 0 {
            let questionListViewController = storyboard?.instantiateViewControllerWithIdentifier("QuestionListViewController") as! QuestionListViewController
            questionListViewController.roomId = self.room._id
            return questionListViewController
        }
        else if index == 1 {
            let currentQuestionViewController = storyboard?.instantiateViewControllerWithIdentifier("QuestionViewController") as! QuestionViewController
            currentQuestionViewController.roomId = self.room._id
            return currentQuestionViewController
        }
        else if index == 2 {
            let chatViewController = storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            chatViewController.roomId = self.room._id
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
        return currentPage
    }
}
