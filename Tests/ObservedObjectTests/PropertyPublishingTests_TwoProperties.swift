import Combine
import ObservedObject
import XCTest

class PropertyPublishingTests_TwoProperties: XCTestCase {
    
    private class ContainerWithTwoProperties<A, B>: ObservedObject {
        @Observed var first: A?
        @Observed var second: B?
    }
    
    func testPublishingTwoProperties_InitialValue() {
        let container = ContainerWithTwoProperties<Int, Int>()
        container.first = 1
        container.second = 2
        
        var observed: (Int?, Int?)?
        let cancellable = container
            .publisher(for: \.first, \.second)
            .sink { (first, second) in
                observed = (first, second)
            }
        
        XCTAssertEqual(1, observed?.0)
        XCTAssertEqual(2, observed?.1)
        
        cancellable.cancel()
    }
    
    func testPublishingTwoProperties_FirstValueChanges() {
        let container = ContainerWithTwoProperties<Int, Int>()
        container.first = 1
        container.second = 2
        
        var observed: (Int?, Int?)?
        let cancellable = container
            .publisher(for: \.first, \.second)
            .sink { (first, second) in
                observed = (first, second)
            }
        
        container.first = 10
        
        XCTAssertEqual(10, observed?.0)
        XCTAssertEqual(2, observed?.1)
        
        cancellable.cancel()
    }
    
    func testPublishingTwoProperties_SecondValueChanges() {
        let container = ContainerWithTwoProperties<Int, Int>()
        container.first = 1
        container.second = 2
        
        var observed: (Int?, Int?)?
        let cancellable = container
            .publisher(for: \.first, \.second)
            .sink { (first, second) in
                observed = (first, second)
            }
        
        container.second = 20
        
        XCTAssertEqual(1, observed?.0)
        XCTAssertEqual(20, observed?.1)
        
        cancellable.cancel()
    }
    
    func testPublisherWaitsUntilRequestBeforeFormingPipeline() {
        let container = ContainerWithTwoProperties<Int, Int>()
        let subscriber = SpySubscriber<(Int?, Int?), Never>()
        
        container
            .publisher(for: \.first, \.second)
            .subscribe(subscriber)
        
        XCTAssertTrue(subscriber.receiveInputs.isEmpty)
    }
    
    func testOnlyRequestingOneValueDoesNotProvideAnyExtraUpdates() throws {
        let container = ContainerWithTwoProperties<Int, Int>()
        let subscriber = SpySubscriber<(Int?, Int?), Never>()
        
        container
            .publisher(for: \.first, \.second)
            .subscribe(subscriber)
        
        subscriber.subscription?.request(.max(1))
        
        container.first = 10
        let expectedCompletion = Subscribers.Completion<Never>.finished
        
        let receivedInput = try XCTUnwrap(subscriber.receiveInputs.first)
        
        XCTAssertEqual(nil, receivedInput.0)
        XCTAssertEqual(nil, receivedInput.1)
        XCTAssertEqual(expectedCompletion, subscriber.completion)
    }
    
    func testPublisherForPropertyDoesNotPostInitialValue_OptionsDoNotContainInitialValue() {
        let container = ContainerWithTwoProperties<Int, Int>()
        
        var observed: (Int?, Int?)?
        let cancellable = container
            .publisher(for: \.first, \.second, options: [])
            .sink { (value) in
                observed = value
            }
        
        XCTAssertNil(observed, "Not specifying `initial` should not provide initial value to subscriber")
        
        cancellable.cancel()
    }
    
    func testDoesNotRepublishTupleWhenFirstElementDoesNotActuallyChangeValue() {
        let container = ContainerWithTwoProperties<Int, Int>()
        container.first = 10
        
        var observed: (Int?, Int?)?
        let cancellable = container
            .publisher(for: \.first, \.second, options: [])
            .sink { (value) in
                observed = value
            }
        
        container.first = 10
        
        XCTAssertNil(observed, "First value did not actually change - Publisher should not emit event")
        
        cancellable.cancel()
    }
    
}
