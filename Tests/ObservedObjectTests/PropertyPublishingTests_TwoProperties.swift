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
    
}
