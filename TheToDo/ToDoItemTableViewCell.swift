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
    
    var todo: ToDo? {
        didSet {
            guard let todo = todo else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"

            itemTitle.text = todo.title
            isDone.isOn = todo.done
            updatedAt.text = formatter.string(from: todo.createdAt)
        }
    }

    weak var toggable: Toggable?

    @IBAction func onToggle() {
        guard let todo = todo else { return }
        toggable?.toggle(withId: todo.id)
    }
}
