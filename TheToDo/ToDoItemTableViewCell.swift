//
//  ToDoItemTableViewCell.swift
//  TheToDo
//
//

import UIKit

protocol Toggable: AnyObject {
    func toggle(withId id: String)
}

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
            isDone.isOn = newValue.done
            updatedAt.text = formatter.string(from: newValue.createdAt)
            self.todo = newValue
        }
    }

    weak var toggable: Toggable?

    @IBAction func onToggle() {
        toggable?.toggle(withId: todo.id)
    }
}
