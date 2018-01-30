
import UIKit

class AnimationFrames {
    
    class func createFrames() -> [UIImage] {
    
        // Setup "Now Playing" Animation Bars
        var animationFrames = [UIImage]()
        for i in 0...3 {
            if let image = UIImage(named: "NowPlayingBars-\(i)") {
                animationFrames.append(image)
            }
        }
        
        for i in 1...2 {
            if let image = UIImage(named: "NowPlayingBars-\(i)") {
                animationFrames.append(image)
            }
        }
        return animationFrames
    }

}
