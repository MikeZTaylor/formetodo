//
//  ViewController.swift
//  For me to do
//
//  Created by Mike Taylor on 23/05/2017.
//  Copyright © 2017 Mike Taylor. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private var todoItems = [ToDoItem]()
    
    private func vibrateWithHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.prepare()
    
    generator.impactOccurred()
    }
    
    func platform() -> String {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    public var hasHapticFeedback: Bool {
        return ["iPhone9,1", "iPhone9,3", "iPhone9,2", "iPhone9,4"].contains(platform())
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_todo", for: indexPath)
        
        if indexPath.row < todoItems.count
        {
            let item = todoItems[indexPath.row]
            cell.textLabel?.text = item.title
            
            let accessory: UITableViewCellAccessoryType = item.done ? .checkmark : .none
            cell.accessoryType = accessory
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < todoItems.count
        {
            let item = todoItems[indexPath.row]
            item.done = !item.done
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func didTapAddItemButton(_ sender: UIBarButtonItem)
    {
        // Create an alert
        let alert = UIAlertController(
            title: "New to-do item",
            message: "Insert the title of the new to-do item:",
            preferredStyle: .alert)
        
        // Add a text field to the alert for the new item's title
        alert.addTextField(configurationHandler: nil)
        
        // Add a "cancel" button to the alert. This one doesn't need a handler
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Add a "OK" button to the alert. The handler calls addNewToDoItem()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let title = alert.textFields?[0].text
            {
                self.addNewToDoItem(title: title)
            }
        }))
        
        // Present the alert to the user
        self.present(alert, animated: true, completion: nil)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

    }
    
    private func addNewToDoItem(title: String)
    {
        // The index of the new item will be the current item count
        let newIndex = todoItems.count
        
        // Create new item and add it to the todo items list
        todoItems.append(ToDoItem(title: title))
        
        // Tell the table view a new row has been created
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if indexPath.row < todoItems.count
        {
            todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc
    public func applicationDidEnterBackground(_ notification: NSNotification)
    {
        do
        {
            try todoItems.writeToPersistence()
        }
        catch let error
        {
            NSLog("Error writing to persistence: \(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
          self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.didTapAddItemButton(_:)))
        
        // Setup a notification to let us know when the app is about to close,
        // and that we should store the user items to persistence. This will call the
        // applicationDidEnterBackground() function in this class
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)),
            name: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil)
        
        do
        {
            // Try to load from persistence
            self.todoItems = try [ToDoItem].readFromPersistence()
        }
        catch let error as NSError
        {
            if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError
            {
                NSLog("Could not find a persistence file, this many not be a bad thing")
            }
            else
            {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Could not load the items from for me to do!",
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                NSLog("Error loading from persistence: \(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

