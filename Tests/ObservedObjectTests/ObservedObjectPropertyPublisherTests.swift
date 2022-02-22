import Combine
import ObservedObject
import XCTest

class ObservedObjectPropertyPublisherTests: XCTestCase {
    
    func testAccessingValueUsingObservedPublisher_InitialValue() {
        let observable = ObservableContainer(value: "Hello, World!")
        let publisher = observable.$value
        
        var observedValue: String?
        let cancellable = publisher
            .sink { (value) in
                observedValue = value
            }
        
        defer {
            cancellable.cancel()
        }
        
        XCTAssertEqual("Hello, World!", observedValue)
    }
    
    func testAccessingValueUsingObservedPublisher_UpdatedValue() {
        let observable = ObservableContainer(value: "Hello, World!")
        let publisher = observable.$value
        
        var observedValue: String?
        let cancellable = publisher
            .sink { (value) in
                observedValue = value
            }
        
        defer {
            cancellable.cancel()
        }
        
        observable.value = "Goodbye, World!"
        
        XCTAssertEqual("Goodbye, World!", observedValue)
    }
    
    func testObjectDidChangeIsInvokedAfterPropertySet() {
        enum Event: Equatable {
            case publishedValue(String)
            case objectDidChange
        }
        
        let observable = ObservableContainer(value: "Hello, World!")
        let publisher = observable.$value
        
        var observedEvents = [Event]()
        var cancellables = Set<AnyCancellable>()
        
        publisher
            .sink { (value) in
                observedEvents.append(.publishedValue(value))
            }
            .store(in: &cancellables)
        
        observable
            .objectDidChange
            .sink { (_) in
                observedEvents.append(.objectDidChange)
            }
            .store(in: &cancellables)
        
        // 1. Initial value (testAccessingValueUsingObservedPublisher_InitialValue)
        // 2. Updated value (testAccessingValueUsingObservedPublisher_UpdatedValue)
        // 3. objectDidChange
        let expected: [Event] = [.publishedValue("Hello, World!"), .publishedValue("Goodbye, World!"), .objectDidChange]
        
        observable.value = "Goodbye, World!"
        
        XCTAssertEqual(expected, observedEvents)
    }
    
}
