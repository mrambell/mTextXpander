//
//  configViewController.swift
//  mTextXpander
//
//  Created by Mattia Rambelli (TS-DE) on 28/06/16.
//  Copyright © 2016 rms. All rights reserved.
//

import Cocoa

class configViewController: NSViewController {


    var localhandler = xmlHandler //bound to object's memory on mTextXpanderXMLHandling.swift to allow array binding.
    
    //add view controller for content adding elements
    let addElementViewController = AddElement(nibName: "AddElement", bundle: nil)
    let editElementViewController = EditElement(nibName: "EditElement", bundle: nil)
    
    //add view controller for editing elements
    
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var mainView: NSView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set table delegate
        tableView.setDelegate(self)
        
        //set table double click action
        tableView.doubleAction = #selector(configViewController.editSelectionOnTable)
        
        //load add abbreviation view
        addElementViewController?.loadView()
        editElementViewController?.loadView()
        
        
        
    }
    
    func editSelectionOnTable(){
        
        var mySelectedRows = [Int]()
        let tableViewFromNotification = tableView as NSTableView
        
        // In this example, the TableView allows multiple selection, but we have only one row so using mySelectedRows[0]
        let indexes = tableViewFromNotification.selectedRowIndexes
        var index = indexes.firstIndex
        while index != NSNotFound {
            mySelectedRows.append(index)
            index = indexes.indexGreaterThanIndex(index)
        }
        
        print(mySelectedRows[0])
        xmlHandler.abbreviationToBeDited = xmlHandler.data[mySelectedRows[0] as Int].ast
        xmlHandler.abbreviationToBeDitedIndex = mySelectedRows[0] as Int
        print(xmlHandler.abbreviationToBeDited)
        editElementViewController!.presentViewControllerAsModalWindow(editElementViewController!)

    }

    
    @IBAction func addXmlAbbreviation(sender: AnyObject) {
        addElementViewController!.presentViewControllerAsModalWindow(addElementViewController!)
        
    }
    
    @IBAction func removeXmlAbbr(sender: AnyObject) {
        
        //find index and use it for array
        
        var mySelectedRows = [Int]()
        let tableViewFromNotification = tableView as NSTableView
        
        // In this example, the TableView allows multiple selection, but we have only one row so using mySelectedRows[0]
        let indexes = tableViewFromNotification.selectedRowIndexes
        var index = indexes.firstIndex
        while index != NSNotFound {
            mySelectedRows.append(index)
            index = indexes.indexGreaterThanIndex(index)
        }
        
        print(mySelectedRows[0])
        print(xmlHandler.data[mySelectedRows[0] as Int].ast)
        xmlHandler.removeXmlAbbreviation(xmlHandler.data[mySelectedRows[0] as Int].ast)
        
    }
    
    
    
    @IBAction func quitApp(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    
    @IBAction func closeThisView(sender: NSButton) {
        sender.superview?.window?.setIsVisible(false)
        
    }

}




extension configViewController : NSTableViewDelegate {
    func tableViewSelectionDidChange(notification: NSNotification) {
        var mySelectedRows = [Int]()
        let myTableViewFromNotification = notification.object as! NSTableView
        // In this example, the TableView allows multiple selection
        let indexes = myTableViewFromNotification.selectedRowIndexes
        var index = indexes.firstIndex
        while index != NSNotFound {
            mySelectedRows.append(index)
            index = indexes.indexGreaterThanIndex(index)
        }
        //print(mySelectedRows)
        //currentSelection = mySelectedRows[0]
        //print(currentSelection)
    }
    
}
