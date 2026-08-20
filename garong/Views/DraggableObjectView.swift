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
                    .frame(width: 44, height: 44)
            } else {
                Image(systemName: object.sfSymbol)
                    .font(.system(size: 32))
                    .foregroundColor(GarongTheme.teal)
                    .shadow(color: GarongTheme.teal.opacity(0.6), radius: 2)
            }
            #else
            Image(systemName: object.sfSymbol)
                .font(.system(size: 32))
                .foregroundColor(GarongTheme.teal)
                .shadow(color: GarongTheme.teal.opacity(0.6), radius: 2)
            #endif
            
            Text(object.name)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(GarongTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(GarongTheme.teal.opacity(0.16)))
        .instantDraggable(object) {
            // Drag preview
            if hasValidAsset {
                Image(object.symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .shadow(color: GarongTheme.teal, radius: 2)
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
