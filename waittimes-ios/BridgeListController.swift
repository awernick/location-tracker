//
//  BridgeListController.swift
//  
//
//  Created by Victor Fernandez on 9/3/15.
//
//

import SwiftyJSON
import MagicalRecord
import UIKit

class BridgeListController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var url = NSURL(string: "http://dev.waittimes.io:8080/api/v1/bridges")
    var loading = false
    var bridges: Array<Bridge> = []
    var session: NSURLSession = NSURLSession.sharedSession()
    
    func getBridges(){
        self.loading = true
        self.session.dataTaskWithURL(self.url!, completionHandler: {
                (data, response, errors) -> Void in
                    let json = JSON(data: data)
                    var bridgesJSON = json.arrayValue
                    self.bridges.removeAll(keepCapacity: true)
                    for bridgeJSON in bridgesJSON {
                        self.bridges.append(Bridge.createWithJSON(bridgeJSON))
                    }
                    self.loading = false
//                   Faults .MR_defaultContext().saveToPersistentStoreAndWait()
                    self.tableView.reloadData()
            }
        ).resume()
    }
    
    //Prepare for select action
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("preparing to change view with \(segue.identifier)")
        let bdController = segue.destinationViewController as? BridgeDetailViewController
        if let index = self.tableView.indexPathForSelectedRow() {
            let row = index.row
            bdController!.bridge = self.bridges[row]
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bridges.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getBridges()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bridgePreviewCell", forIndexPath: indexPath) as! UITableViewCell
        // Configure the cell...
        if indexPath.row < self.bridges.count {
            cell.textLabel?.text = self.bridges[indexPath.row].name
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
