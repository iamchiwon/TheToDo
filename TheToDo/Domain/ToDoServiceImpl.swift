//
//  ToDoServiceImpl.swift
//  TheToDo
//
//  Created by Chiwon Song on 2022/07/15.
//

import Foundation

class ToDoServiceImpl: ToDoService {
    private var todoItems: [ToDo] = []

    func create(title: String) {
        let todo = ToDo(id: UUID().uuidString,
                        title: title,
                        done: false,
                        createdAt: Date())
        todoItems.append(todo)
    }

    func count() -> Int {
        return todoItems.count
    }

    func item(at index: Int) -> ToDo {
        return todoItems[index]
    }
}

extension ToDoServiceImpl: Toggable {
    func toggle(withId id: String) {
    }
}
