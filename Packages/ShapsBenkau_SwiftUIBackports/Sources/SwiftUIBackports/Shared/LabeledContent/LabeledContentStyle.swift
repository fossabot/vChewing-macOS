// (c) 2022 and onwards Shaps Benkau (MIT License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import SwiftUI

@available(macOS 10.15, *)
@available(iOS, deprecated: 16)
@available(tvOS, deprecated: 16)
@available(macOS, deprecated: 13)
@available(watchOS, deprecated: 9)
extension Backport where Wrapped: View {
  /// Sets a style for labeled content.
  public func labeledContentStyle<S>(_ style: S) -> some View where S: BackportLabeledContentStyle {
    content.environment(\.backportLabeledContentStyle, .init(style))
  }
}

@available(macOS 10.15, *)
@available(iOS, deprecated: 16)
@available(tvOS, deprecated: 16)
@available(macOS, deprecated: 13)
@available(watchOS, deprecated: 9)
public protocol BackportLabeledContentStyle {
  typealias Configuration = Backport<Any>.LabeledContentStyleConfiguration
  associatedtype Body: View
  @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

@available(macOS 10.15, *)
internal struct AnyLabeledContentStyle: BackportLabeledContentStyle {
  typealias Configuration = Backport<Any>.LabeledContentStyleConfiguration
  let _makeBody: (Configuration) -> AnyView

  @available(macOS 10.15, *)
  init<S: BackportLabeledContentStyle>(_ style: S) {
    _makeBody = { config in
      AnyView(style.makeBody(configuration: config))
    }
  }

  @available(macOS 10.15, *)
  func makeBody(configuration: Configuration) -> some View {
    _makeBody(configuration)
  }
}

@available(macOS 10.15, *)
private struct BackportLabeledContentStyleEnvironmentKey: EnvironmentKey {
  static var defaultValue: AnyLabeledContentStyle = .init(.automatic)
}

@available(macOS 10.15, *)
@available(iOS, deprecated: 16)
@available(tvOS, deprecated: 16)
@available(macOS, deprecated: 13)
@available(watchOS, deprecated: 9)
extension EnvironmentValues {
  var backportLabeledContentStyle: AnyLabeledContentStyle {
    get { self[BackportLabeledContentStyleEnvironmentKey.self] }
    set { self[BackportLabeledContentStyleEnvironmentKey.self] = newValue }
  }
}