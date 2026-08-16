//
//  DraggableObjectView.swift
//  garong
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import UniformTypeIdentifiers

struct DraggableObjectView: View {
    let object: GameObject
    var onDragStarted: (() -> Void)? = nil
    var onDragEnded: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 4) {
            #if canImport(UIKit)
            if !object.symbol.isEmpty, UIImage(named: object.symbol) != nil {
                Image(object.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    // Multi-directional edge stroke tracing the exact PNG image silhouette contour
                    .shadow(color: .gray, radius: 1, x: 1, y: 1)
                    .shadow(color: .gray, radius: 1, x: -1, y: -1)
                    .shadow(color: .gray, radius: 1, x: 1, y: -1)
                    .shadow(color: .gray, radius: 1, x: -1, y: 1)
            } else {
                Image(systemName: object.sfSymbol)
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
                    .shadow(color: Color.accentColor.opacity(0.6), radius: 2)
            }
            #else
            Image(systemName: object.sfSymbol)
                .font(.system(size: 32))
                .foregroundColor(.accentColor)
                .shadow(color: Color.accentColor.opacity(0.6), radius: 2)
            #endif
            
            Text(object.name)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .instantDraggable(object) {
            // Drag preview
            #if canImport(UIKit)
            if !object.symbol.isEmpty, UIImage(named: object.symbol) != nil {
                Image(object.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.accentColor, radius: 2)
            } else {
                Image(systemName: object.sfSymbol)
                    .font(.system(size: 48))
                    .shadow(radius: 8)
            }
            #else
            Image(systemName: object.sfSymbol)
                .font(.system(size: 48))
                .shadow(radius: 8)
            #endif
        }
    }
}

struct DraggableObjectView_Previews: PreviewProvider {
    static var previews: some View {
        DraggableObjectView(object: SampleGameData.teddy)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
