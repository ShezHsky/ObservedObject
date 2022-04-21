import Combine

extension Publishers {
    
    public struct PropertyPublisher2<Object, Value1, Value2>
        where Object: ObservedObject, Value1: Equatable, Value2: Equatable
    {
        
        private let pipelineFactory: PropertyPipelineFactory2<Value1, Value2>
        
        init(pipelineFactory: PropertyPipelineFactory2<Value1, Value2>) {
            self.pipelineFactory = pipelineFactory
        }
        
    }
    
}

extension Publishers.PropertyPublisher2: Publisher {
    
    public typealias Output = (Value1, Value2)
    public typealias Failure = Never
    
    public func receive<S>(subscriber: S) where S: Subscriber, S.Input == (Value1, Value2), S.Failure == Never {
        let subscription = Subscription(pipelineFactory: pipelineFactory, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
    private class Subscription<S>: Combine.Subscription
        where S: Combine.Subscriber, S.Input == Output, S.Failure == Failure
    {
        
        private let pipelineFactory: PropertyPipelineFactory2<Value1, Value2>
        private let subscriber: S
        private var propertyDidChange: Cancellable?
        
        init(pipelineFactory: PropertyPipelineFactory2<Value1, Value2>, subscriber: S) {
            self.pipelineFactory = pipelineFactory
            self.subscriber = subscriber
            
            propertyDidChange = pipelineFactory
                .makePipeline()
                .sink { (tuple) in
                    subscriber.receive(tuple)
                }
        }
        
        let combineIdentifier = CombineIdentifier()
        
        func request(_ demand: Subscribers.Demand) {
            
        }
        
        func cancel() {
            
        }
        
    }
    
}

struct PropertyPipelineFactory2<Value1, Value2> where Value1: Equatable, Value2: Equatable {
    
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
    
    func makePipeline() -> AnyPublisher<(Value1, Value2), Never> {
        _makePipeline()
    }
    
}
