//
//  ToDoService.swift
//  TheToDo
//
//  Created by Chiwon Song on 2022/07/15.
//

import Foundation

protocol ToDoService {
    func create(title: String)
    func count() -> Int
    func item(at: Int) -> ToDo
}
