import Combine

class PropertyChangedSubscription<Upstream: Publisher, S: Subscriber>: Subscription
    where Upstream.Failure == Never, S.Input == Upstream.Output, S.Failure == Upstream.Failure
{
    
    private let upstream: Upstream
    private let subscriber: S
    private var demand: Subscribers.Demand?
    private var propertyDidChange: Cancellable?
    
    init(upstream: Upstream, subscriber: S) {
        self.upstream = upstream
        self.subscriber = subscriber
    }
    
    let combineIdentifier = CombineIdentifier()
    
    func request(_ demand: Subscribers.Demand) {
        self.demand = demand
        prepareUpstream()
    }
    
    func cancel() {
        propertyDidChange?.cancel()
    }
    
    private func prepareUpstream() {
        guard propertyDidChange == nil else { return }
        
        propertyDidChange = upstream
            .sink { [weak self] (newValue) in
                self?.updateSubscriber(newValue: newValue)
            }
    }
    
    private func updateSubscriber(newValue: S.Input) {
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
