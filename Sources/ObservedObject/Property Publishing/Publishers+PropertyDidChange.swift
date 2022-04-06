import Combine

extension Publishers {
    
    /// A `Publisher` that emits events when the value of an ``ObservedObject``'s property changes.
    ///
    /// Use this publisher to integrate a property that’s observable with ``@Observed`` into a Combine publishing
    /// chain. You can create a publisher of this type with the ``ObservedObject`` instance method
    /// ``publisher(for:options:)``, passing in the key path.
    public struct ObservedPropertyPublisher<Object, Value> where Object: ObservedObject {
        
        private let object: Object
        private let keyPath: KeyPath<Object, Value>
        private let options: ObservedObjectPropertyOptions
        
        init(object: Object, keyPath: KeyPath<Object, Value>, options: ObservedObjectPropertyOptions) {
            self.object = object
            self.keyPath = keyPath
            self.options = options
        }
        
    }
    
}

extension Publishers.ObservedPropertyPublisher: Publisher {
    
    public typealias Output = Value
    public typealias Failure = Never
    
    public func receive<S>(subscriber: S) where S: Subscriber, S.Input == Value, S.Failure == Never {
        let subscription = Subscription(object: object, keyPath: keyPath, options: options, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
    private class Subscription<S>: Combine.Subscription
        where S: Combine.Subscriber, S.Input == Output, S.Failure == Failure
    {
        
        private var object: Object!
        private let keyPath: KeyPath<Object, Value>
        private let options: ObservedObjectPropertyOptions
        private let subscriber: S
        private var propertyDidChange: Cancellable?
        
        private var currentValue: Value {
            object[keyPath: keyPath]
        }
        
        init(object: Object, keyPath: KeyPath<Object, Value>, options: ObservedObjectPropertyOptions, subscriber: S) {
            self.object = object
            self.keyPath = keyPath
            self.options = options
            self.subscriber = subscriber
            
            propertyDidChange = object
                .objectDidChange
                .map(keyPath)
                .sink { [weak self] (newValue) in
                    self?.updateSubscriber(value: newValue)
                }
            
            publishInitialValue()
        }
        
        private func publishInitialValue() {
            if options.contains(.initial) {
                updateSubscriber(value: currentValue)
            }
        }
        
        private func updateSubscriber(value: Value) {
            _ = subscriber.receive(value)
        }
        
        let combineIdentifier = CombineIdentifier()
        
        func request(_ demand: Subscribers.Demand) {
            
        }
        
        func cancel() {
            
        }
        
    }
    
}
