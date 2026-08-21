//
//  InstantDragHelper.swift
//  garong
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// ViewModifier that attaches native .draggable and reduces UILongPressGestureRecognizer.minimumPressDuration to 0.01s
/// so dragging starts immediately on initial touch motion without press-and-hold delay.
struct InstantDragModifier<T: Transferable, Preview: View>: ViewModifier {
    let item: T
    let onDragStarted: (() -> Void)?
    let onDragEnded: (() -> Void)?
    let preview: () -> Preview

    func body(content: Content) -> some View {
        content
            .draggable(item) {
                preview()
            }
            #if canImport(UIKit)
            .background(InstantDragHelperView(
                onDragStarted: onDragStarted,
                onDragEnded: onDragEnded
            ))
            #endif
    }
}

struct InstantDragActivity {
    private(set) var isActive = false

    mutating func update(isActive newValue: Bool) -> Bool? {
        guard newValue != isActive else { return nil }
        isActive = newValue
        return newValue
    }
}

#if canImport(UIKit)
private struct InstantDragHelperView: UIViewRepresentable {
    let onDragStarted: (() -> Void)?
    let onDragEnded: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(onDragStarted: onDragStarted, onDragEnded: onDragEnded)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let coordinator = context.coordinator
        DispatchQueue.main.async {
            if let parent = view.superview {
                configureDragGestures(in: parent, coordinator: coordinator)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onDragStarted = onDragStarted
        context.coordinator.onDragEnded = onDragEnded
        let coordinator = context.coordinator
        DispatchQueue.main.async {
            if let parent = uiView.superview {
                configureDragGestures(in: parent, coordinator: coordinator)
            }
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.finishIfNeeded()
    }
    
    private func configureDragGestures(in view: UIView, coordinator: Coordinator) {
        var current: UIView? = view
        var attachedObserver = false
        while let v = current {
            let longPresses = ((v.gestureRecognizers ?? []) + v.subviews.flatMap { $0.gestureRecognizers ?? [] })
                .compactMap { $0 as? UILongPressGestureRecognizer }

            for gesture in longPresses {
                gesture.minimumPressDuration = 0.01
                if !attachedObserver {
                    coordinator.observe(gesture)
                }
            }
            attachedObserver = attachedObserver || !longPresses.isEmpty
            current = v.superview
        }
    }

    final class Coordinator: NSObject {
        var onDragStarted: (() -> Void)?
        var onDragEnded: (() -> Void)?
        private var activity = InstantDragActivity()
        private var observedGestureIDs: Set<ObjectIdentifier> = []

        init(onDragStarted: (() -> Void)?, onDragEnded: (() -> Void)?) {
            self.onDragStarted = onDragStarted
            self.onDragEnded = onDragEnded
        }

        func observe(_ gesture: UILongPressGestureRecognizer) {
            guard observedGestureIDs.insert(ObjectIdentifier(gesture)).inserted else { return }
            gesture.addTarget(self, action: #selector(handleDragGesture(_:)))
        }

        @objc private func handleDragGesture(_ gesture: UILongPressGestureRecognizer) {
            let nextState: Bool?
            switch gesture.state {
            case .began, .changed:
                nextState = true
            case .ended, .cancelled, .failed:
                nextState = false
            default:
                nextState = nil
            }

            guard let nextState, let isActive = activity.update(isActive: nextState) else { return }
            if isActive {
                onDragStarted?()
            } else {
                onDragEnded?()
            }
        }

        func finishIfNeeded() {
            guard activity.update(isActive: false) == false else { return }
            onDragEnded?()
        }
    }
}
#endif

extension View {
    func instantDraggable<T: Transferable, Preview: View>(
        _ item: T,
        onDragStarted: (() -> Void)? = nil,
        onDragEnded: (() -> Void)? = nil,
        @ViewBuilder preview: @escaping () -> Preview
    ) -> some View {
        modifier(InstantDragModifier(
            item: item,
            onDragStarted: onDragStarted,
            onDragEnded: onDragEnded,
            preview: preview
        ))
    }
}
