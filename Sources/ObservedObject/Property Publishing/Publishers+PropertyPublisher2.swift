import Combine

extension Publishers {
    
    /// A `Publisher` that emits events when the values of two ``ObservedObject``'s properties change.
    ///
    /// Use this publisher to integrate two properties that are observable with ``@Observed`` into a Combine publishing
    /// chain. You can create a publisher of this type with the ``ObservedObject`` instance method
    /// ``ObservedObject.publisher(for:options:)``, passing in the key paths.
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
        let subscription = PropertySubscription(pipelineFactory: pipelineFactory, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
}
