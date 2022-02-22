import ObservedObject
import XCTest

class ObservedObjectLeakTests: XCTestCase {
    
    func testPublishersForObservableModelsDoNotOutliveTheirObjects() {
        let options = XCTMeasureOptions()
        options.iterationCount = 100
        
        measure(metrics: [XCTMemoryMetric()], options: options) {
            let models = (0..<1000).map({ (_) in ObservableContainer(value: "Hello, World!") })
            _ = models.map(\.objectDidChange)
        }
    }
    
}
