//
//  AppDelegate.swift
//  mTextXpander
//
//  Created by Mattia Rambelli (TS-DE) on 28/06/16.
//  Copyright © 2016 rms. All rights reserved.
//

import Cocoa
import SWXMLHash
import ApplicationServices
import Carbon
import Foundation
import CoreGraphics


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!

    let popover = NSPopover()
    var eventMonitor:EventMonitor?

 
    //we need our buffer...
    //var stringBuffer:[UInt16] = []
    var stringBuffer:String = ""
    //I'd like to mark when I am typing...
    //we monitor that inside self.handleBuffer and deactivate the function if it is set to true.
    var autoTypingFlag:Bool=false
    
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        
        
        //start listener
        acquirePrivileges()
        //start listening to NSEvents
        NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: {(event: NSEvent) in
            //handleBuffer is the function which actually does everything
            //self.handleBuffer starts only if we are not committing an auto type.
            if !self.autoTypingFlag {
                self.handleBuffer(event)
            }
        })
        
        //add an event tap to SEND keyboard events!
                //end of declarations to run event tap for char writing. lets test it shall we
        
        if let button = statusItem.button {
            button.image = NSImage(named: "IconStatus")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        popover.contentViewController = configViewController(nibName: "configViewController", bundle: nil)
        
        
        eventMonitor = EventMonitor(mask: [NSEventMask.LeftMouseDownMask, NSEventMask.RightMouseDownMask]) { [unowned self] event in
            if self.popover.shown {
                self.closePopover(event)
            }
        }
        

    }
    

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        
    }
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    
    //popover toggle code
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    func acquirePrivileges() -> Bool {
        let accessEnabled = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true])
        if accessEnabled != true {
            print("please enable the app on System Preferences -> Security and Privacy -> Accessibility.")
        }
        return accessEnabled
    }
    func handleBuffer(theEvent: NSEvent) {
        
        //let pressedKey = convertKeyCode(theEvent.keyCode)
        print(theEvent.keyCode)
        
        //evaluate if space or tab is pressed. that is our actuator to check and start replacing routine.
        //evaluate pressed key func does just that.
        //we need to ensure that string is not empty as well.
        
        if evaluatePressedKey(theEvent.keyCode) {
            if (theEvent.keyCode == 48 || theEvent.keyCode == 49 ) {
                if stringBuffer != ""
                {
                    print("replace event!!!")
                    autoTypingFlag=true
                    print(stringBuffer)
                    typeLongText(theEvent)
                    //add a way to write with keyboard pliz
                    //func write stuff from xml if shorttext matches!
                    //then empty buffer
                    stringBuffer = ""
                    autoTypingFlag=false
                }
            }
            else {
                stringBuffer += convertKeyCode(theEvent.keyCode)
                print(stringBuffer)
            }
        }
        else {
            stringBuffer = ""
        }
        
    }
    
    func typeLongText(theEvent: NSEvent) {
        //not bothering with buffer control right now...
        //try to simulate a keyboard press that updates background app
        //println("key down is \(event.keyCode)");
        
        //get tap location and register delete keyboardEvent
        
        let eventTapLocation : CGEventTapLocation = CGEventTapLocation(rawValue: 0)!
        let deleteEvent = CGEventCreateKeyboardEvent(nil, CGKeyCode(51), true)
        
        

        //example post:
        //CGEventPost(eventTapLocation, deleteEvent)
        //send a delete for every char in buffer if buffer equals some item inside the xml
        for element in xmlHandler.data
        {
            if element.ast == stringBuffer {
                //empty buffer, delete all the elements written by sending keycode 51
                //then send a keycode for each character found on longtext, element.alt
                for _ in stringBuffer.characters {
                    CGEventPost(eventTapLocation, deleteEvent)
                }
                //deletes only n-1 letters so need to delete another
                CGEventPost(eventTapLocation, deleteEvent)
                //then lets convert string into array of unichar and start writing
                //let chars: [unichar] = Array(element.alt.utf16)
                for altChar in element.alt.characters {
                    
                    
                    print(element.alt)
                    let lowercaseEval = String(altChar).lowercaseString
                    let evalOriginalString = String(altChar)
                    
                    let whitespaceEvaluator = evalOriginalString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    if !whitespaceEvaluator.isEmpty
                    {
                    
                        if lowercaseEval == evalOriginalString
                        {
                            //char which is not newline and not uppercase
                            let loc1 : CGEventTapLocation = CGEventTapLocation(rawValue: 0)!
                            //all good to go
                            //send the event first down key then up
                            let writeCharEventDown = CGEventCreateKeyboardEvent(nil, convertCharToKeyCode(altChar),true)! //down key
                            let writeCharEventUp = CGEventCreateKeyboardEvent(nil, convertCharToKeyCode(String(altChar).lowercaseString.characters.first!),false)! //up key
                            CGEventPost(eventTapLocation, writeCharEventDown)
                            CGEventPost(eventTapLocation, writeCharEventUp)
                            
                            
                        }
                        else{
                            
                            let loc2 : CGEventTapLocation = CGEventTapLocation(rawValue: 0)!
                            
                            //we have an uppercase char
                            //set shift flag or directly press shift
                            //lets simulate anyway shift up
                            
                            //shift down event
                            let shiftDown = CGEventCreateKeyboardEvent(nil, CGKeyCode(56), true)
                            //shift up event
                            let shiftUp = CGEventCreateKeyboardEvent(nil, CGKeyCode(56), false)
                            
                            //keydown event
                            let writeUpcaseCharEventDown = CGEventCreateKeyboardEvent(nil, convertCharToKeyCode(String(altChar).lowercaseString.characters.first!),true)! //down key
                            //key up event
                            let writeUpcaseCharEventUp = CGEventCreateKeyboardEvent(nil, convertCharToKeyCode(String(altChar).lowercaseString.characters.first!),false)! //up key
                            
                            //set char mask to shiftdown? cannot make upcase stuff so must be imo
                            //CGEventSetFlags(writeUpcaseCharEventDown, CGEventFlags.MaskAlphaShift)
                            //CGEventSetFlags(writeUpcaseCharEventDown, CGEventFlags.MaskShift)
                            //CGEventSetFlags(writeUpcaseCharEventDown, CGEventFlags.MaskShift)
                            
                            //set shift down
                            //CGEventPost(eventTapLocation, shiftDown)
                            //set char down
                            //CGEventPost(eventTapLocation, writeUpcaseCharEventDown)
                            //set char up
                            //CGEventPost(eventTapLocation, writeUpcaseCharEventUp)
                            //set shift up
                            //CGEventPost(eventTapLocation, shiftUp)
                            
                            //lets repeat coupla times as seems slow or concurrent?
                            //CGEventPost(loc2, shiftUp)
                            //CGEventPost(loc2, shiftUp)
                            //CGEventPost(loc2, shiftUp)
                            //CGEventSetFlags(writeUpcaseCharEventDown, CGEventFlags.MaskShift)
                            //CGEventSetFlags(writeUpcaseCharEventDown, CGEventFlags.MaskAlphaShift)
                            //CGEventRef event1, event2;
                            //event1 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)6, true);//'z' keydown event
                            CGEventSetFlags(writeUpcaseCharEventDown, CGEventFlags.MaskShift)//set shift key down for above event
                            CGEventPost(eventTapLocation, writeUpcaseCharEventDown);//post event
                            //I'm then releasing the 'z' key for completeness (also setting the shift-flag on, though not sure if this is correct).
                            
                            //event2 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)6, false);
                            CGEventSetFlags(writeUpcaseCharEventUp, CGEventFlags.MaskShift)
                            CGEventPost(eventTapLocation, writeUpcaseCharEventUp)
                            //Finally (and bizarrely) you DO need to send the 'key up' event for the shift key:
                            
                            //e5 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)56, false);
                            CGEventPost(eventTapLocation, shiftUp)
                            CGEventPost(eventTapLocation, shiftUp)
                            CGEventPost(eventTapLocation, shiftUp)
                            CGEventPost(eventTapLocation, shiftUp)
                            CGEventPost(eventTapLocation, shiftUp)
                            CGEventPost(eventTapLocation, shiftUp)
                            CGEventPost(eventTapLocation, shiftUp)
                            //consider this: http://stackoverflow.com/questions/2008126/cgeventpost-possible-bug-when-simulating-keyboard-events
                            //issues with this behavior generally.... maybe related to multitask?
                            
                        }
                    }
                    else {
                        //we are writing a space or a newline
                        let loc1 : CGEventTapLocation = CGEventTapLocation(rawValue: 0)!
                        //all good to go
                        //send the event first down key then up
                        let writeCharEventDown = CGEventCreateKeyboardEvent(nil, convertCharToKeyCode(altChar),true)! //down key
                        let writeCharEventUp = CGEventCreateKeyboardEvent(nil, convertCharToKeyCode(altChar),false)! //up key
                        CGEventPost(eventTapLocation, writeCharEventDown)
                        CGEventPost(eventTapLocation, writeCharEventUp)
                    }
                }
            }
            
        }

        

    }
    

    func evaluatePressedKey(code: UInt16) -> Bool {
        switch (code) {
        case 0 ... 35: return true
        case 37 ... 49: return true
        case 82 ... 89: return true
        case 91 ... 92: return true
        default: return false;
        }

    }

    func convertKeyCode(code: UInt16) -> String {
        
        switch (code) {
        case 0:   return "a"
        case 1:   return "s"
        case 2:   return "d"
        case 3:   return "f"
        case 4:   return "h"
        case 5:   return "g"
        case 6:   return "z"
        case 7:   return "x"
        case 8:   return "c"
        case 9:   return "v"
        case 11:  return "b"
        case 12:  return "q"
        case 13:  return "w"
        case 14:  return "e"
        case 15:  return "r"
        case 16:  return "y"
        case 17:  return "t"
        case 18:  return "1"
        case 19:  return "2"
        case 20:  return "3"
        case 21:  return "4"
        case 22:  return "6"
        case 23:  return "5"
        case 24:  return "="
        case 25:  return "9"
        case 26:  return "7"
        case 27:  return "-"
        case 28:  return "8"
        case 29:  return "0"
        case 30:  return "]"
        case 31:  return "o"
        case 32:  return "u"
        case 33:  return "["
        case 34:  return "i"
        case 35:  return "p"
        case 37:  return "l"
        case 38:  return "j"
        case 39:  return "'"
        case 40:  return "k"
        case 41:  return ";"
        case 42:  return "\\"
        case 43:  return ","
        case 44:  return "/"
        case 45:  return "n"
        case 46:  return "m"
        case 47:  return "."
        case 50:  return "`"
        case 65:  return "[decimal]"
        case 67:  return "[asterisk]"
        case 69:  return "[plus]"
        case 71:  return "[clear]"
        case 75:  return "[divide]"
        case 76:  return "[enter]"
        case 78:  return "[hyphen]"
        case 81:  return "[equals]"
        case 82:  return "0"
        case 83:  return "1"
        case 84:  return "2"
        case 85:  return "3"
        case 86:  return "4"
        case 87:  return "5"
        case 88:  return "6"
        case 89:  return "7"
        case 91:  return "8"
        case 92:  return "9"
        case 36:  return "[return]"
        case 48:  return "[tab]"
        case 49:  return " "
        case 51:  return "[del]"
        case 53:  return "[esc]"
        case 54:  return "[right-cmd]"
        case 55:  return "[left-cmd]"
        case 56:  return "[left-shift]"
        case 57:  return "[caps]"
        case 58:  return "[left-option]"
        case 59:  return "[left-ctrl]"
        case 60:  return "[right-shift]"
        case 61:  return "[right-option]"
        case 62:  return "[right-ctrl]"
        case 63:  return "[fn]"
        case 64:  return "[f17]"
        case 72:  return "[volup]"
        case 73:  return "[voldown]"
        case 74:  return "[mute]"
        case 79:  return "[f18]"
        case 80:  return "[f19]"
        case 90:  return "[f20]"
        case 96:  return "[f5]"
        case 97:  return "[f6]"
        case 98:  return "[f7]"
        case 99:  return "[f3]"
        case 100: return "[f8]"
        case 101: return "[f9]"
        case 103: return "[f11]"
        case 105: return "[f13]"
        case 106: return "[f16]"
        case 107: return "[f14]"
        case 109: return "[f10]"
        case 111: return "[f12]"
        case 113: return "[f15]"
        case 114: return "[help]"
        case 115: return "[home]"
        case 116: return "[pgup]"
        case 117: return "[fwddel]"
        case 118: return "[f4]"
        case 119: return "[end]"
        case 120: return "[f2]"
        case 121: return "[pgdown]"
        case 122: return "[f1]"
        case 123: return "[left]"
        case 124: return "[right]"
        case 125: return "[down]"
        case 126: return "[up]"
        default: return " "
        }
        //return "[unknown]";
    }
    
    func convertCharToKeyCode(aAltChar: Character) -> CGKeyCode {
        
        var theIntCode:Int
        
        switch (aAltChar) {
        case "a": theIntCode = 0
        case "s": theIntCode = 1
        case "d": theIntCode = 2
        case "f": theIntCode = 3
        case "h": theIntCode = 4
        case "g": theIntCode = 5
        case "z": theIntCode = 6
        case "x": theIntCode = 7
        case "c": theIntCode = 8
        case "v": theIntCode = 9
        case "b": theIntCode = 11
        case "q": theIntCode = 12
        case "w": theIntCode = 13
        case "e": theIntCode = 14
        case "r": theIntCode = 15
        case "y": theIntCode = 16
        case "t": theIntCode = 17
        case "1": theIntCode = 18
        case "2": theIntCode = 19
        case "3": theIntCode = 20
        case "4": theIntCode = 21
        case "6": theIntCode = 22
        case "5": theIntCode = 23
        case "=": theIntCode = 24
        case "9": theIntCode = 25
        case "7": theIntCode = 26
        case "-": theIntCode = 27
        case "8": theIntCode = 28
        case "0": theIntCode = 29
        case "]": theIntCode = 30
        case "o": theIntCode = 31
        case "u": theIntCode = 32
        case "[": theIntCode = 33
        case "i": theIntCode = 34
        case "p": theIntCode = 35
        case "l": theIntCode = 37
        case "j": theIntCode = 38
        case "'": theIntCode = 39
        case "k": theIntCode = 40
        case ";": theIntCode = 41
        case "\\": theIntCode = 42
        case ",": theIntCode = 43
        case "/": theIntCode = 44
        case "n": theIntCode = 45
        case "m": theIntCode = 46
        case ".": theIntCode = 47
        case "`": theIntCode = 50
        case "0": theIntCode = 82
        case "1": theIntCode = 83
        case "2": theIntCode = 84
        case "3": theIntCode = 85
        case "4": theIntCode = 86
        case "5": theIntCode = 87
        case "6": theIntCode = 88
        case "7": theIntCode = 89
        case "8": theIntCode = 91
        case "9": theIntCode = 92
        case "\n": theIntCode = 36
        case "\t": theIntCode = 48
        case " ": theIntCode = 49

        default: theIntCode = 49
        }
        return CGKeyCode(theIntCode)
    }


}