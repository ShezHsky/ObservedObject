import Combine

struct PropertyPipelineFactory<Value>: PipelineFactory {
    
    private let _makePipeline: () -> AnyPublisher<Value, Never>
    
    private static func makeInitialValuePublisher<Object>(
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
        keyPath: KeyPath<Object, Value>,
        options: PropertyObservationOptions,
        propertyChangedBy equalityComparator: @escaping (Value, Value) -> Bool
    ) where Object: ObservedObject {
        _makePipeline = {
            let propertyFromObjectPublisher = object.objectDidChange.map(keyPath)
            
            return Self.makeInitialValuePublisher(from: object, keyPath: keyPath, options: options)
                .merge(with: propertyFromObjectPublisher)
                .removeDuplicates(by: equalityComparator)
                .eraseToAnyPublisher()
        }
    }
    
    init<Object>(
        object: Object,
        keyPath: KeyPath<Object, Value>,
        options: PropertyObservationOptions
    ) where Object: ObservedObject, Value: Equatable {
        _makePipeline = {
            let propertyFromObjectPublisher = object.objectDidChange.map(keyPath)
            
            return Self.makeInitialValuePublisher(from: object, keyPath: keyPath, options: options)
                .merge(with: propertyFromObjectPublisher)
                .removeDuplicates()
                .eraseToAnyPublisher()
        }
    }
    
    typealias Pipeline = AnyPublisher<Value, Never>
    
    func makePipeline() -> AnyPublisher<Value, Never> {
        _makePipeline()
    }
    
}
