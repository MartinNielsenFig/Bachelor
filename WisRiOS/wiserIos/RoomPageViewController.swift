//
//  RoomPageViewController.swift
//  wiserIos
//
//  Created by Peter Helstrup Jensen on 10/09/2015.
//  Copyright © 2015 Peter Helstrup Jensen. All rights reserved.
//

import UIKit
import JsonSerializerSwift

/// Container for the Room view. This ViewController has three sub-viewcontrollers: QuestionViewController, ChatViewController and QuestionListViewController. It enables the user to slide between these three views with a finger-flick. The implementation of this ViewController is influenced by this guide: https://www.veasoftware.com/tutorials/2015/4/2/uipageviewcontroller-in-swift-xcode-62-ios-82-tutorial
class RoomPageViewController: UIViewController, UIPageViewControllerDataSource {
    
    //MARK: Properties
    
    /// The room that was chosen on the previous Room list. RoomPageViewController representes this Room
    var room: Room!
    /// A reference to a UIPageViewController used to display a paged view.
    var pageViewController: UIPageViewController!
    /// Number of pages represented by UIPageViewController, can be subtracted by 1 if chat is not present.
    var pageCount = 3
    /// Keeps track on index of the current page being represented.
    var currentPage = 0
    /// An updater that can continually poll whether the room still exists, else log out.
    var checkRoomExistsUpdater: Updater?
    /// Array of the viewControllers representing the pages inside the UIPageViewController
    var viewControllerArray = [UIViewController?](count: 3, repeatedValue: nil)
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        print("RoomPageViewController instantiated with roomId \(room._id)")
        
        //Disable chat?
        if !room.HasChat! {
            pageCount = 2
        }
        
        //Title for users, room owner sees an edit button
        if let myId = CurrentUser.sharedInstance._id where self.room.CreatedById == myId {
            let editbtnContainer = UIView(frame: CGRectMake(0, 0, 44, 44))
            editbtnContainer.backgroundColor = UIColor.clearColor()
            let btn = UIButton(type: .DetailDisclosure)
            btn.frame = CGRectMake(0, 0, 44, 44)
            btn.addTarget(self, action: "editRoom", forControlEvents: .TouchUpInside)
            editbtnContainer.addSubview(btn)
            self.navigationItem.titleView = editbtnContainer
            
        } else {
            self.title = room.Name
        }
        
        //Ask button
        //http://stackoverflow.com/questions/18844681/how-to-make-custom-uibarbuttonitem-with-image-and-label
        let askQBtn = UIButton(type: .Custom)
        askQBtn.setImage(UIImage(named: "AskQuestion"), forState: .Normal)
        askQBtn.addTarget(self, action: "addQuestion", forControlEvents: .TouchUpInside)
        askQBtn.frame = CGRectMake(0, 0, 22, 22)
        let askQBarBtn = UIBarButtonItem(customView: askQBtn)
        navigationItem.rightBarButtonItem = askQBarBtn
        
        //Handle exit button on UINavigation Bar
        let exitBtn = UIButton(type: .Custom)
        exitBtn.setImage(UIImage(named: "Exit"), forState: .Normal)
        exitBtn.addTarget(self, action: "logoutRoomGracefully", forControlEvents: .TouchUpInside)
        exitBtn.frame = CGRectMake(0, 0, 22, 22)
        let exitRoomBtn = UIBarButtonItem(customView: exitBtn)
        self.navigationItem.leftBarButtonItem = exitRoomBtn
        
        //Setup the page view controller
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController.dataSource = self
        
        //Set initial page
        let startVC = viewControllerAtIndex(0, createNew: true)!
        pageViewController.setViewControllers([startVC], direction: .Forward, animated: true, completion: nil)
        makeRoomForNavigationBar(orientationIsLandscape: !UIApplication.sharedApplication().statusBarOrientation.isLandscape)   //logic seems to be inverted, bug?
        
        //Add it to the current viewcontroller
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //Check if room exists, else log out
        checkRoomExistsUpdater = Updater(secondsDelay: 30, function: {
            () -> Void in
            print("updater check room exist")
            let body = "roomId=\(self.room._id!)"
            HttpHandler.requestWithResponse(action: "Room/RoomExists", type: "POST", body: body) {
                (notification, response, error) in
                
                if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                    if let data = notification.Data where data.lowercaseString == "false" {
                        self.checkRoomExistsUpdater?.stop()
                        self.logoutRoom(true)
                    }
                } else {
                    print("error in checking if room exists")
                    print(notification.Errors)
                }
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        checkRoomExistsUpdater?.stop()
    }
    
    //MARK: Rotation
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        makeRoomForNavigationBar(orientationIsLandscape: fromInterfaceOrientation.isLandscape)
    }
    
    /**
     Makes sure there's room enough for the navigation bar when presenting the sub-views. Needs a little offset when in landscape mode, and is dependent on Device type (phone vs pad).
     
     - parameter orientationIsLandscape:	Indicates the orientation of the device.
     */
    func makeRoomForNavigationBar(orientationIsLandscape orientationIsLandscape: Bool) {
        
        var offset = CGFloat(0)
        if orientationIsLandscape || UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            offset = CGFloat(24)
        }
        let cellHeight = self.navigationController!.navigationBar.frame.size.height + offset
        pageViewController.view.frame = CGRect(x: 0, y: cellHeight, width: view.frame.size.width, height: view.frame.size.height - cellHeight)
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateQuestion" {
            let createQuestionViewController = ((segue.destinationViewController as! UINavigationController).topViewController) as! CreateQuestionViewController
            createQuestionViewController.questionListViewController = viewControllerAtIndex(0, createNew: false) as! QuestionListViewController
            createQuestionViewController.room = self.room
            
            if let oldQuestion = sender as? Question {
                createQuestionViewController.oldQuestion = oldQuestion
            }
        }
        
    }
    
    /**
    Log out of the room.
     
    - parameter forced:	If forced is true, the logout will be forced and the user will not be able to cancel.
    */
    func logoutRoom(forced: Bool = false) {
        
        let leavingTitle = NSLocalizedString("Leaving Room", comment: "")
        let leavingComment = NSLocalizedString("Do you want to leave room?", comment: "")
        let forcedTitle = NSLocalizedString("Logged out", comment: "")
        let forcedComment = NSLocalizedString("The room was deleted", comment: "")
        
        let alert = UIAlertController(title: forced ? forcedTitle : leavingTitle, message: forced ? forcedComment : leavingComment, preferredStyle: .Alert)
        
        if !forced {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: { action in
                //Do nothing
            }))
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Logout", comment: ""), style: .Default, handler: { action in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
     This function simply asks user to log out or not.
     */
    func logoutRoomGracefully() {
        logoutRoom(false)
    }
    
    func addQuestion() {
        NSLog("add question pressed")
        performSegueWithIdentifier("CreateQuestion", sender: self)
        
    }
    
    func editQuestion(oldQuestion: Question) {
        performSegueWithIdentifier("CreateQuestion", sender: oldQuestion)
    }
    
    //MARK: Utilities
    
    /**
    Shows information for the room and enables the user to update the location of the room. The location is assumed to be the same as collected by the start screen.
    */
    func editRoom() {
        print("edit room called")
        
        let message = String(format: NSLocalizedString("Name of room: %@\nSecret of room: %@", comment: ""), self.room.Name!, self.room.Secret!)
        
        //Build alert
        let alert = UIAlertController(title: NSLocalizedString("Room Information", comment: ""), message: message, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default, handler: { (action) in
            //do nothing
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Update Location", comment: ""), style: .Destructive, handler: { (action) in
            
            let location = Coordinate()
            location.AccuracyMeters = CurrentUser.sharedInstance.location.AccuracyMeters
            location.Latitude = CurrentUser.sharedInstance.location.Latitude
            location.Longitude = CurrentUser.sharedInstance.location.Longitude
            let locationJson = JSONSerializer.toJson(location)
            
            let body = "id=\(self.room._id!)&location=\(locationJson)"
            HttpHandler.requestWithResponse(action: "Room/UpdateLocation", type: "POST", body: body, completionHandler: {
                (notification, response, error) in
                
                if notification.ErrorType == .Ok || notification.ErrorType == .OkWithError {
                    self.room.Location.AccuracyMeters = CurrentUser.sharedInstance.location.AccuracyMeters
                    self.room.Location.Latitude = CurrentUser.sharedInstance.location.Latitude
                    self.room.Location.Longitude = CurrentUser.sharedInstance.location.Longitude
                    
                    Toast.showToast(NSLocalizedString("Location updated.", comment: ""), durationMs: 2000, presenter: self)
                } else {
                    Toast.showOkToast(NSLocalizedString("Error", comment: ""),
                        message: NSLocalizedString("Could not update room location", comment: ""), presenter: self)
                }
            })
        }))

        //http://stackoverflow.com/questions/25759885/uiactionsheet-from-popover-with-ios8-gm
        //iPad support
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
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
        else if i == 2 && room.HasChat! {
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
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let pagedVC = viewController as? Paged {
            var index = pagedVC.pageIndex
            return self.viewControllerAtIndex(++index, createNew: false)
        } else {
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
