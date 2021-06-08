//
//  MusicListViewController.swift
//  MusicAll
//
//  Created by Patryk Krajnik on 29/03/2021.
//

import UIKit
import MediaPlayer

class MusicListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var musicList: UITableView!
    @IBOutlet weak var miniPlayer: UIButton!
    @IBOutlet weak var miniPlayerView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var songArtworkImage: UIImageView!
    
    
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
    var songManager = SongManager()
    
    let refreshControl = UIRefreshControl()
    
    final let apiURL = "Here is a place for URL to your API"
    var isJsonOffline = false
    
    override func viewWillAppear(_ animated: Bool) {
        updateSmallButtons()
        SongManager.player?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchBar
        
        musicList.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshContent(sender:)), for: .valueChanged)
        
        if UIDevice.current.hasNotch {
            if let myConstraint = miniPlayerView.constraintWith(identifier: "playerHeight") {
                myConstraint.constant = 100
            }
        }
        
        configureTableView()
        prepareToParse()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            updateSmallButtons()
        }
    }
    
    @IBAction func showMusicPlayer(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(identifier: "MusicPlayerViewController") as? MusicPlayerViewController
        
        if let songTitle = songTitleLabel.text?.description, let songArtist = songArtistLabel.text?.description, let songArtwork = songArtworkImage.image?.accessibilityIdentifier {
            if songTitle != "Title" && songArtist != "Artist" {
                viewController?.songTitle = songTitle
                viewController?.songArtist = songArtist
                viewController?.songArtwork = songArtwork
                
                self.navigationController?.pushViewController(viewController!, animated: true)
            }
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        SongManager.player?.play()
        updateSmallButtons()
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        SongManager.player?.pause()
        updateSmallButtons()
    }
    
    @objc func refreshContent(sender: AnyObject) {
        print("Refreshing...")
        prepareToParse()
        refreshControl.endRefreshing()
    }
    
    func updateSmallButtons() {
        switch SongManager.isPlaying() {
        case true:
            playButton.isHidden = true
            pauseButton.isHidden = false
        default:
            playButton.isHidden = false
            pauseButton.isHidden = true
        }
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
                print("Not valid URL")
                return
            }
            parseJsonFromURL(json: data)
        } else {
            parseLocalJson()
            isJsonOffline = true
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
    
    func filteredContentForSeatchText(searchText: String) {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() { return filteredSongs.count }
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell") as? MusicListCell else {return UITableViewCell()}
        
        let currentSongs: SongModel
        
        if isFiltering() {
            currentSongs = filteredSongs[indexPath.row]
        } else {
            currentSongs = songs[indexPath.row]
        }
        
        cell.songArtist.text = getSongArtist(songName: currentSongs.songName)
        cell.songTitle.text = getSongTitle(songName: currentSongs.songName)
        cell.songArtwork.image = UIImage(named: currentSongs.songArtwork)
        cell.songArtwork.image?.accessibilityIdentifier = currentSongs.songArtwork
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MusicListCell
        let viewController = storyboard?.instantiateViewController(identifier: "MusicPlayerViewController") as? MusicPlayerViewController
        
        if let songTitleCell = cell.songTitle.text?.description, let songArtistCell = cell.songArtist.text?.description, let songArtworkCell = cell.songArtwork.image?.accessibilityIdentifier {
            songTitleLabel.text = songTitleCell
            songArtistLabel.text = songArtistCell
            songArtworkImage.image = UIImage(named: songArtworkCell)
            
            songManager.appendMetadata(songTitleCell, songArtistCell, songArtworkCell, isJsonOffline)
            viewController?.songManager = songManager
        }
        
        self.navigationController?.pushViewController(viewController!, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MusicListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSeatchText(searchText: searchController.searchBar.text!)
    }
}
