import UIKit
import HealthKit

class ViewController: UIViewController {
    let healthStore = HKHealthStore()
    var voltageValues: [Double] = []
    let ecgLabel = UILabel() // Add a UILabel to display ECG data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        ecgLabel.frame = CGRect(x: 20, y: 50, width: 300, height: 500)
        ecgLabel.numberOfLines = 0
        view.addSubview(ecgLabel)
        
        requestHealthKitAuthorization()
    }
    
    func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        let ecgType = HKObjectType.electrocardiogramType()
        let typesToRead: Set<HKObjectType> = [ecgType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("Authorization succeeded")
                self.fetchECGData { ecgSamples, error in
                    if let ecgSamples = ecgSamples {
                        print("Fetched ECG data: \(ecgSamples)")
                        for ecgSample in ecgSamples {
                            self.fetchECGDataPoints(ecgSample: ecgSample)
                        }
                    } else if let error = error {
                        print("Error fetching ECG data: \(error.localizedDescription)")
                    }
                }
            } else {
                if let error = error {
                    print("Authorization failed: \(error.localizedDescription)")
                } else {
                    print("Authorization failed")
                }
            }
        }
    }
    
    func fetchECGData(completion: @escaping ([HKElectrocardiogram]?, Error?) -> Void) {
        let ecgType = HKObjectType.electrocardiogramType()
        
        let query = HKSampleQuery(sampleType: ecgType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
            guard let samples = samples as? [HKElectrocardiogram] else {
                completion(nil, error)
                return
            }
            completion(samples, nil)
        }
        healthStore.execute(query)
    }
    
    func fetchECGDataPoints(ecgSample: HKElectrocardiogram) {
        let query = HKElectrocardiogramQuery(ecgSample) { (query, result) in
            switch result {
            case .measurement(let measurement):
                if let leadIQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI) {
                    let leadIValue = leadIQuantity.doubleValue(for: HKUnit.voltUnit(with: .milli))
                    self.voltageValues.append(leadIValue)
                    print("Lead I Voltage: \(leadIValue) mV")
                }
                DispatchQueue.main.async {
                    self.ecgLabel.text = self.voltageValues.map { "\($0) mV" }.joined(separator: "\n")
                }
            case .done:
                print("Finished retrieving all data points")
            case .error(let error):
                print("Error retrieving data points: \(error.localizedDescription)")
            @unknown default:
                fatalError("Unknown case in ECG query result")
            }
        }
        healthStore.execute(query)
    }

    func getVoltageValues() -> [Double] {
        return voltageValues
    }
}

