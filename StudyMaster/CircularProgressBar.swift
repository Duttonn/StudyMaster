//
//  Untitled.swift
//  StudyMaster
//
//  Created by DUTTON Natao on 06/11/2024.
//

import SwiftUI

struct CircularProgressBar: View {
    @Binding var progress: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(.blue)
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut(duration: 1.5), value: progress) // Smooth animation

            Text("\(Int(progress * 15))")
                .font(.headline)
                .bold()
        }
    }
}
