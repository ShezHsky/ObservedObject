import Combine

extension Publishers {
    
    /// A `Publisher` that emits events when the value of an ``ObservedObject``'s property changes.
    ///
    /// Use this publisher to integrate a property that’s observable with ``@Observed`` into a Combine publishing
    /// chain. You can create a publisher of this type with the ``ObservedObject`` instance method
    /// ``ObservedObject.publisher(for:options:)``, passing in the key path.
    public struct ObservedPropertyPublisher<Object, Value> where Object: ObservedObject, Value: Equatable {
        
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
        
        private let object: Object
        private let keyPath: KeyPath<Object, Value>
        private let options: ObservedObjectPropertyOptions
        private let subscriber: S
        private var propertyDidChange: Cancellable?
        private var demand: Subscribers.Demand?
        
        init(object: Object, keyPath: KeyPath<Object, Value>, options: ObservedObjectPropertyOptions, subscriber: S) {
            self.object = object
            self.keyPath = keyPath
            self.options = options
            self.subscriber = subscriber
        }
        
        let combineIdentifier = CombineIdentifier()
        
        func request(_ demand: Subscribers.Demand) {
            self.demand = demand
            prepareUpstreamIfNeeded()
        }
        
        func cancel() {
            propertyDidChange?.cancel()
        }
        
        private func prepareUpstreamIfNeeded() {
            if propertyDidChange == nil {
                prepareUpstream()
            }
        }
        
        private func prepareUpstream() {
            let initialValuePublisher: AnyPublisher<Value, Never> = {
                let initialValue = object[keyPath: keyPath]
                if options.contains(.initial) {
                    return Just(initialValue).eraseToAnyPublisher()
                } else {
                    return Empty().eraseToAnyPublisher()
                }
            }()
            
            let propertyFromObjectPublisher = object.objectDidChange.map(keyPath)
            
            propertyDidChange = initialValuePublisher
                .merge(with: propertyFromObjectPublisher)
                .removeDuplicates()
                .sink { [weak self] (newValue) in
                    self?.updateSubscriber(newValue)
                }
        }
        
        private func updateSubscriber(_ newValue: Value) {
            guard var demand = demand else { return }
            
            if demand > .none {
                demand -= 1
                _ = subscriber.receive(newValue)
            }
            
            if demand == .none {
                subscriber.receive(completion: .finished)
            }
            
            self.demand = demand
        }
    }
    
}
