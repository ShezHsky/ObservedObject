import Combine
import ObservedObject
import XCTest

class PropertyPublishingTests_ThreeProperties: XCTestCase {
    
    private class ContainerWithThreeProperties<A, B, C>: ObservedObject {
        @Observed var first: A?
        @Observed var second: B?
        @Observed var third: C?
    }
    
    func testPublishingTwoProperties_InitialValue() {
        let container = ContainerWithThreeProperties<Int, Int, Int>()
        container.first = 1
        container.second = 2
        container.third = 3
        
        var observed: (Int?, Int?, Int?)?
        let cancellable = container
            .publisher(for: \.first, \.second, \.third)
            .sink { (first, second, third) in
                observed = (first, second, third)
            }
        
        XCTAssertEqual(1, observed?.0)
        XCTAssertEqual(2, observed?.1)
        XCTAssertEqual(3, observed?.2)
        
        cancellable.cancel()
    }
    
}
