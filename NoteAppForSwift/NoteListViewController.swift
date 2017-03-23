//
//  NoteListViewController.swift
//  NoteAppForSwift
//
//  Created by 陳昶安 on 2017/2/11.
//  Copyright © 2017年 ANAN. All rights reserved.
//

import UIKit
import CoreData

class NoteListViewController: UIViewController,UITableViewDataSource,NoteViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var notes:[Note] = []
    
    required init?(coder aDecoder: NSCoder) {
        
        //產生9筆假的cell資料
//        for index in 0..<10 {
//            let note = Note()
//            note.text = "Note \(index)"
//            self.notes.append(note)
//        }
        
        super.init(coder: aDecoder)
        //self.loadFromFile()
        self.loadFromCoreData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        //設定左上角編輯按鈕
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        //設定左上編輯按鈕進入編輯模式
        self.tableView.setEditing(editing, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: File Archiving
    func loadFromFile() {
        
        let homeURL = NSURL(fileURLWithPath: NSHomeDirectory())
        let documentURL = homeURL.appendingPathComponent("Documents")
        let fileURL = documentURL?.appendingPathComponent("notes.archive")
        
        if let notes = NSKeyedUnarchiver.unarchiveObject(withFile: (fileURL?.path)!) as?[Note] {
            
            self.notes = notes
            
        } else { //如果不存在
            
            self.notes = []
            
        }
        
    }
    
    func saveToFile() {
        
        let homeURL = NSURL(fileURLWithPath: NSHomeDirectory())
        let documentURL = homeURL.appendingPathComponent("Documents")
        let fileURL = documentURL?.appendingPathComponent("notes.archive")
        
        NSKeyedArchiver.archiveRootObject(self.notes, toFile: (fileURL?.path)!)
        
    }
    
    //MARK: CoreData
    func loadFromCoreData() {
        
        let moc = CoreDataHelper.shareInstance.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        moc.performAndWait { 
            
            do {
                
                let result = try moc.fetch(request) as! [Note]
                self.notes = result
                
            } catch {
                
                print("error: \(error)")
                self.notes = []
                
            }
        }
    }
    
    func saveToCoreData() throws {
        
        let moc = CoreDataHelper.shareInstance.managedObjectContext
        var e: Error?
        
        moc.performAndWait {
            
            if moc.hasChanges {
                
                do {
                    
                    try moc.save()
                    
                } catch {
                    
                    print("error saving \(error)")
                    e = error
                    
                }
                
            }
            
        }
        if let error = e {
            
            throw error
            
        }
        
        
        
    }
    
    
    @IBAction func addNote(_ sender: Any) {
        
        //let note = Note()
        let moc = CoreDataHelper.shareInstance.managedObjectContext
        var note: Note!
        moc.performAndWait { 
            
            note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: moc) as! Note
            
        }
        
        note.text = "New Note"
        do {
            
            try self.saveToCoreData()
            
            //self.notes.append(note)   //新增cell在最下方
            self.notes.insert(note, at: 0)   //新增cell在最上方
            
            //新增cell在最下方
            //let indexPath = IndexPath(row: self.notes.count-1, section: 0)
            
            //新增cell在最上方
            let indexPath = IndexPath(row: 0, section: 0)
            
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            
            //self.saveToFile()
            
        } catch {
            
            print("add note error \(error)")
            
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        
        
        let note = self.notes[indexPath.row]
        cell.textLabel?.text = note.text
        cell.imageView?.image = note.image()
        
        //cell.imageView?.image = UIImage(named: "履歷用大頭照.jpg")
        //cell.imageView?.image = UIImage(named: "NoteApp的MVC.png")

        //print("row \(indexPath.row)")
        
        //讓cell可以移動位置的步驟一
        cell.showsReorderControl = true
        
        return cell
    }
    
    //讓cell可以移動位置的步驟二
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //使編輯模式下在cell的最右邊出現三條線的reorder，一個移動cell的按鈕
        let note = self.notes[sourceIndexPath.row]
        self.notes.remove(at: sourceIndexPath.row)
        self.notes.insert(note, at: destinationIndexPath.row)
        self.saveToFile()
        
    }
    
    //在編輯模式下按delete時dataSource所呼叫出的方法，editingStyle會有三種值
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let note = self.notes[indexPath.row]
            
            let moc = CoreDataHelper.shareInstance.managedObjectContext
            moc.performAndWait({ 
                
                moc.delete(note)
                
            })
            
            do {
                
                try saveToCoreData()
                self.notes.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                //self.saveToFile()
                
            } catch {
                
                print("delete note error: \(error)")
                
            }
        
            
        }
        
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if  segue.identifier == "noteViewController" {
            
            let noteViewController = segue.destination as! NoteViewController
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let note = self.notes[indexPath.row]
                noteViewController.note = note
                noteViewController.delegate = self
                
            }
        
        }
        
    }

    func didFinishUpdateNote(note: Note) {
        
        if let index = self.notes.index(of: note) {
            
            do {
                
                try self.saveToCoreData()
                let indexPath = NSIndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath as IndexPath], with: .automatic)
                //self.saveToFile()
                
            } catch {
                
                print("error updating note \(error)")
                
            }
            
            
        }
        
    }
    
}
