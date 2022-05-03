//
//  XCUITestBugReproductionUITests.swift (XCUITestBugReproduction)
//  Created by Asaf Korem (Wix.com) on 2022.
//

import XCTest

class XCUITestBugReproductionUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

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
}
