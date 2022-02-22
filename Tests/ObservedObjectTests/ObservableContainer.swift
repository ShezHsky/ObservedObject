import ObservedObject

class ObservableContainer<T>: ObservedObject {
    
    @Observed var value: T
    
    init(value: T) {
        self.value = value
    }
    
}
