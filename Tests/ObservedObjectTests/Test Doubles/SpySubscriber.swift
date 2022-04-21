import Combine

class SpySubscriber<T, U>: Combine.Subscriber where U: Error {
            
    typealias Input = T
    typealias Failure = U
    
    private(set) var subscription: Subscription?
    func receive(subscription: Subscription) {
        self.subscription = subscription
    }
    
    private(set) var completion: Subscribers.Completion<U>?
    func receive(completion: Subscribers.Completion<U>) {
        self.completion = completion
    }
    
    private(set) var receiveInputs = [T]()
    var demand: Subscribers.Demand = .unlimited
    func receive(_ input: T) -> Subscribers.Demand {
        receiveInputs.append(input)
        return demand
    }
    
}
