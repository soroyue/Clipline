import SwiftUI

enum Layout {
    /// How big the photos hang, from Size in the menu bar. The clip, the rope
    /// and the glass frame keep their size; the photos and the room they take
    /// grow or shrink. Medium is the original size.
    enum Size: String, CaseIterable {
        case small, medium, large

        var scale: CGFloat {
            switch self {
            case .small: 0.8
            case .medium: 1
            case .large: 1.35
            }
        }
    }

    static var size: Size {
        get { Size(rawValue: UserDefaults.standard.string(forKey: "lineSize") ?? "") ?? .medium }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "lineSize") }
    }

    static var photoMaxHeight: CGFloat { (104 * size.scale).rounded() }
    static var cardWidth: CGFloat { (150 * size.scale).rounded() }
    static var spacing: CGFloat { cardWidth + 24 }
    static var panelHeight: CGFloat { photoMaxHeight + 106 }
    static let ropeTop: CGFloat = 10
    static let pinAbove: CGFloat = 9.5

    /// The rope hangs as a parabola from edge to edge of the screen.
    static func sag(width: CGFloat) -> CGFloat { min(30, width * 0.018) }

    static func ropeY(x: CGFloat, width: CGFloat) -> CGFloat {
        guard width > 0 else { return ropeTop }
        let f = x / width
        return ropeTop + 4 * sag(width: width) * f * (1 - f)
    }

    /// Each lane starts at the centre, newest first and older cards outward.
    static func groupX(rank: Int, isText: Bool, width: CGFloat, scroll: CGFloat) -> CGFloat {
        let distance = cardWidth / 2 + 30 + CGFloat(rank) * spacing - scroll
        return width / 2 + (isText ? -distance : distance)
    }

}

struct LineView: View {
    @ObservedObject var line: Line

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .topLeading) {
                Rope(width: width)

                if line.items.isEmpty {
                    Hint()
                        .position(x: width / 2, y: Layout.ropeY(x: width / 2, width: width) + 34)
                        .transition(.opacity)
                }

                ForEach([true, false], id: \.self) { isText in
                    ZStack(alignment: .topLeading) {
                        ForEach(line.items.filter { $0.isText == isText }) { item in
                            let x = line.x(for: item, width: width)
                            let ropeY = Layout.ropeY(x: max(0, min(width, x)), width: width)
                            PeggedView(item: item, line: line)
                                .frame(width: Layout.cardWidth, height: Layout.panelHeight - ropeY, alignment: .top)
                                .opacity(min(1, max(0, min(x, width - x) / 90)))
                                .position(x: x, y: ropeY - Layout.pinAbove + (Layout.panelHeight - ropeY) / 2)
                        }
                    }
                    .frame(width: width, height: Layout.panelHeight)
                    .mask(alignment: isText ? .leading : .trailing) {
                        Rectangle().frame(width: max(0, width / 2 - 12))
                    }
                }
                HStack(spacing: 8) {
                    Image(systemName: "text.alignleft").foregroundStyle(Color(red: 0.65, green: 0.56, blue: 0.42))
                    Rectangle().fill(.secondary.opacity(0.25)).frame(width: 1, height: 12)
                    Image(systemName: "photo").foregroundStyle(Color(red: 0.43, green: 0.60, blue: 0.70))
                }
                .font(.system(size: 10, weight: .medium))
                .position(x: width / 2, y: Layout.ropeY(x: width / 2, width: width) + 30)
                .allowsHitTesting(false)

            }
            .animation(.spring(response: 0.55, dampingFraction: 0.78), value: line.items.map(\.id))
            .animation(.easeInOut(duration: 0.3), value: line.items.isEmpty)
            // Tucked away, the whole line waits above the top edge and slides
            // out from under the menu bar, the way an auto-hiding Dock does.
            .offset(y: line.revealed ? 0 : -(Layout.panelHeight + 12))
            .animation(line.revealed ? .spring(response: 0.42, dampingFraction: 0.82)
                                     : .easeIn(duration: 0.22), value: line.revealed)
        }
        .onPreferenceChange(HitRectsKey.self) { rects in
            line.hitRects = rects
        }
    }
}

private struct Hint: View {
    var body: some View {
        Text(L("Take a screenshot and it will hang here"))
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.regularMaterial, in: Capsule())
    }
}

/// A thin, neutral line: a mid gray core with a faint highlight and a soft
/// shadow, so it reads on light and dark backgrounds alike. It fades out at
/// both ends so it seems to come from beyond the screen.
struct Rope: View {
    let width: CGFloat

    private var path: Path {
        Path { p in
            let top = Layout.ropeTop
            p.move(to: CGPoint(x: -20, y: top))
            p.addQuadCurve(
                to: CGPoint(x: width + 20, y: top),
                control: CGPoint(x: width / 2, y: top + 2 * Layout.sag(width: width)))
        }
    }

    var body: some View {
        ZStack {
            path.stroke(Color.black.opacity(0.22), lineWidth: 1.4).offset(y: 1.2).blur(radius: 1.2)
            path.stroke(Color(white: 0.55), lineWidth: 1.2)
            path.stroke(Color.white.opacity(0.45), lineWidth: 0.4).offset(y: -0.35)
        }
        .mask(
            LinearGradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.08),
                .init(color: .black, location: 0.92),
                .init(color: .clear, location: 1),
            ], startPoint: .leading, endPoint: .trailing)
        )
        .allowsHitTesting(false)
    }
}

struct HitRectsKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}
