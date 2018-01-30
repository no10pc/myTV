
import UIKit

class InfoDetailViewController: UIViewController {
    
    @IBOutlet weak var stationImageView: UIImageView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var stationDescLabel: UILabel!
    @IBOutlet weak var stationLongDescTextView: UITextView!
    @IBOutlet weak var okayButton: UIButton!
    
    var currentStation: RadioStation!
    var downloadTask: URLSessionDownloadTask?

    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStationText()
        setupStationLogo()
    }

    deinit {
        // Be a good citizen.
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    //*****************************************************************
    // MARK: - UI Helpers
    //*****************************************************************
    
    func setupStationText() {
        
        // Display Station Name & Short Desc
        stationNameLabel.text = currentStation.stationName
        stationDescLabel.text = currentStation.stationDesc
        
        // Display Station Long Desc
        if currentStation.stationLongDesc == "" {
            loadDefaultText()
        } else {
            stationLongDescTextView.text = currentStation.stationLongDesc
        }
    }
    
    func loadDefaultText() {
        // Add your own default ext
        stationLongDescTextView.text = "Swift TV izliyorsunuz. Bu tatlı küçük projeyi hemen arkadaşlarınıza söyleyin!"
    }
    
    func setupStationLogo() {
        
        // Display Station Image/Logo
        let imageURL = currentStation.stationImageURL
        
        if imageURL.contains("http"){
            // Get station image from the web, iOS should cache the image
            if let url = URL(string: currentStation.stationImageURL) {
                stationImageView.loadImageWithURL(url: url as URL) { _ in }
            }
            
        } else if imageURL != "" {
            // Get local station image
            stationImageView.image = UIImage(named: imageURL)
            
        } else {
            // Use default image if station image not found
            stationImageView.image = UIImage(named: "stationImage")
        }
        
        // Apply shadow to Station Image
        stationImageView.applyShadow()
    }
    
    //*****************************************************************
    // MARK: - IBActions
    //*****************************************************************
    
    @IBAction func okayButtonPressed(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
