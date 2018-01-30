
import UIKit

struct DataManager {
    
    //*****************************************************************
    // Helper Class to get either local or remote JSON
    //*****************************************************************
    
    static func getStationDataWithSuccess(success: @escaping ((_ metaData: Data?) -> Void)) {
        
        if useLocalStations {
            getDataFromFileWithSuccess() { data in
                success(data)
            }
        } else {
            loadDataFromURL(url: URL(string: stationDataURL)!) { data, error in
                if let urlData = data {
                    success(urlData)
                }
            }
        }
    }
    
    //*****************************************************************
    // Load local JSON Data
    //*****************************************************************
    
    static func getDataFromFileWithSuccess(success: (_ data: Data?) -> Void) {
        
       
            
        guard let filePathURL = Bundle.main.url(forResource: "stations", withExtension: "json") else {
            success(nil)
            return
        }
        do {
            let data = try Data(contentsOf:filePathURL,
                options: .uncached)
            success(data)
        } catch {
            fatalError()
        }
        
    }
    
    //*****************************************************************
    // Get LastFM Data
    //*****************************************************************
    

    
    //*****************************************************************
    // REUSABLE DATA/API CALL METHOD
    //*****************************************************************
    
    static func loadDataFromURL(url: URL, completion: @escaping (_ data: Data?,_ error: Error?) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess          = true
        sessionConfig.timeoutIntervalForRequest     = 15
        sessionConfig.timeoutIntervalForResource    = 30
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        let session = URLSession(configuration: sessionConfig)
        
        // Use NSURLSession to get data from an NSURL
        let loadDataTask = session.dataTask(with: url){ data, response, error in
            
            guard error == nil else {
                completion(nil, error!)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                200...299 ~= httpResponse.statusCode else {
                    completion(nil, nil)
                    return
            }
            guard let data = data else {
                completion(nil, nil)
                return
            }
            completion(data, nil)
        }
        
        loadDataTask.resume()
    }
}
