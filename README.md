# Ditto
A lightweight routing system written in Swift.

## Usage

```swift
let router = Router<Void>(schemes: ["ditto"])
let endpoint = Endpoint(url: URL(string: "ditto://foo/:bar")!)
let route = Route<Void>(endpoint: endpoint) { context in
    guard let bar: Int = try? context.argument(forKey: "bar") else {
        return false
    }
    print(bar) // 233
    return true
}

router.register(route)

let url = URL(string: "ditto://foo/233")!
if router.responds(to: url) {
    router.route(to: url)
}
```

## Advanced

```swift
class Router {
    // Register home page route use silgen prefix `ditto:`
    // alligator://home
    // https://www.alligator.com/home
    @_silgen_name("ditto:/home")
    func home(context: Context<RoutingCoordinator>) -> Bool {
        return true
    }
}
```

## License

Ditto is available under the MIT License. See the LICENSE file for more info.