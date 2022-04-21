import Combine

class PropertySubscription<Factory: PipelineFactory, S: Combine.Subscriber>: Combine.Subscription
    where Factory.Pipeline.Output == S.Input, Factory.Pipeline.Failure == S.Failure
{
    
    private let pipelineFactory: Factory
    private let subscriber: S
    private var demand: Subscribers.Demand?
    private var propertyDidChange: Cancellable?
    
    init(pipelineFactory: Factory, subscriber: S) {
        self.pipelineFactory = pipelineFactory
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
        propertyDidChange = pipelineFactory
            .makePipeline()
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
