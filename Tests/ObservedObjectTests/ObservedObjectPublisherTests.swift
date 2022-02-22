import Combine
import ObservedObject
import XCTest

class ObservedObjectPublisherTests: XCTestCase {
    
    func testNotifiesSubscribersWhenSendingEvent() {
        let object = ObservableContainer(value: "Hello, World!")
        let publisher = ObservedObjectPublisher(object)
        
        var observedObject: ObservableContainer<String>?
        let cancellable = publisher
            .sink { (object) in
                observedObject = object
            }
        
        defer {
            cancellable.cancel()
        }
        
        XCTAssertNil(observedObject)
        
        publisher.send()
        
        XCTAssertIdentical(object, observedObject)
    }
    
}
