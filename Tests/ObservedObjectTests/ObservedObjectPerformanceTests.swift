import ObservedObject
import XCTest

class ObservedObjectPerformanceTests: XCTestCase {
    
    func testManagingThousandsOfPublishersDoesNotDiminishRuntimePerformance() {
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        
        measure(metrics: [XCTClockMetric()], options: options) {
            let models = (0..<5000).map({ (_) in ObservableContainer(value: "Hello, World!") })
            _ = models.map(\.objectDidChange)
        }
    }
    
}
