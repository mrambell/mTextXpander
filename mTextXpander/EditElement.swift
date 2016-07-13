//
//  AddElement.swift
//  mTextXpander
//
//  Created by Mattia Rambelli (TS-DE) on 05/07/16.
//  Copyright © 2016 rms. All rights reserved.
//

import Cocoa

class EditElement: NSViewController {
    @IBOutlet weak var longTextScrollView: NSScrollView!

    @IBOutlet weak var shortTextField: NSTextField!
    
    var longTextField: NSTextView {
        get {
            return longTextScrollView.contentView.documentView as! NSTextView
        }
    }
    
    //register initial value
    
    @IBAction func closeThisView(sender: AnyObject) {
        
        self.view.window?.close()
        xmlHandler.abbreviationToBeDited = ""
        xmlHandler.abbreviationToBeDitedIndex = -1
        
    }
    @IBAction func addXMLElement(sender: AnyObject) {
        xmlHandler.removeXmlAbbreviation(xmlHandler.abbreviationToBeDited)
        xmlHandler.addXmlAbbreviation(shortTextField.stringValue, longtext: longTextField.string!)
        xmlHandler.abbreviationToBeDited = ""
        xmlHandler.abbreviationToBeDitedIndex = -1
        self.view.window?.close()
        shortTextField.stringValue = ""
        longTextField.string! = ""
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.window?.makeKeyAndOrderFront(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    override func viewDidAppear() {
        shortTextField.stringValue = xmlHandler.abbreviationToBeDited
        longTextField.string! = (xmlHandler.xml["xml"]["abbreviation"][xmlHandler.abbreviationToBeDitedIndex]["longtext"].element!.text!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        print(xmlHandler.xml["xml"]["abbreviation"][xmlHandler.abbreviationToBeDitedIndex]["longtext"].element!.text!)
    }
}
