//
//  LogLift.swift
//  logU
//
//  Created by Brett Alcox on 2/4/16.
//  Copyright © 2016 Brett Alcox. All rights reserved.
//

import UIKit
import Eureka

var shouldUpdateDash: Bool = false
var shouldUpdatePoundage: Bool = false
var shouldUpdateSquat: Bool = false
var shouldUpdateBench: Bool = false
var shouldUpdateDeadlift: Bool = false
var shouldUpdateMax: Bool = true
var shouldUpdateWeek: Bool = true
var shouldUpdateSettings: Bool = false


var theDate:String?
var lift:String?
var set:String?
var rep:String?
var weight:String?

class LogLift: FormViewController {
    
    let url_to_request:String = "https://loguapp.com/swift.php"
    let url_to_post:String = "https://loguapp.com/swift2.php"
    
    @IBOutlet weak var logButton: UIBarButtonItem!
    
    @IBAction func logPressed(sender: UIBarButtonItem) {
        
            }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("New Lift")
            <<< DateInlineRow("Date"){
                $0.title = "Date"
                $0.value = NSDate()
                
            }
            <<< PickerInlineRow<String>("Lift") { (row : PickerInlineRow<String>) -> Void in
                
                row.title = "Lift"
                row.options = ["Squat", "Pause Squat", "Front Squat", "Bench", "Close Grip Bench", "Incline Bench", "Pause Bench", "Floor Press", "Deadlift", "Deficit Deadlift", "Pause Deadlift", "Snatch Grip Deadlift", "Overhead Press", "Sots Press", "Pullups", "Dips", "Bent Over Rows", "Kroc Rows", "Straight Bar Bicep Curls", "EZ Bar Bicep Curls", "Barbell Bicep Curls", "Snatch", "Clean and Jerk", "Power Clean", "Power Snatch", "Hang Clean", "Hang Snatch"]
                row.value = row.options[0]
            }
            
            <<< TextRow("Sets") {
                $0.title = "Sets"
                set = $0.value
            }
            <<< TextRow("Reps") {
                $0.title = "Reps"
                rep = $0.value
            }
            <<< TextRow("Weight") {
                $0.title = "Weight"
                weight = $0.value
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        shouldUpdateDash = true
        shouldUpdatePoundage = true
        shouldUpdateSquat = true
        shouldUpdateBench = true
        shouldUpdateDeadlift = true
        shouldUpdateMax = true
        shouldUpdateWeek = true
        
        if logButton === sender {
            
            if Reachability.isConnectedToNetwork() {
                
                let tits = (form.values()["Date"]!)! as! NSDate
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-M-d HH:mm:ss Z"
                
                let date = dateFormatter.dateFromString(String(tits))!
                
                dateFormatter.dateFormat = "M/d/yyyy"
                
                let formattedDateString = dateFormatter.stringFromDate(date)
                
                if (form.values()["Sets"]! == nil || form.values()["Reps"]! == nil || form.values()["Weight"]! == nil) {
                    let actionSheetController: UIAlertController = UIAlertController(title: "Logging Failed", message: "Please fill out all fields!", preferredStyle: .Alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Dismiss", style: .Cancel) { action -> Void in
                        //Do some stuff
                    }
                    actionSheetController.addAction(cancelAction)
                    self.presentViewController(actionSheetController, animated: true, completion: nil)
                } else {
                    theDate = formattedDateString
                    lift = String((form.values()["Lift"]!)!)
                    set = String((form.values()["Sets"]!)!)
                    rep = String((form.values()["Reps"]!)!)
                    weight = String((form.values()["Weight"]!)!)
                    
                    print(theDate, lift!, set!, rep!, weight!)
                    upload_request()

                }

            }
            
            if !Reachability.isConnectedToNetwork() {
                OfflineRequest.coreDataInsert(theDate!, lift: lift!, sets: set!, reps: rep!, weight: weight!)
                
                DashTableViewController().OfflineTableInsert(theDate!, lift: lift!, set: set!, rep: rep!, weight: weight!)
            }
        }
    }

    
    func upload_request()
    {
        let url:NSURL = NSURL(string: url_to_post)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let query = "name=\(NSUserDefaults.standardUserDefaults().valueForKey("USERNAME")!)&date=\(theDate!)&lift=\(lift!)&sets=\(set!)&reps=\(rep!)&weight=\(weight!)".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.uploadTaskWithRequest(request, fromData: query, completionHandler:
            {(data,response,error) in
                
                guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                
                let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(dataString)
            }
        );
        
        task.resume()
        
    }


}
