//
//  MusicCell.swift
//  MusicAll
//
//  Created by Patryk Krajnik on 10/01/2021.
//

import UIKit

class MusicListCell: UITableViewCell {
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
