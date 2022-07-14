//
//  UserDefaultRepository.swift
//  TheToDo
//
//  Created by Chiwon Song on 2022/07/15.
//

import Foundation

class UserDefaultRepository: Repository {
    private let TodoKey = "todos"
    private var database: UserDefaults { UserDefaults.standard }

    func load() -> [ToDo] {
        return []
    }

    func save(todos: [ToDo]) {
    }
}
