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
    
    private var hasValidAsset: Bool {
        !object.symbol.isEmpty && AssetFallbackHelper.hasAsset(named: object.symbol)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if hasValidAsset {
                Image(object.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
            } else {
                Image(systemName: object.sfSymbol)
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
                    .shadow(color: Color.accentColor.opacity(0.6), radius: 2)
            }
            
            Text(object.name)
                .font(.appFont(size: 16, relativeTo: .caption2))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .instantDraggable(object) {
            // Drag preview
            if hasValidAsset {
                Image(object.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
            } else {
                Image(systemName: object.sfSymbol)
                    .font(.system(size: 48))
                    .shadow(radius: 8)
            }
        }
    }
}

struct DraggableObjectView_Previews: PreviewProvider {
    static var previews: some View {
        DraggableObjectView(object: SampleGameData.toy)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
