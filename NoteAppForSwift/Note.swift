//
//  Note.swift
//  NoteAppForSwift
//
//  Created by 陳昶安 on 2017/2/11.
//  Copyright © 2017年 ANAN. All rights reserved.
//

import UIKit
import CoreData

//class Note: NSObject,NSCoding {
class Note: NSManagedObject {

    @NSManaged var text: String?
    //var image: UIImage?
    @NSManaged var imageName: String?
    
    /*
    required init?(coder aDecoder: NSCoder) {
        
        self.text = aDecoder.decodeObject(forKey: "text") as? String
        self.imageName = aDecoder.decodeObject(forKey: "imageName") as? String
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.text, forKey: "text")
        aCoder.encode(self.imageName, forKey: "imageName")
        
    }
    
    override init() {
        super.init()
    }
    */
 
    func image() -> UIImage? {
        
        if let fileName = self.imageName {
            
            let homeURL = NSURL(fileURLWithPath: NSHomeDirectory())
            let documentURL = homeURL.appendingPathComponent("Documents")
            let fileURL = documentURL?.appendingPathComponent(fileName)
            if let imageData = NSData(contentsOf: fileURL!) {
                
                return UIImage(data: imageData as Data)
                
            }
            
            
        }
        
        return nil
    }
    
}
