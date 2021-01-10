//
//  MusicList.swift
//  MusicAll
//
//  Created by Patryk Krajnik on 10/01/2021.
//

import UIKit

class MusicListViewController: UITableViewController {
    
    @IBOutlet var musicList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    func configureTableView() {
        setTableViewDelegates()
        musicList.rowHeight = 100
        self.title = "Library"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setTableViewDelegates() {
        musicList.delegate = self
        musicList.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
