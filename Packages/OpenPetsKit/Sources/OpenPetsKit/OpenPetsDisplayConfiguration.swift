import CoreGraphics

public struct OpenPetsDisplayConfiguration: Codable, Equatable, Sendable {
    public static let defaultScale: CGFloat = 0.42
    public static let defaultFontSize: CGFloat = 13
    public static let minimumFontSize: CGFloat = 9
    public static let maximumFontSize: CGFloat = 24
    public static let defaultMessageBubbleWidth: CGFloat = 260
    public static let minimumMessageBubbleWidth: CGFloat = 200
    public static let maximumMessageBubbleWidth: CGFloat = 420
    public static let `default` = OpenPetsDisplayConfiguration()

    public var scale: CGFloat
    public var messageAreaHeight: CGFloat
    public var fontSize: CGFloat
    public var messageBubbleWidth: CGFloat

    public init(
        scale: CGFloat = OpenPetsDisplayConfiguration.defaultScale,
        messageAreaHeight: CGFloat = 56,
        fontSize: CGFloat = OpenPetsDisplayConfiguration.defaultFontSize,
        messageBubbleWidth: CGFloat = OpenPetsDisplayConfiguration.defaultMessageBubbleWidth
    ) {
        self.scale = scale
        self.messageAreaHeight = messageAreaHeight
        self.fontSize = Self.clampedFontSize(fontSize)
        self.messageBubbleWidth = Self.clampedMessageBubbleWidth(messageBubbleWidth)
    }

    private enum CodingKeys: String, CodingKey {
        case scale
        case messageAreaHeight
        case fontSize
        case messageBubbleWidth
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            scale: try container.decodeIfPresent(CGFloat.self, forKey: .scale) ?? Self.defaultScale,
            messageAreaHeight: try container.decodeIfPresent(CGFloat.self, forKey: .messageAreaHeight) ?? 56,
            fontSize: try container.decodeIfPresent(CGFloat.self, forKey: .fontSize) ?? Self.defaultFontSize,
            messageBubbleWidth: try container.decodeIfPresent(CGFloat.self, forKey: .messageBubbleWidth) ?? Self.defaultMessageBubbleWidth
        )
    }

    public static func clampedFontSize(_ fontSize: CGFloat) -> CGFloat {
        min(max(fontSize, minimumFontSize), maximumFontSize)
    }

    public static func clampedMessageBubbleWidth(_ messageBubbleWidth: CGFloat) -> CGFloat {
        min(max(messageBubbleWidth, minimumMessageBubbleWidth), maximumMessageBubbleWidth)
    }
}
