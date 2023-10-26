//
//  NoteDetailsViewController.swift
//  Notes
//
//  Created by Александр Федоткин on 17.10.2023.
//

import UIKit
import CoreData

class NoteDetailsViewController: UIViewController, UITextViewDelegate {
    var selectedNote = ""
    var selectedId: UUID?
    var selectedSecondNote = ""
    
    @IBOutlet weak var titleTextView: UITextView!
    
    @IBOutlet weak var noteTextView: UITextView!
    
    override func viewDidLoad() {
        titleTextView.delegate = self
        noteTextView.delegate = self
        
        super.viewDidLoad()
        
        if selectedNote != ""{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            let idString = selectedId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String{
                            self.titleTextView.text = title
                        }
                        if let note = result.value(forKey: "note") as? String{
                            self.noteTextView.text = note
                        }
                    }
                }
            } catch{
                print("error")
            }
            
        } else if selectedNote == "" && selectedSecondNote == ""{
            titleTextView.text = ""
            noteTextView.text = ""
            noteTextView.isEditable = false
        } else if selectedNote == "" && selectedSecondNote != ""{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            let idString = selectedId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String{
                            self.titleTextView.text = title
                        }
                        if let note = result.value(forKey: "note") as? String{
                            self.noteTextView.text = note
                        }
                    }
                }
            } catch{
                print("error")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if titleTextView.text != "" && selectedNote == ""{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let newNote = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context)
            
            newNote.setValue(titleTextView.text, forKey: "title")
            newNote.setValue(noteTextView.text, forKey: "note")
            newNote.setValue(Date(), forKey: "date")
            
            newNote.setValue(UUID(), forKey: "id")
            do{
                try context.save()
            } catch {
                print("error")
            }
            NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
            self.navigationController?.popViewController(animated: true)
        } else if titleTextView.text != "" && selectedNote != ""{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            let idString = selectedId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if titleTextView.text != selectedNote || noteTextView.text != selectedNote{
                            result.setValue(titleTextView.text, forKey: "title")
                            result.setValue(noteTextView.text, forKey: "note")
                            result.setValue(Date(), forKey: "date")
                        }
                        do{
                            try context.save()
                        } catch{
                            print("error")
                        }
                    }
                }
            } catch{
                print("error")
            }
            NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
            self.navigationController?.popViewController(animated: true)
        } else if titleTextView.text == "" && selectedNote != ""{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            let idString = selectedId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        result.setValue(titleTextView.text, forKey: "title")
                        result.setValue(noteTextView.text, forKey: "note")
                        result.setValue(Date(), forKey: "date")
                        do{
                            try context.save()
                        } catch{
                            print("error")
                        }
                    }
                }
            } catch{
                print("error")
            }
            NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }
        if titleTextView.text == "" && noteTextView.text == "" && (selectedSecondNote != "" || selectedNote != ""){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let context = appDelegate.persistentContainer.viewContext
            
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
                        let idString = selectedId?.uuidString
            
                        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
                        fetchRequest.returnsObjectsAsFaults = false
            
                        do{
                            let results = try context.fetch(fetchRequest)
                            if results.count > 0{
                                for result in results as! [NSManagedObject]{
                                    if let id = result.value(forKey: "id") as? UUID{
                                        if id == selectedId{
                                            context.delete(result)
                                        }
                                        do{
                                            try context.save()
                                        } catch{
                                            print("error")
                                        }
                                        break
                                    }
                                }
                            }
                        } catch{
                            print("error")
                        }
                        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
                        self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let text = (textView.text ?? "") as NSString
        let newText = text.replacingCharacters(in: range, with: text as String)
        if !newText.isEmpty {
            noteTextView.isEditable = true
        } else if titleTextView.text.isEmpty{
            noteTextView.isEditable = false
        }
        return true
    }
    
}
