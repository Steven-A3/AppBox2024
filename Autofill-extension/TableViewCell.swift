//
//  TableViewCell.swift
//  extension
//
//  Created by Uday on 24/01/21.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var url: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var password: UILabel!
    @IBOutlet weak var cardFrameView: UIView!
    @IBOutlet weak var iconView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardFrameView.layer.cornerRadius = 10
        cardFrameView.layer.shadowOffset = CGSize(width: 5, height: 5)
        cardFrameView.layer.shadowRadius = 3
        cardFrameView.layer.shadowColor = UIColor.darkGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
