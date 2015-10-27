//
//  RoomPageViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit

/// Container for the Room view. This ViewController basically has three sub-viewcontrollers: QuestionViewController, ChatViewController and QuestionListViewController. It enables the user to slide between these three views with a finger-flick. The implementation of this ViewController is influenced by this guide: https://www.veasoftware.com/tutorials/2015/4/2/uipageviewcontroller-in-swift-xcode-62-ios-82-tutorial
class RoomPageViewController: UIViewController, UIPageViewControllerDataSource {
    
    //MARK: Properties
    //Gets instantiated by previous caller
    var room: Room!
    var pageViewController: UIPageViewController!
    let pageCount = 3
    var currentPage = 0
    
    var viewControllerArray = [UIViewController?](count: 3, repeatedValue: nil)
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        
        self.title = room.Name
        
        print("RoomPageViewController instantiated with roomId \(room._id)")
        
        //http://stackoverflow.com/questions/18844681/how-to-make-custom-uibarbuttonitem-with-image-and-label
        let askQBtn = UIButton(type: .Custom)
        askQBtn.setImage(UIImage(named: "AskQuestion"), forState: .Normal)
        askQBtn.addTarget(self, action: "addQuestion", forControlEvents: .TouchUpInside)
        askQBtn.frame = CGRectMake(0, 0, 22, 22)
        /*let askQLabel = UILabel(frame: CGRectMake(-10, -10, 50, 20))
        askQLabel.text = "Ask"
        askQLabel.font = UIFont(name: "Arial-BoldMT", size: 13)
        askQLabel.textColor = UIColor(red: 52, green: 152, blue: 219, alpha: 0)
        askQLabel.textAlignment = .Center
        askQLabel.backgroundColor = UIColor.clearColor()
        askQBtn.addSubview(askQLabel)*/
        let askQBarBtn = UIBarButtonItem(customView: askQBtn)
        navigationItem.rightBarButtonItem = askQBarBtn
        
        //Handle back button on UINavigation Bar
        let exitBtn = UIButton(type: .Custom)
        exitBtn.setImage(UIImage(named: "Exit"), forState: .Normal)
        exitBtn.addTarget(self, action: "logoutRoom", forControlEvents: .TouchUpInside)
        exitBtn.frame = CGRectMake(0, 0, 22, 22)
        let exitRoomBtn = UIBarButtonItem(customView: exitBtn)
        self.navigationItem.leftBarButtonItem = exitRoomBtn
        
        //Setup the page view controller
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.dataSource = self
        
        //Set initial page
        let startVC = viewControllerAtIndex(0, createNew: true)!
        pageViewController.setViewControllers([startVC], direction: .Forward, animated: true, completion: nil)
        makeRoomForNavigationBar(orientationIsLandscape: !UIApplication.sharedApplication().statusBarOrientation.isLandscape)   //this is odd, but works
        
        //Add it to the current viewcontroller
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    /**
    Makes sure there's room enough for the navigation bar when presenting the sub-views. Needs a little offset when in landscape mode.
    - parameter orientationIsLandscape:	Indicates the orientation of the device.
    */
    func makeRoomForNavigationBar(orientationIsLandscape orientationIsLandscape: Bool) {
        let offset = orientationIsLandscape ? CGFloat(16) : CGFloat(0)
        let cellHeight = self.navigationController!.navigationBar.frame.size.height + offset
        pageViewController.view.frame = CGRect(x: 0, y: cellHeight, width: view.frame.size.width, height: view.frame.size.height - cellHeight)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        makeRoomForNavigationBar(orientationIsLandscape: fromInterfaceOrientation.isLandscape)
    }
    
    //MARK: Navigation
    func logoutRoom() {
        let alert = UIAlertController(title: "Leaving Room", message: "Do you want to leave current room?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            //Do nothing
        }))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .Default, handler: { action in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func addQuestion() {
        NSLog("add question pressed")
        performSegueWithIdentifier("CreateQuestion", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateQuestion" {
            let createQuestionViewController = segue.destinationViewController as! CreateQuestionViewController
            createQuestionViewController.room = self.room
            createQuestionViewController.previousNavigationController = self.navigationController
            //assert(false)   //Todo check if ok
        }

    }
    
    //MARK: Utilities
    /**
    Helper function for UIPageViewControllerDataSource. Returns the ViewController at a specific index. Initiates the roomId parameter.
    - parameter index:	The index of the viewcontroller.
    - returns: Returns the UIViewController at a specific location on the UIPageViewController
    */
    func viewControllerAtIndex(i: Int, createNew: Bool) -> UIViewController? {
        
        //You might wonder why viewController[i] isn't thrown into a variable, cast it to Paged and assign room._id and return it, but there's always the case of i < 0 || i > pageCount-1 which you would have to check, as well as assigning the viewController[i] array field to the correct VC is nice to have verbose imo.
        
        currentPage = i
        if i == 0 {
            if viewControllerArray[i] == nil || createNew {
                viewControllerArray[i] = storyboard?.instantiateViewControllerWithIdentifier("QuestionListViewController") as! QuestionListViewController
            }
            (viewControllerArray[i] as! QuestionListViewController).roomId = self.room._id
            return viewControllerArray[i]
        }
        else if i == 1 {
            if viewControllerArray[i] == nil || createNew {
                viewControllerArray[i] = storyboard?.instantiateViewControllerWithIdentifier("QuestionViewController") as! QuestionViewController
            }
            (viewControllerArray[i] as! QuestionViewController).roomId = self.room._id
            return viewControllerArray[i]
        }
        else if i == 2 {
            if viewControllerArray[i] == nil || createNew {
                viewControllerArray[i] = storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
            }
            (viewControllerArray[i] as! ChatViewController).roomId = self.room._id
            return viewControllerArray[i]
        }
        
        return nil
    }
    
    //MARK: UIPageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let pagedVC = viewController as? Paged {
            var index = pagedVC.pageIndex
            return self.viewControllerAtIndex(--index, createNew: false)
        }
        else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let pagedVC = viewController as? Paged {
            var index = pagedVC.pageIndex
            return self.viewControllerAtIndex(++index, createNew: false)
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
