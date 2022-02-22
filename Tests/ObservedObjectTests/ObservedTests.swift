import Combine
import ObservedObject
import XCTest

class ObservedTests: XCTestCase {
    
    func testSettingValueOfObservedPropertySignalsDidChange() {
        let observable = ObservableContainer(value: "Hello, world")
        
        var witnessedChange: String?
        let cancellable = observable
            .objectDidChange
            .sink { (object) in
                witnessedChange = object.value
            }
        
        defer {
            cancellable.cancel()
        }
        
        observable.value = "Goodbye, World"
        
        XCTAssertEqual("Goodbye, World", witnessedChange)
    }
    
}
