//
//  mTextXpanderXMLHandling.swift
//  mTextXpander
//
//  Created by Mattia Rambelli (TS-DE) on 05/07/16.
//  Copyright © 2016 rms. All rights reserved.
//

import Foundation
import SWXMLHash

class abbreviationClass : NSObject {
    //aShortText - which is the abbreviation
    var ast:String
    //aLongText - which is the long text to sobstitute the short one
    var alt:String
    init(ast:String, alt:String) {
        self.ast = ast
        self.alt = alt
        super.init()
    }
}

class mTXXMLHandler : NSObject {
    dynamic var data:[abbreviationClass]
    var loadedXml = String()
    var xml = SWXMLHash.parse("")
    
    //for editing, record text being edited to assert if editing on the doubleclick
    var abbreviationToBeDited:String = ""
    //index for the same usage: editing
    var abbreviationToBeDitedIndex = -1
    
    func loadData()
    {
        //called by presentData.
        //xml file location and name
        let file = "/xpand.xml"
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) {
            let dir = dirs[0] //documents directory
            let path = dir.stringByAppendingString(file)
            do {
                self.loadedXml = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
                //print(xmlAbbr)
                }
            catch {
                print("no file found or cannot open file at\(path)")
                //try to recreate file maybe later
                do {
                    let initialText = "<xml>"
                        + "<abbreviation>"
                        + "<shorttext>"
                        + "hai"
                        + "</shorttext>"
                        + "<longtext>"
                        + "Hello World."
                        + "</longtext>"
                        + "</abbreviation>"
                        + "</xml>"
                    try initialText.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
                }
                catch {/* error handling here */
                    
                }
                
                
            }
        }
        
        
    }

    
    func presentData(){
        //var tdata:NSMutableArray = [""]
        //the table binds to data array!!! present just fills the array to control the table.
        
        
        //load xml and print it just in case
        self.loadData()
        
        //print(loadedXml)
        self.xml = SWXMLHash.parse(self.loadedXml as String)
        
        //print(xml["xml"]["abbreviation"]["shorttext"][0].element!.text!)
        
        for child in xml["xml"].children {
            
            //let astPH2 = (child["shorttext"].element!.text!).stringByReplacingOccurrencesOfString("\t", withString: "").stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
            let ast = (child["shorttext"].element!.text!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            let alt = (child["longtext"].element!.text!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            self.data.append(abbreviationClass(ast: (ast as String), alt: (alt as String)))
            
        }
        
    }
    
    func addXmlAbbreviation(shorttext:String, longtext:String){
        
        //control: no shorttext in array!
        
        var flagShortTextPresent = false
        
        for child in self.xml["xml"].children {
            if shorttext == child["shorttext"].element!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                flagShortTextPresent = true
            }
        }
        
        if !flagShortTextPresent {
        
            let newAbbr = "<abbreviation>\n"
                + "<shorttext>\n"
                + "\(shorttext)\n"
                + "</shorttext>\n"
                + "<longtext>\n"
                + "\(longtext)\n"
                + "</longtext>\n"
                + "</abbreviation>\n"
            
            var newXML = "<xml>\n"
            for child in self.xml["xml"].children {
                newXML = newXML + "<abbreviation>\n"
                newXML = newXML + "<shorttext>\n"
                newXML = newXML + child["shorttext"].element!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                newXML = newXML + "\n</shorttext>\n"
                newXML = newXML + "<longtext>\n"
                newXML = newXML + child["longtext"].element!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                newXML = newXML + "\n</longtext>\n"
                newXML = newXML + "</abbreviation>\n"
        }
        newXML += newAbbr
        newXML += "</xml>"
        
        self.writeData(newXML)
        self.data.removeAll()
        self.presentData()
        }
        
    }
    
    func writeData(xmlData:String){
        let file = "/xpand.xml"
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) {
            let dir = dirs[0] //documents directory
            let path = dir.stringByAppendingString(file)
            do {
                try xmlData.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {
            }
        }
    }
    
    func removeXmlAbbreviation(shorttext:String){
        
        var newXML = "<xml>\n"
        for child in self.xml["xml"].children {
            if shorttext != child["shorttext"].element!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            newXML = newXML + "<abbreviation>\n"
            newXML = newXML + "<shorttext>\n"
            newXML = newXML + child["shorttext"].element!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            newXML = newXML + "\n</shorttext>\n"
            newXML = newXML + "<longtext>\n"
            newXML = newXML + child["longtext"].element!.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            newXML = newXML + "\n</longtext>\n"
            newXML = newXML + "</abbreviation>\n"
            }
        }
        newXML += "</xml>"
        
        self.writeData(newXML)
        self.data.removeAll()
        self.presentData()
        
    }
    func editAbbreviation(shorttext:String){
        
        //the control here is, if self.abbreviationToBeDited = "" then we are not editing anything.
        //what we do in NSTableVire double click is to set this value, and on edit view save button delete abbr for this value and commit save
        //then, we need to call xmlhandler.abbreviationToBeEdited="" again for control from the edit view
        abbreviationToBeDited = shorttext
        
    }
    
    override init() {
        self.data = [abbreviationClass]()
        super.init()
        self.presentData()
    }
    
}

var xmlHandler = mTXXMLHandler()