import Combine
import ObservedObject
import XCTest

class PropertyPublishingTests: XCTestCase {
    
    func testPublisherForPropertyPostsInitialValue_OptionsContainInitialValueByDefault() {
        let container = ObservableContainer(value: "Hello, World")
        
        var observed: String?
        let cancellable = container
            .publisher(for: \.value)
            .sink { (value) in
                observed = value
            }
        
        XCTAssertEqual("Hello, World", observed, "Should receive initial property value by default")
        
        cancellable.cancel()
    }
    
    func testPublisherForPropertyDoesNotPostInitialValue_OptionsDoNotContainInitialValue() {
        let container = ObservableContainer(value: "Hello, World")
        
        var observed: String?
        let cancellable = container
            .publisher(for: \.value, options: [])
            .sink { (value) in
                observed = value
            }
        
        XCTAssertNil(observed, "Not specifying `initial` should not provide initial value to subscriber")
        
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
    
    func testDoesNotPublishUpdatesWhenOtherPropertiesChange() {
        class MultipleValuesObservableContainer: ObservedObject {
            
            @Observed var stringValue: String
            @Observed var intValue: Int
            
            init(stringValue: String, intValue: Int) {
                self.stringValue = stringValue
                self.intValue = intValue
            }
            
        }
        
        let container = MultipleValuesObservableContainer(stringValue: "Hello, World", intValue: 42)
        
        var observedIntValues = [Int]()
        let subscription = container
            .publisher(for: \.intValue)
            .sink { (value) in
                observedIntValues.append(value)
            }
        
        container.stringValue = "Hello again, World"
        
        XCTAssertEqual([42], observedIntValues)
        
        subscription.cancel()
    }
    
}
