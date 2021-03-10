//
//  MusicList.swift
//  MusicAll
//
//  Created by Patryk Krajnik on 10/01/2021.
//

import UIKit

class MusicListViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var musicList: UITableView!
    
    lazy var searchBar: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.delegate = self
        
        return searchController
    }()
    
    var songs = [SongModel]()
    var filteredSongs = [SongModel]()
    
    final let apiURL = "Here is a place for URL to your API"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchBar
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshContent(sender:)), for: .valueChanged)
        
        configureTableView()
        prepareToParse()
    }
    
    @objc func refreshContent(sender: AnyObject) {
        prepareToParse()
        refreshControl?.endRefreshing()
    }
    
    func configureTableView() {
        setTableViewDelegates()
        self.title = "Library"
        musicList.rowHeight = 100
        musicList.tableFooterView = UITableView()
    }
    
    func setTableViewDelegates() {
        musicList.delegate = self
        musicList.dataSource = self
    }
    
    func prepareToParse() {
        if let url = URL(string: apiURL) {
            guard let data = try? Data(contentsOf: url) else {
                print("Not a valid URL")
                return
            }
            parseJsonFromURL(json: data)
        } else {
            parseLocalJson()
        }
    }
    
    func parseLocalJson() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard
            let localJson = Bundle.main.url(forResource: "localMusic", withExtension: "json"),
            let data = try? Data(contentsOf: localJson),
            let jsonSongs = try? decoder.decode([SongModel].self, from: data)
        else {
            print("JSON file could not be found")
            return
        }
        songs = jsonSongs
    }
    
    func parseJsonFromURL(json: Data) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        if let jsonSongs = try? decoder.decode([SongModel].self, from: json) {
            songs = jsonSongs
            musicList.reloadData()
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredSongs = songs.filter({(song: SongModel) -> Bool in
            if isSearchBarEmpty() {
                return true
            } else {
                return song.songName.lowercased().contains(searchText.lowercased())
            }
        })
        musicList.reloadData()
    }
    
    func isSearchBarEmpty() -> Bool {
        return searchBar.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchBar.isActive && (!isSearchBarEmpty())
    }
    
    func getSongTitle(songName: String) -> String {
        let songFullName = songName.components(separatedBy: "-")
        let songTitle = songFullName[1]
        let trimmedSongTitle = songTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trimmedSongTitle
    }
    
    func getSongArtist(songName: String) -> String {
        let songFullName = songName.components(separatedBy: "-")
        let songArtist = songFullName[0]
        let trimmedSongArtist = songArtist.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trimmedSongArtist
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() { return filteredSongs.count }
        return songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell") as? MusicListCell else {return UITableViewCell()}
        
        let currentSongs: SongModel
        
        if isFiltering() {
            currentSongs = filteredSongs[indexPath.row]
        } else {
            currentSongs = songs[indexPath.row]
        }
        
        cell.songArtist.text = getSongArtist(songName: currentSongs.songName)
        cell.songTitle.text = getSongTitle(songName: currentSongs.songName)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MusicListCell
        let viewController = storyboard?.instantiateViewController(identifier: "MusicPlayerViewController") as? MusicPlayerViewController
        
        if let songTitleCell = cell.songTitle.text?.description, let songArtistCell = cell.songArtist.text?.description {
            viewController?.songTitle = songTitleCell
            viewController?.songArtist = songArtistCell
        }
        
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
}

extension MusicListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}


 /* TODO LIST
 - dostosować do light/dark mode
 - stworzyć Radio Player
 - pokombinować żeby dodawać do ulubionych
 - dodać żeby player się minimalizował i można było wrócić do obecnie grającej piosenki
*/
