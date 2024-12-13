

import Foundation
import UIKit
import SwiftUI

struct Note: Identifiable, Codable {
    var id: UUID
    var title: String
    var content: String
    var type: NoteType
    var drawingData: Data?
    var fontSize: CGFloat
    var textColor: String
    var isBold: Bool
    var isItalic: Bool
    var isUnderlined: Bool
    var textAlignment: TextAlignmentWrapper?

    enum NoteType: String, Codable {
        case text
        case checklist
        case drawing
    }
}

enum TextAlignmentWrapper: String, Codable {
    case leading
    case center
    case trailing

    var textAlignment: TextAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }

    init(textAlignment: TextAlignment) {
        switch textAlignment {
        case .leading: self = .leading
        case .center: self = .center
        case .trailing: self = .trailing
        @unknown default: self = .leading
        }
    }
}




