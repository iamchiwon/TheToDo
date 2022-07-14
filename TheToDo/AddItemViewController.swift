//
//  AddItemViewController.swift
//  TheToDo
//
//  Created by Chiwon Song on 2022/02/16.
//

import UIKit

class AddItemViewController: UIViewController {
    var createdItem: ((String, Date) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        itemTitle.becomeFirstResponder()
    }

    @IBOutlet var itemTitle: UITextView!

    @IBAction func onDone() {
        createdItem?(itemTitle.text ?? "", Date())
        dismiss(animated: true, completion: nil)
    }
}
