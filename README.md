# ReactiveMapper

[![Build Status](https://travis-ci.org/aschuch/ReactiveMapper.svg)](https://travis-ci.org/aschuch/ReactiveMapper)
![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)
![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)

A collection of reactive JSON parsing helpers for the [Mapper](https://github.com/lyft/mapper) JSON parser.

## Usage

### ReactiveSwift

ReactiveMapper supports JSON mapping for ReactiveSwift on values in a `Signal` or `SignalProducer` stream.

```swift
// Create models from a JSON dictionary
let jsonSignalProducer: SignalProducer<Any, NSError> = // ...
jsonSignalProducer.mapToType(User).startWithResult { result in
    // use the decoded User model
    let user: User? = result.value
}

// Create array of models from array of JSON dictionaries
let jsonSignalProducer: SignalProducer<Any, NSError> = // ...
jsonSignalProducer.mapToTypeArray(Task).startWithResult { result in
    // use the decoded array of Task models
    let tasks: [Task]? = result.value
}
```

### Model → JSON encoding

Mapper only supports decoding JSON to models, but not the other way around. ReactiveMapper introduces a simple protocol `Encodable` that models may adopt in order to encode themselves into a JSON representation.

```swift
struct Dog {
    let name: String
}

extension Dog: Encodeable {
    func encode() -> [String: Any] {
        return ["name": name]
    }
}

struct User {
    let id: String
    let name: String?
    let dog: Dog
}

extension User: Encodeable {
    func encode() -> [String: Any] {
        return [
            "id": id,
            "name": name ?? Encodeable.null,
            "dog": dog.encode()
        ]
    }
}

let dog = Dog(name: "Waldo")
let user = User(id: "1", name: nil, dog: dog)
let encoded = user.encode() // ["id": "1", "name": NSNull, "dog": ["name": "Waldo"]]
```





## Version Compatibility

Current Swift compatibility breakdown:

| Swift Version | Framework Version |
| ------------- | ----------------- |
| 3.x           | 1.x               |

[all releases]: https://github.com/aschuch/ReactiveMapper/releases

## Installation

#### Carthage

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "aschuch/ReactiveMapper”
```

Then run `carthage update`.

#### Manually

Just drag and drop the three `.swift` files in the `ReactiveMapper` folder into your project.

## Tests

Open the Xcode project and press `⌘-U` to run the tests.

Alternatively, all tests can be run from the terminal using xcodebuild.

```bash
xcodebuild \
  -project Example.xcodeproj \
  -scheme ReactiveMapper \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 6,OS=10.1' \
  test
```

## Contributing

* Create something awesome, make the code better, add some functionality,
  whatever (this is the hardest part).
* [Fork it](http://help.github.com/forking/)
* Create new branch to make your changes
* Commit all your changes to your branch
* Submit a [pull request](http://help.github.com/pull-requests/)


## Contact

Feel free to get in touch.

* Website: <https://schuch.me>
* Twitter: [@schuchalexander](http://twitter.com/schuchalexander)
