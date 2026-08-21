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
    let preview: () -> Preview

    func body(content: Content) -> some View {
        content
            .draggable(item) {
                preview()
            }
            #if canImport(UIKit)
            .background(InstantDragHelperView(
                onDragStarted: onDragStarted
            ))
            #endif
    }
}

struct InstantDragActivity {
    private(set) var isActive = false

    mutating func update(isActive newValue: Bool) -> Bool? {
        defer { isActive = newValue }
        return newValue && !isActive ? true : nil
    }
}

#if canImport(UIKit)
private struct InstantDragHelperView: UIViewRepresentable {
    let onDragStarted: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(onDragStarted: onDragStarted)
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
        let coordinator = context.coordinator
        DispatchQueue.main.async {
            if let parent = uiView.superview {
                configureDragGestures(in: parent, coordinator: coordinator)
            }
        }
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
        private var activity = InstantDragActivity()
        private var observedGestureIDs: Set<ObjectIdentifier> = []

        init(onDragStarted: (() -> Void)?) {
            self.onDragStarted = onDragStarted
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

            guard let nextState else { return }
            if activity.update(isActive: nextState) == true {
                onDragStarted?()
            }
        }
    }
}
#endif

extension View {
    func instantDraggable<T: Transferable, Preview: View>(
        _ item: T,
        onDragStarted: (() -> Void)? = nil,
        @ViewBuilder preview: @escaping () -> Preview
    ) -> some View {
        modifier(InstantDragModifier(
            item: item,
            onDragStarted: onDragStarted,
            preview: preview
        ))
    }
}
