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
    var loading = false
    var bridges: Array<Bridge> = []
    /**
    * getBridges
    *
    * Gets the bridges from the server and sets the appropriate 
    * variables in the view controller for the table like loading,
    * bridges, and reloads table view
    *
    */
    func getBridges(){
        self.loading = true
        Bridge.GetAllBridges(bridgeReceiver: {
            (bridgeArray: [Bridge]) -> Void in
                self.bridges = bridgeArray
                self.loading = false
                self.tableView.reloadData()
        })
    }
    
    /**
    * prepareForSegue
    *
    * Whenever any of the tables rows are clicked this method will be
    * called and it will get the index of the row that was clicked so
    * that we may send the object to the bridge detail view controller.
    *
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("preparing to change view with \(segue.identifier)")
        let bdController = segue.destinationViewController as? BridgeDetailViewController
        if let index = self.tableView.indexPathForSelectedRow() {
            let row = index.row
            bdController!.id = self.bridges[row].getID()
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
    /**
    * tableView
    *
    * Gets the bridge for the given index and sets the title of
    * a cell that is allocated and returned to the table view.
    *
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bridgePreviewCell", forIndexPath: indexPath) as! UITableViewCell
        // Configure the cell
        if indexPath.row < self.bridges.count {
            cell.textLabel?.text = self.bridges[indexPath.row].getName()
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
