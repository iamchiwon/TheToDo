//
//  ToDoItemTableViewCell.swift
//  TheToDo
//
//

import UIKit

class ToDoItemTableViewCell: UITableViewCell {
    @IBOutlet var isDone: UISwitch!
    @IBOutlet var itemTitle: UILabel!
    @IBOutlet var updatedAt: UILabel!
    
    var todo: ToDo {
        get {
            self.todo
        }
        set {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"

            itemTitle.text = newValue.title
            updatedAt.text = formatter.string(from: newValue.createdAt)
            self.todo = newValue
        }
    }
}
