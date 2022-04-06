import Combine
import ObservedObject
import XCTest

class PropertyDidChangeTests: XCTestCase {
    
    func testPublisherForPropertyPostsInitialValue() {
        let container = ObservableContainer(value: "Hello, World")
        
        var observed: String?
        let cancellable = container
            .publisher(for: \.value)
            .sink { (value) in
                observed = value
            }
        
        XCTAssertEqual("Hello, World", observed)
        
        cancellable.cancel()
    }
    
    func testPublisherForPropertyPostsUpdatedValues() {
        let container = ObservableContainer(value: "Hello, World")
        
        var observed: String?
        let cancellable = container
            .publisher(for: \.value)
            .sink { (value) in
                observed = value
            }
        
        container.value = "Hello again, World"
        
        XCTAssertEqual("Hello again, World", observed)
        
        cancellable.cancel()
    }
    
    func testPublisherForProperty_CancellationDoesNotLeakObject() {
        weak var container: ObservableContainer<String>?
        
        autoreleasepool {
            let strongContainer = ObservableContainer(value: "Hello, World")
            container = strongContainer
            
            let cancellable = strongContainer
                .publisher(for: \.value)
                .sink { (_) in }
            
            cancellable.cancel()
        }
        
        XCTAssertNil(container)
    }
    
}
