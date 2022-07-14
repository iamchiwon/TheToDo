//
//  ToDo.swift
//  TheToDo
//
//  Created by Chiwon Song on 2022/07/15.
//

import Foundation

struct ToDo: Identifiable, Codable {
    let id: String
    let title: String
    var done: Bool
    let createdAt: Date
}
