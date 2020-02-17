# mTextXpander

This is Archived. too old to be used imo.

~~UPDATE 20190215
As you can guess, I did not really manage to follow up on any open issue that the code has (time constraints)
Also, this code is still swift 2.2 and would need to be converted to swift 4 nowadays. 
On any case, I uploaded a compiled version for wohmever would like to use the (incomplete) version (works with US qwerty only, really)~~

----------------

~~a homemade Mac OS X text replacement / expansion app, templating app, written in SWIFT. functional but needs improvement, now in beta stage.
The only supported keyboard layout for now is English US. I am not sure how to implement different keyboard layouts at this stage.~~

~~Some parts of the code still need lots of cloaning, and there is an ObjC bridge I thought I'd have to use but didn't so it is still there...~~

~~Important disclaimer:
 the software is provided as is, is in beta stage eternally, and the author is not liable for any issue you think this software may case.~~
 
~~more importantly, the author never even opened a book about SWIFT and is conscious this is very bad, he is very sorry for it, too, and the code may be heavily impacted by his ignorance of the matter. All suggestions are hence more than welcome :)
 It should be compatible with only Mac OS X 10.11 but I did not try with any other versions.~~

~~Status:
the app can now write special characters, but still only US_en layout is supported. as soon as I figure out how to programmatically detect the keyboard layout and identify a conversion algorithm I will switch to multilang, but I have no idea so far when will that happen.~~

~~Structure:
mTextXpander reads from an XML file located in your document folder called xpand.xml
it is just a plain text file with xml, defined as follows:~~
<s>
~~~ xml
<xml>
<abbreviation>
<shorttext>
hai
</shorttext>
<longtext>
hello world.
</longtext>
</abbreviation>
<abbreviation>
<shorttext>
cu.
</shorttext>
<longtext>
goodbye.
</longtext>
</abbreviation>
</xml>
~~~
</s>

<s>
The software parses through the xml and loads in in an array, which is part of a global object handling the XML operations.
The array is initialised with objects of this class:
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
each of which represents an associaton of short text (or abbreviation) and long text (which is your message / template / whatever).
 </s>
<s>
a table is bound to the array through cocoa bindings and uses KVO to load the content.

edit function does not really edit but removes an xml entity and re adds it but copies the text for you before presenting you the dialog.

For the keyboard handling part is a mess. read through and sooner or later I will sum it up here too :)

I will write some documentation, but as of now this was mostly result of about a week work out of the blue as a first approach to swift (AND I did not want to spend 5 euros for the funcionality, alas! how tightfisted of me!)
</s>

<s>
CREDITS:
Please keep in mind this has been done for fun, and I have almost no idea about swift.
Also, lots of code has been copied from various stackoverflow / tutorials / articles / KBs / and so forth.
Some code has been adapted by some other ObjC projects like keylogger.
Many of them were just snippets and I could not keep track of them but notify me if I should include you on references, please.
My thanks to caseyscarborough for the first examples I read on obtaining keyboard events, on https://github.com/caseyscarborough/keylogger
also thanks to Mikael Konutgan for the tutorial https://www.raywenderlich.com/98178/os-x-tutorial-menus-popovers-menu-bar-apps
from which I got the base structure of the menu bar app


</s>

Old SWIFT Code. nowadays probably dead in favour of new SWIFT versions, might need a total rework, hence archiving!

