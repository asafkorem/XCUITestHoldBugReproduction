# XCUITest Bug Reproduction
#### `press(forDuration:thenDragTo:withVelocity:thenHoldForDuration:)`
Reproduction for long-press, drag &amp; hold bug in XCUITest API.

### Description
This API of XCUITest isn't working as expected, and this repo (demo application and UI test) reproduces the bug.
Apple Documentation: https://developer.apple.com/documentation/xctest/xcuicoordinate/3551692-press
```swift
func press(
  forDuration duration: TimeInterval, 
  thenDragTo otherCoordinate: XCUICoordinate, 
  withVelocity velocity: XCUIGestureVelocity, 
  thenHoldForDuration holdDuration: TimeInterval
)
```

### The Bug

When using the above API with a non-zero `holdDuration` value, there is no effect, and no long press (A.K.A. "hold") is made at the end of the dragging.

#### The Expected Behaviour

This is when I'm dragging my element **manually** (works as expected, the label changes its value to "Success!"):

https://user-images.githubusercontent.com/55082339/166443733-406ef4b0-958a-46bd-af64-27b3737351d0.mp4

Download from here: [Video.mp4](Video.mp4)

#### The Existing Behaviour

This test ([here](https://github.com/asafkorem/XCUITestHoldBugReproduction/blob/main/XCUITestBugReproductionUITests/XCUITestBugReproductionUITests.swift)):
```swift
func testLongPressDragAndHold() throws {
  let app = XCUIApplication()
  app.launch()

  let button = app.buttons["button"]
  XCTAssert(button.waitForExistence(timeout: 5))

  let label = app.staticTexts["label"]
  XCTAssert(label.exists)

  button.press(forDuration: 1, thenDragTo: label, withVelocity: .default, thenHoldForDuration: 2)

  // The following assertion fails with the message:
  // XCTAssertEqual failed: ("Hold 1 second") is not equal to ("Success!")
  XCTAssertEqual(label.label, "Success!")
}
```

Results with an assertion error (`XCTAssertEqual failed: ("Hold 1 second") is not equal to ("Success!")`) when running on iPhone Simulator. 

Visually, this happens:

https://user-images.githubusercontent.com/55082339/166443746-58a181a0-603c-4379-ad9e-35bd2c85ffeb.mp4

Download from here: [UITests-Video.mp4](UITests-Video.mp4)


You may clone this repo, and execute the reproduction test from this file: [XCUITestBugReproductionUITests/XCUITestBugReproductionUITests.swift](https://github.com/asafkorem/XCUITestHoldBugReproduction/blob/main/XCUITestBugReproductionUITests/XCUITestBugReproductionUITests.swift)
