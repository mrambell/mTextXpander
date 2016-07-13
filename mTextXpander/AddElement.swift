//
//  AddElement.swift
//  mTextXpander
//
//  Created by Mattia Rambelli (TS-DE) on 05/07/16.
//  Copyright © 2016 rms. All rights reserved.
//

import Cocoa

class AddElement: NSViewController {
    @IBOutlet weak var longTextScrollView: NSScrollView!

    @IBOutlet weak var shortTextField: NSTextField!
    
    
    var longTextField: NSTextView {
        get {
            return longTextScrollView.contentView.documentView as! NSTextView
        }
    }
    
    @IBAction func closeThisView(sender: AnyObject) {
        //let tmpcontroller:NSViewController! = self.presentingViewController
        self.view.window?.close()
        //self.dismissViewController(self)
        //self.dismissViewControllerAnimated(false, completion: {()->Void in
          //  println("done");
           // tmpController.dismissViewControllerAnimated(false, completion: nil);
        //});
    }
    @IBAction func addXMLElement(sender: AnyObject) {
        xmlHandler.addXmlAbbreviation(shortTextField.stringValue, longtext: longTextField.string!)
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
    
}
