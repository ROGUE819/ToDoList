//
//  ToDoListTableViewCell.swift
//  NewExample
//
//  Created by Parwate, Shardul on 10/12/20.
//  Copyright © 2020 Parwate, Shardul. All rights reserved.
//

import UIKit

class ToDoListTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
