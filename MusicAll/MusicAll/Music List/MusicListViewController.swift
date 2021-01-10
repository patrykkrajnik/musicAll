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
        self.title = "Library"
        musicList.rowHeight = 100
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


 /* TODO LIST
 - json i odbieranie z niego danych
 - wyświetlanie danych z jsona
 - wyszukiwarka na górze kontrolera
 - dostosować do light/dark mode
 - stworzyć Radio Player
 - pokombinować żeby dodawać do ulubionych
 - dodać żeby player się minimalizował i można było wrócić do obecnie grającej piosenki
*/
