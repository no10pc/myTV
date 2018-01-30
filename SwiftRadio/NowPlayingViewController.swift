
import UIKit
import MediaPlayer

import AVFoundation
import AudioToolbox

//*****************************************************************
// Protocol
// Updates the StationsViewController when the track changes
//*****************************************************************

protocol NowPlayingViewControllerDelegate: class {
    func songMetaDataDidUpdate(track: Track)
    func artworkDidUpdate(track: Track)
}

//*****************************************************************
// NowPlayingViewController
//*****************************************************************

class NowPlayingViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var albumHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumImageView: SpringImageView!
    @IBOutlet weak var tvWebView: UIWebView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songLabel: SpringLabel!
    @IBOutlet weak var stationDescLabel: UILabel!
    @IBOutlet weak var stationLongDescTextView: UITextView!
    @IBOutlet weak var volumeParentView: UIView!
    @IBOutlet weak var slider = UISlider()
    
    var currentStation: RadioStation!
    var downloadTask: URLSessionDownloadTask?
    var iPhone4 = false
    var justBecameActive = false
    var newStation = true
    var nowPlayingImageView: UIImageView!
    let radioPlayer = Player.radio
    var track: Track!
    var mpVolumeSlider = UISlider()
    
    weak var delegate: NowPlayingViewControllerDelegate?
    
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stationLongDescTextView.text = currentStation.stationLongDesc
        if currentStation.stationLongDesc == "" {
            stationLongDescTextView.text = "myTV izliyorsunuz."
        } else {
            stationLongDescTextView.text = currentStation.stationLongDesc
        }
        
        //*****************************************************************
        // MUSTAFA ŞAHİN: - UIWebView TV
        //*****************************************************************
        tvWebView.delegate = self
        
        let myURL = URL(string: currentStation.stationStreamURL)
        let myURLRequest:URLRequest = URLRequest(url: myURL!)
        tvWebView.loadRequest(myURLRequest as URLRequest);
        
        tvWebView.scrollView.bounces = false;
        tvWebView.scrollView.showsHorizontalScrollIndicator = false;
        tvWebView.scrollView.showsVerticalScrollIndicator = false;
        
        // Set AlbumArtwork Constraints
        optimizeForDeviceSize()
        
        // Set View Title
        self.title = currentStation.stationName
        
        // Create Now Playing BarItem
        createNowPlayingAnimation()
        
        // Setup MPMoviePlayerController
        // If you're building an app for a client, you may want to
        // replace the MediaPlayer player with a more robust
        // streaming library/SDK. Preferably one that supports interruptions,
        // buffering, stream stitching, backup streams, etc.
        // Most of the good streaming libaries are in Obj-C, however they
        // will work nicely with this Swift code.
        setupPlayer()
        
        // Notification for when app becomes active
        NotificationCenter.default.addObserver(self,
            selector: "didBecomeActiveNotificationReceived",
            name:NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"),
            object: nil)
        
        // Notification for MediaPlayer metadata updated
        NotificationCenter.default.addObserver(self,
            selector: Selector("metadataUpdated:"),
            name:NSNotification.Name.MPMoviePlayerTimedMetadataUpdated,
            object: nil);
        
        // Check for station change
        if newStation {
            track = Track()
            stationDidChange()
        } else {
            updateLabels()
            albumImageView.image = track.artworkImage
            
            if !track.isPlaying {
                pausePressed()
            } else {
                nowPlayingImageView.startAnimating()
            }
        }
        
        // Setup slider
        setupVolumeSlider()
    }
    
    func didBecomeActiveNotificationReceived() {
        // View became active
        updateLabels()
        justBecameActive = true
        updateAlbumArtwork()
    }
    
   
    
    //*****************************************************************
    // MARK: - Setup
    //*****************************************************************
    
    func setupPlayer() {
        radioPlayer.view.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        radioPlayer.view.sizeToFit()
        radioPlayer.movieSourceType = MPMovieSourceType.streaming
        radioPlayer.isFullscreen = true
        radioPlayer.shouldAutoplay = true
        radioPlayer.prepareToPlay()
        radioPlayer.controlStyle = MPMovieControlStyle.none
    }
    
    func setupVolumeSlider() {
        // Note: This slider implementation uses a MPVolumeView
        // The volume slider only works in devices, not the simulator.
        
        volumeParentView.backgroundColor = UIColor.clear
        let volumeView = MPVolumeView(frame: volumeParentView.bounds)
        for view in volumeView.subviews {
            let uiview: UIView = view as UIView
            if (uiview.description as NSString).range(of: "MPVolumeSlider").location != NSNotFound {
                mpVolumeSlider = (uiview as! UISlider)
            }
        }
        
        let thumbImageNormal = UIImage(named: "slider-ball")
        slider?.setThumbImage(thumbImageNormal, for: .normal)
        
    }
    
    func stationDidChange() {
        radioPlayer.stop()
        
        //radioPlayer.contentURL = NSURL(string: currentStation.stationStreamURL)
        //radioPlayer.prepareToPlay()
        radioPlayer.play()
        
        updateLabels(statusMessage: "Kanallar Yükleniyor...")
        
        // songLabel animate
        songLabel.animation = "flash"
        songLabel.repeatCount = 2
        songLabel.animate()
        
        resetAlbumArtwork()
        
        track.isPlaying = false
    }
    
    //*****************************************************************
    // MARK: - Player Controls (Play/Pause/Volume)
    //*****************************************************************
    
    @IBAction func playPressed() {
        track.isPlaying = true
        playButtonEnable(enabled: false)
        radioPlayer.play()
        updateLabels()
        
        // songLabel Animation
        songLabel.animation = "flash"
        songLabel.animate()
        
        // Start NowPlaying Animation
        nowPlayingImageView.startAnimating()
    }
    
    @IBAction func pausePressed() {
        track.isPlaying = false
        
        playButtonEnable()
        
        radioPlayer.pause()
        updateLabels(statusMessage: "Kanal Durduruldu...")
        nowPlayingImageView.stopAnimating()
    }
    
    @IBAction func volumeChanged(sender:UISlider) {
        mpVolumeSlider.value = sender.value
    }
    
    //*****************************************************************
    // MARK: - UI Helper Methods
    //*****************************************************************
    
    func optimizeForDeviceSize() {
        
        // Adjust album size to fit iPhone 4s & iPhone 6 & 6+
        let deviceHeight = self.view.bounds.height
        
        if deviceHeight == 480 {
            iPhone4 = true
            albumHeightConstraint.constant = 106
            view.updateConstraints()
        } else if deviceHeight == 667 {
            albumHeightConstraint.constant = 230
            view.updateConstraints()
        } else if deviceHeight > 667 {
            albumHeightConstraint.constant = 260
            view.updateConstraints()
        }
    }
    
    func updateLabels(statusMessage: String = "") {
        
        if statusMessage != "" {
            // There's a an interruption or pause in the audio queue
            songLabel.text = statusMessage
            artistLabel.text = currentStation.stationName
            
        } else {
            // Radio is (hopefully) streaming properly
            if track != nil {
                songLabel.text = track.title
                artistLabel.text = track.artist
            }
        }
        
        // Hide station description when album art is displayed or on iPhone 4
        if track.artworkLoaded || iPhone4 {
            stationDescLabel.isHidden = true
        } else {
            stationDescLabel.isHidden = false
            stationDescLabel.text = currentStation.stationDesc
        }
    }
    
    func playButtonEnable(enabled: Bool = true) {
        if enabled {
            playButton.isEnabled = true
            pauseButton.isEnabled = false
            track.isPlaying = false
        } else {
            playButton.isEnabled = false
            pauseButton.isEnabled = true
            track.isPlaying = true
        }
    }
    
    func createNowPlayingAnimation() {
        
        // Setup ImageView
        nowPlayingImageView = UIImageView(image: UIImage(named: "NowPlayingBars-3"))

        nowPlayingImageView.contentMode = UIViewContentMode.center
        
        // Create Animation
        nowPlayingImageView.animationImages = AnimationFrames.createFrames()
        nowPlayingImageView.animationDuration = 0.7
        
        // Create Top BarButton
        let barButton = UIButton(type: UIButtonType.custom)
        barButton.frame = CGRect(x:0, y:0, width:40, height:40);
        barButton.addSubview(nowPlayingImageView)
        nowPlayingImageView.center = barButton.center
        
        let barItem = UIBarButtonItem(customView: barButton)
        self.navigationItem.rightBarButtonItem = barItem
        
    }
    
    func startNowPlayingAnimation() {
        nowPlayingImageView.startAnimating()
    }
    
    //*****************************************************************
    // MARK: - Album Art
    //*****************************************************************
    
    func resetAlbumArtwork() {
        track.artworkLoaded = false
        track.artworkURL = currentStation.stationImageURL
        updateAlbumArtwork()
        stationDescLabel.isHidden = false
    }
    
    func updateAlbumArtwork() {
        
        if track.artworkURL.contains("http") {
            
            // Hide station description
            DispatchQueue.main.async() {
                self.stationDescLabel.isHidden = false
            }
            
            // Attempt to download album art from LastFM
            if let url = URL(string: track.artworkURL) {
                
                self.albumImageView.loadImageWithURL(url: url) {
                    (image) in
                    
                    // Update track struct
                    self.track.artworkImage = image
                    self.track.artworkLoaded = true
                    
                    // Turn off network activity indicator
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    // Animate artwork
                    self.albumImageView.animation = "wobble"
                    self.albumImageView.duration = 2
                    self.albumImageView.animate()
                    
                    // Call delegate function that artwork updated
                    self.delegate?.artworkDidUpdate(track: self.track)
                }
            }
            
            // Hide the station description to make room for album art
            if track.artworkLoaded && !self.justBecameActive {
                self.stationDescLabel.isHidden = true
                self.justBecameActive = false
            }
            
        } else if track.artworkURL != "" {
            // Local artwork
            self.albumImageView.image = UIImage(named: track.artworkURL)
            track.artworkImage = albumImageView.image
            track.artworkLoaded = true
            
            // Call delegate function that artwork updated
            self.delegate?.artworkDidUpdate(track: track)
            
        } else {
            // No Station or LastFM art found, use default art
            self.albumImageView.image = UIImage(named: "albumArt")
            track.artworkImage = albumImageView.image
        }
        
        // Force app to update display
        self.view.setNeedsDisplay()
    }
    
    // Call LastFM API to get album art url
    
    func queryAlbumArt() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Construct LastFM API Call URL
        let queryURL = URL(string: String(format: "http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=%@&artist=%@&track=%@&format=json", apiKey, track.artist, track.title))
        
        
        // Query API
        DataManager.loadDataFromURL(url: queryURL!, completion: { (data, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            let json = try? JSON(data: data!)
            
            // Get Largest Sized Image
            if let imageArray = json!["track"]["album"]["image"].array {
                
                let arrayCount = imageArray.count
                let lastImage = imageArray[arrayCount - 1]
                
                if let artURL = lastImage["#text"].string {
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    
                    // Check for Default Last FM Image
                    if artURL.contains("/noimage/") != nil {
                        self.resetAlbumArtwork()
                        
                    } else {
                        self.track.artworkURL = artURL
                        self.track.artworkLoaded = true
                        self.updateAlbumArtwork()
                    }
                    
                } else {
                    self.resetAlbumArtwork()
                }
            } else {
                self.resetAlbumArtwork()
            }

        })
  
    }
    
    //*****************************************************************
    // MARK: - Segue
    //*****************************************************************
    
     func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "InfoDetail" {
            let infoController = segue.destination as! InfoDetailViewController
            infoController.currentStation = currentStation
        }
    }
    
    @IBAction func infoButtonPressed(sender: UIButton) {
        performSegue(withIdentifier: "InfoDetail", sender: self)
    }
    
    
    //*****************************************************************
    // MARK: - MetaData Updated Notification
    //*****************************************************************
    
    func metadataUpdated(n: NSNotification)
    {
        if(radioPlayer.timedMetadata != nil && radioPlayer.timedMetadata.count > 0)
        {
            startNowPlayingAnimation()
            
            let firstMeta: MPTimedMetadata = radioPlayer.timedMetadata.first as! MPTimedMetadata
            let metaData = firstMeta.value as! String
            
            var stringParts = [String]()
            if metaData.contains(" - ") != nil {
                stringParts.append(metaData)
            } else {
                stringParts.append(metaData)
            }
            
            // Set artist & songvariables
            let currentSongName = track.title
            track.artist = stringParts[0]
            track.title = stringParts[0]
            
            if stringParts.count > 1 {
                track.title = stringParts[1]
            }
            
            if track.artist == "" && track.title == "" {
                track.artist = currentStation.stationDesc
                track.title = currentStation.stationName
            }
            
            DispatchQueue.main.async() {
                
                if currentSongName != self.track.title {
                    
                    if DEBUG_LOG {
                        print("METADATA artist: \(self.track.artist) | title: \(self.track.title)")
                    }
                    
                    // Update Labels
                    self.artistLabel.text = self.track.artist
                    self.songLabel.text = self.track.title
                    
                    // songLabel animation
                    self.songLabel.animation = "zoomIn"
                    self.songLabel.duration = 1.5
                    self.songLabel.damping = 1
                    self.songLabel.animate()
                    
                    // Update Stations Screen
                    self.delegate?.songMetaDataDidUpdate(track: self.track)
                    
                    // Query LastFM API for album art
                    self.resetAlbumArtwork()
                    self.queryAlbumArt()
                    
                }
            }
        }
    }
}
