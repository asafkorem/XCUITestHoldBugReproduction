//
//  LongPressAndDragViewController.swift (XCUITestBugReproduction)
//  Created by Asaf Korem (Wix.com) on 2022.
//

import Foundation
import UIKit

class LongPressAndDragViewController: UIViewController {
  @IBOutlet var longPressAndDragButton: UIButton!
  @IBOutlet var label: UILabel!

  var holdArea = CGRect.zero

  var longPressGestureRecognizer: UILongPressGestureRecognizer?
  var panGestureRecognizer: UIPanGestureRecognizer?

  var allowDragging = false

  override func viewDidLoad() {
    super.viewDidLoad()
    setupLongPressGestureRecognizer()
    setupDragGestureRecognizer()
  }

  private func setupLongPressGestureRecognizer() {
    let longPressGestureRecognizer = UILongPressGestureRecognizer(
      target: self,
      action: #selector(pressed)
    )
    longPressGestureRecognizer.delegate = self
    longPressAndDragButton.addGestureRecognizer(longPressGestureRecognizer)

    self.longPressGestureRecognizer = longPressGestureRecognizer
  }

  private func setupDragGestureRecognizer() {
    let panGestureRecognizer = UIPanGestureRecognizer(
      target: self,
      action: #selector(panned)
    )
    panGestureRecognizer.delegate = self
    longPressAndDragButton.addGestureRecognizer(panGestureRecognizer)

    self.panGestureRecognizer = panGestureRecognizer
  }

  @objc private func pressed(_ sender: UIGestureRecognizer) {
    changeButtonToDraggableState()
    longPressAndDragButton.removeGestureRecognizer(sender)

    label.text = "Drag here and hold"
  }

  private func changeButtonToDraggableState() {
    longPressAndDragButton.translatesAutoresizingMaskIntoConstraints = true
    allowDragging = true

    longPressAndDragButton.layer.add(makeShakeAnimation(), forKey:"animate")

    longPressAndDragButton.setNeedsLayout()
    longPressAndDragButton.layoutIfNeeded()
  }

  private func makeShakeAnimation() -> CABasicAnimation {
    let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
    shakeAnimation.duration = 0.05
    shakeAnimation.repeatCount = 4
    shakeAnimation.autoreverses = true
    shakeAnimation.duration = 0.2
    shakeAnimation.repeatCount = 99999

    let startAngle: Float = -0.035
    let stopAngle = -startAngle

    shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
    shakeAnimation.toValue = NSNumber(value: 3 * stopAngle as Float)
    shakeAnimation.autoreverses = true
    shakeAnimation.timeOffset = 290 * drand48()

    return shakeAnimation
  }

  static var holdStartDate: Date?

  @objc private func panned(_ sender: UIPanGestureRecognizer) {
    guard allowDragging else {
      return
    }

    if (sender.state == .ended) {
      label.text = "Drag here and hold"
      Self.holdStartDate = nil
    }

    if (longPressAndDragButton.frame.intersects(makeHoldArea())) {
      if Self.holdStartDate == nil {
        label.text = "Hold"
        Self.holdStartDate = Date.now
      } else if (abs(Self.holdStartDate!.timeIntervalSinceNow) > 1) {
        // After hold for 1 second...
        label.text = "Success!"
      }
    } else {
      label.text = "Drag here and hold"
      Self.holdStartDate = nil
    }

    longPressAndDragButton.center += sender.translation(in: longPressAndDragButton)
    sender.setTranslation(.zero, in: longPressAndDragButton)
  }

  private func makeHoldArea() -> CGRect {
    self.holdArea = self.holdArea.union(label.frame)
    return self.holdArea
  }
}

extension LongPressAndDragViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    if (gestureRecognizer == longPressGestureRecognizer
        && otherGestureRecognizer == panGestureRecognizer) {
      return true
    }

    if (gestureRecognizer == panGestureRecognizer
        && otherGestureRecognizer == longPressGestureRecognizer) {
      return true
    }

    return false
  }

  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return gestureRecognizer == longPressGestureRecognizer
    && otherGestureRecognizer == panGestureRecognizer
  }
}

extension CGPoint {
  static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  static func +=(lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs + rhs
  }
}
