import SwiftUI

enum TimerButtonStyle {
    case start
    case stop
    case pause
    case resume
    case done

    var systemImage: String {
        switch self {
        case .start: "play.fill"
        case .stop: "stop.fill"
        case .pause: "pause.fill"
        case .resume: "play.fill"
        case .done: "checkmark"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .start, .resume: .green
        case .stop: .red
        case .pause: .orange
        case .done: .blue
        }
    }

    var size: CGFloat {
        switch self {
        case .start, .done: 72
        case .stop, .pause, .resume: 64
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .start, .done: 28
        case .stop, .pause, .resume: 24
        }
    }
}

struct TimerButton: View {
    let style: TimerButtonStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: style.systemImage)
                .font(.system(size: style.iconSize, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: style.size, height: style.size)
                .background(style.backgroundColor)
                .clipShape(Circle())
        }
    }
}
