import Combine

extension Publishers {
    
    /// A `Publisher` that emits events when the value of an ``ObservedObject``'s property changes.
    ///
    /// Use this publisher to integrate a property that’s observable with ``@Observed`` into a Combine publishing
    /// chain. You can create a publisher of this type with the ``ObservedObject`` instance method
    /// ``ObservedObject.publisher(for:options:)``, passing in the key path.
    public struct PropertyPublisher<Object, Value> where Object: ObservedObject {
        
        private let pipelineFactory: PropertyPipelineFactory<Value>
        
        init(pipelineFactory: PropertyPipelineFactory<Value>) {
            self.pipelineFactory = pipelineFactory
        }
        
    }
    
}

extension Publishers.PropertyPublisher: Publisher {
    
    public typealias Output = Value
    public typealias Failure = Never
    
    public func receive<S>(subscriber: S) where S: Subscriber, S.Input == Value, S.Failure == Never {
        let subscription = PropertySubscription(pipelineFactory: pipelineFactory, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
}
