import Combine

struct PropertyPipelineFactory2<Value1, Value2>: PipelineFactory where Value1: Equatable, Value2: Equatable {
    
    private let _makePipeline: () -> AnyPublisher<(Value1, Value2), Never>
    
    private static func makeInitialValuePublisher<Object, Value>(
        from object: Object,
        keyPath: KeyPath<Object, Value>,
        options: PropertyObservationOptions
    ) -> AnyPublisher<Value, Never> {
        let initialValue = object[keyPath: keyPath]
        if options.contains(.initial) {
            return Just(initialValue).eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }
    
    init<Object>(
        object: Object,
        firstKeyPath: KeyPath<Object, Value1>,
        secondKeyPath: KeyPath<Object, Value2>
    ) where Object: ObservedObject {
        _makePipeline = {
            let firstInitialValuePublisher = Self.makeInitialValuePublisher(from: object, keyPath: firstKeyPath, options: [.initial])
            let firstPropertyFromObjectPublisher = object.objectDidChange.map(firstKeyPath)
            let firstKeyPathUpstream = firstInitialValuePublisher
                .merge(with: firstPropertyFromObjectPublisher)
            
            let secondInitialValuePublisher = Self.makeInitialValuePublisher(from: object, keyPath: secondKeyPath, options: [.initial])
            let secondPropertyFromObjectPublisher = object.objectDidChange.map(secondKeyPath)
            let secondKeyPathUpstream = secondInitialValuePublisher
                .merge(with: secondPropertyFromObjectPublisher)
            
            return Publishers.CombineLatest(firstKeyPathUpstream, secondKeyPathUpstream)
                .eraseToAnyPublisher()
        }
    }
    
    typealias Output = (Value1, Value2)
    typealias Pipeline = AnyPublisher<(Value1, Value2), Never>
    
    func makePipeline() -> AnyPublisher<(Value1, Value2), Never> {
        _makePipeline()
    }
    
}
