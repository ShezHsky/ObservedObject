# ObservedObject

Model your application code as a function of state change.

## Overview

The ObservedObject package provides a convenient mechanism to observe objects as they change that is compatible with Combine pipelines. The API is very similar to `ObservableObject` with the key difference being subscribers are notified **after** the upstream object has changed, rather than before. This enables modelling pipelines as a function of an object update using its new state, in place of waiting for the values to be provided later.

The `Observed` property wrapper provides a similar convenience wrapper to the `Published` property wrapper used by `ObservableObject`. Annotating specific properties of an `ObservedObject` with this wrapper will automatically notify any subscribers _after_ the property value has been set on the object:

```swift
class Weather {
    @Observed var temperature: Double
    init(temperature: Double) {
        self.temperature = temperature
    }
}
let weather = Weather(temperature: 20)
cancellable = weather.$temperature
    .sink() {
        print ("Temperature now: \($0)")
}

weather.temperature = 25

// Prints:
// Temperature now: 20.0
// Temperature now: 25.0
```

## Notes

This package is intended for applications that use Combine pipelines across wider system boundaries without the desire to pollute contracts with `AnyPublisher`. For example, in response to the completion of a CloudKit fetch operation a local database is modified and saved. The model objects are updated by reading the contents of the database, however are typed to a protocol between module boundaries.
