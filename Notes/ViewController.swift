//
//  ViewController.swift
//  Notes
//
//  Created by Александр Федоткин on 17.10.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleText: UILabel!
    
    @IBOutlet weak var bottomTitleText: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    var nameArray = [String]()
    var idArray = [UUID]()
    var noteArray = [String]()
    var dateArray = [Date]()
    var monthArray = [String]()
    
    var selectedNote = ""
    var selectedNoteId: UUID?
    var selectedSecondNote = ""
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        navigationController?.navigationBar.backgroundColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
        idArray.removeAll()
        nameArray.removeAll()
        noteArray.removeAll()
        getData()
    }
    
    @objc func addButtonClicked(){
        selectedNote = ""
        performSegue(withIdentifier: "toNoteDetails", sender: nil)
    }
    
    @objc func getData(){
        tableView.sectionHeaderTopPadding = CGFloat(2)
        idArray.removeAll()
        nameArray.removeAll()
        noteArray.removeAll()
        monthArray.removeAll()
        dateArray.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequests = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        fetchRequests.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(fetchRequests)
            if results.count > 0{
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String{
                        self.nameArray.insert(title, at: 0)
                    } else{
                        self.nameArray.insert("", at: 0)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.insert(id, at: 0)
                    }
                    if let note = result.value(forKey: "note") as? String{
                        self.noteArray.insert(note, at: 0)
                    }
                    if let date = result.value(forKey: "date") as? Date{
                        self.dateArray.insert(date, at: 0)
                    }
                    self.tableView.reloadData()
                }
            }
            printLable()
            self.tableView.reloadData()
        } catch {
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var cellStyle = cell.defaultContentConfiguration()
        cellStyle.textProperties.numberOfLines = 1
        cellStyle.textProperties.lineBreakMode = .byTruncatingTail
        cellStyle.textProperties.color = UIColor.white
        cellStyle.secondaryTextProperties.numberOfLines = 1
        cellStyle.secondaryTextProperties.lineBreakMode = .byTruncatingTail
        cellStyle.secondaryTextProperties.color = UIColor.lightGray

        var index = indexPath.row + indexPath.section * tableView.numberOfRows(inSection: indexPath.section)
        
        if noteArray[index] != "" && nameArray[index] != ""{
            cellStyle.text = nameArray[index]
            cellStyle.secondaryText = noteArray[index]
        } else if noteArray[index] != "" && nameArray[index] == ""{
            cellStyle.text = noteArray[index]
            cellStyle.secondaryText = "Нет дополнительного текста"
        } else if noteArray[index] == "" && nameArray[index] != ""{
            cellStyle.text = nameArray[index]
            cellStyle.secondaryText = "Нет дополнительного текста"
        }
        cell.contentConfiguration = cellStyle
        cell.backgroundColor = UIColor.darkGray

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        setMonthArr()
        return monthArray.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return monthArray[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var quantityRows : Int = 0
        printLable()
        for index in dateArray{
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("MMMM")
            let monthQuantity = formatter.string(from: index)
            if monthQuantity == monthArray[section]{
                quantityRows += 1
            }
        }
        return quantityRows
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let index = indexPath.row + indexPath.section * tableView.numberOfRows(inSection: indexPath.section)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            let idString = idArray[index].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[index] {
                                context.delete(result)
                                nameArray.remove(at: index)
                                idArray.remove(at: index)
                                dateArray.remove(at: index)
                                setMonthArr()
                                printLable()
                                self.tableView.reloadData()
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
            }
            catch{
                print("error")
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row + indexPath.section * tableView.numberOfRows(inSection: indexPath.section)
        selectedNote = nameArray[index]
        selectedNoteId = idArray[index]
        selectedSecondNote = noteArray[index]
        performSegue(withIdentifier: "toNoteDetails", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNoteDetails"{
            let destinationVC = segue.destination as! NoteDetailsViewController
            destinationVC.selectedNote = selectedNote
            destinationVC.selectedId = selectedNoteId
            destinationVC.selectedSecondNote = selectedSecondNote
            selectedNote = ""
            selectedSecondNote = ""
        }
    }

    func setMonthArr(){
        if !dateArray.isEmpty{
            var checkDel = [String]()
            for index in dateArray{
                let formatter = DateFormatter()
                formatter.setLocalizedDateFormatFromTemplate("MMMM")
                if monthArray.firstIndex(of: formatter.string(from: index)) == nil{
                   checkDel.append(formatter.string(from: index))
                } else if checkDel.firstIndex(of: formatter.string(from: index)) == nil{
                    checkDel.append(formatter.string(from: index))
                }
                monthArray = checkDel
            }
        } else{
            monthArray.removeAll()
        }
    }
    
    func printLable(){
        switch nameArray.count{
        case 0:
            bottomTitleText.text = "Нет заметок"
        case 1:
            bottomTitleText.text = "\(nameArray.count) заметка"
        case 2..<5:
            bottomTitleText.text = "\(nameArray.count) заметки"
        default:
            bottomTitleText.text = "\(nameArray.count) заметок"
        }
    }
}

