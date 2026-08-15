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
    let preview: () -> Preview

    func body(content: Content) -> some View {
        content
            .draggable(item) {
                preview()
            }
            #if canImport(UIKit)
            .background(InstantDragHelperView())
            #endif
    }
}

#if canImport(UIKit)
private struct InstantDragHelperView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            if let parent = view.superview {
                disableDragDelay(in: parent)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let parent = uiView.superview {
                disableDragDelay(in: parent)
            }
        }
    }
    
    private func disableDragDelay(in view: UIView) {
        var current: UIView? = view
        while let v = current {
            for gesture in v.gestureRecognizers ?? [] {
                if let longPress = gesture as? UILongPressGestureRecognizer {
                    longPress.minimumPressDuration = 0.01
                }
            }
            for subview in v.subviews {
                for gesture in subview.gestureRecognizers ?? [] {
                    if let longPress = gesture as? UILongPressGestureRecognizer {
                        longPress.minimumPressDuration = 0.01
                    }
                }
            }
            current = v.superview
        }
    }
}
#endif

extension View {
    func instantDraggable<T: Transferable, Preview: View>(_ item: T, @ViewBuilder preview: @escaping () -> Preview) -> some View {
        self.modifier(InstantDragModifier(item: item, preview: preview))
    }
}
