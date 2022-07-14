//
//  ViewController.swift
//  TheToDo
//
//

import UIKit

class ToDoListViewController: UITableViewController {
    var todoItems: [(title: String, createdAt: Date)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateNewItem", let toVC = segue.destination as? AddItemViewController {
            toVC.createdItem = { [weak self] title, createdAt in
                self?.todoItems.append((title, createdAt))
                self?.tableView.reloadData()
            }
        }
    }
}

extension ToDoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as? ToDoItemTableViewCell else {
            fatalError("tableViewCell has not dequeued!")
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"

        let item = todoItems[indexPath.row]
        cell.itemTitle.text = item.title
        cell.updatedAt.text = formatter.string(from: item.createdAt)

        return cell
    }
}
