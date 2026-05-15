import Foundation

public struct PetManifest: Codable, Equatable, Sendable {
    public var id: String
    public var displayName: String
    public var description: String
    public var spritesheetPath: String
    public var reactionAnimations: [OpenPetsPetReactionAnimation]
    public var animationFrameDurationsMilliseconds: [PetAnimation: [Int]]

    public init(
        id: String,
        displayName: String,
        description: String,
        spritesheetPath: String,
        reactionAnimations: [OpenPetsPetReactionAnimation] = [],
        animationFrameDurationsMilliseconds: [PetAnimation: [Int]] = [:]
    ) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.spritesheetPath = spritesheetPath
        self.reactionAnimations = reactionAnimations
        self.animationFrameDurationsMilliseconds = animationFrameDurationsMilliseconds
    }

    public func frameDurationsMilliseconds(for animation: PetAnimation) -> [Int] {
        animationFrameDurationsMilliseconds[animation] ?? animation.frameDurationsMilliseconds
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case description
        case spritesheetPath
        case reactionAnimations
        case animationFrameDurationsMilliseconds
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        displayName = try container.decode(String.self, forKey: .displayName)
        description = try container.decode(String.self, forKey: .description)
        spritesheetPath = try container.decode(String.self, forKey: .spritesheetPath)
        reactionAnimations = try container.decodeIfPresent(
            [OpenPetsPetReactionAnimation].self,
            forKey: .reactionAnimations
        ) ?? []
        animationFrameDurationsMilliseconds = try Self.decodeAnimationFrameDurations(
            from: container,
            forKey: .animationFrameDurationsMilliseconds
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(description, forKey: .description)
        try container.encode(spritesheetPath, forKey: .spritesheetPath)
        try container.encode(reactionAnimations, forKey: .reactionAnimations)
        if !animationFrameDurationsMilliseconds.isEmpty {
            let rawKeyed = Dictionary(
                uniqueKeysWithValues: animationFrameDurationsMilliseconds.map { ($0.key.rawValue, $0.value) }
            )
            try container.encode(rawKeyed, forKey: .animationFrameDurationsMilliseconds)
        }
    }

    private static func decodeAnimationFrameDurations(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> [PetAnimation: [Int]] {
        guard let raw = try container.decodeIfPresent([String: [Int]].self, forKey: key) else {
            return [:]
        }

        var resolved: [PetAnimation: [Int]] = [:]
        for (rawKey, durations) in raw {
            guard let animation = PetAnimation(rawValue: rawKey) else {
                throw DecodingError.dataCorruptedError(
                    forKey: key,
                    in: container,
                    debugDescription: "Unknown animation key '\(rawKey)' in animationFrameDurationsMilliseconds"
                )
            }

            let expectedCount = animation.frameDurationsMilliseconds.count
            guard durations.count == expectedCount else {
                throw DecodingError.dataCorruptedError(
                    forKey: key,
                    in: container,
                    debugDescription: """
                    animationFrameDurationsMilliseconds['\(rawKey)'] must have \(expectedCount) entries to match the \
                    default frame count, got \(durations.count)
                    """
                )
            }

            guard durations.allSatisfy({ $0 > 0 }) else {
                throw DecodingError.dataCorruptedError(
                    forKey: key,
                    in: container,
                    debugDescription: "animationFrameDurationsMilliseconds['\(rawKey)'] entries must be positive"
                )
            }

            resolved[animation] = durations
        }
        return resolved
    }
}

public struct PetAtlas: Codable, Equatable, Sendable {
    public static let codexColumns = 8
    public static let codexRows = 9

    public var columns: Int
    public var rows: Int
    public var cellWidth: Int
    public var cellHeight: Int
    public var pixelWidth: Int
    public var pixelHeight: Int

    public init(columns: Int, rows: Int, cellWidth: Int, cellHeight: Int, pixelWidth: Int, pixelHeight: Int) {
        self.columns = columns
        self.rows = rows
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
    }
}
