//
//  ViewController.swift
//  TheToDo
//
//

import UIKit

class ToDoListViewController: UITableViewController {
    let service: ToDoService = ToDoServiceImpl(repository: UserDefaultRepository()) // TODO: DI

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateNewItem", let toVC = segue.destination as? AddItemViewController {
            toVC.createdItem = { [weak self] title, _ in
                self?.service.create(title: title)
                self?.tableView.reloadData()
            }
        }
    }
}

extension ToDoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        service.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as? ToDoItemTableViewCell else {
            fatalError("tableViewCell has not dequeued!")
        }

        let index = indexPath.row
        let item = service.item(at: index)
        cell.todo = item

        return cell
    }
}
