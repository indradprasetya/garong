//
//  DraggableObjectView.swift
//  garong
//

import SwiftUI
import UniformTypeIdentifiers

struct DraggableObjectView: View {
    let object: GameObject
    
    var body: some View {
        VStack(spacing: 4) {
            Text(object.symbol)
                .font(.system(size: 32))
            
            Text(object.name)
                .font(.caption2)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 2)
        }
        .frame(width: 72, height: 76)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor.separator).opacity(0.6), lineWidth: 1)
        )
        .draggable(object) {
            // Drag preview
            Text(object.symbol)
                .font(.system(size: 52))
                .shadow(radius: 8)
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
