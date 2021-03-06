//
//  Repository.swift
//  TheToDo
//
//  Created by Chiwon Song on 2022/07/15.
//

import Foundation

protocol Repository {
    func load() -> [ToDo]
    func save(todos: [ToDo])
}
