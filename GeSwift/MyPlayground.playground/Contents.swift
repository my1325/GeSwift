import UIKit

var str = "Hello, playground"
let thread = Thread {
    for index in 0 ..< 10 {
        sleep(2)
        print(index)
    }
}

thread.cancel()
