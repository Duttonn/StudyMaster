//
//  Untitled.swift
//  StudyMaster
//
//  Created by DUTTON Natao on 06/11/2024.
//

import SwiftUI

struct CircularProgressBar: View {
    @Binding var progress: CGFloat
    var duration : TimeInterval = 1.5

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(.blue)
                .animation(.easeInOut(duration: duration), value: progress) // Smooth animation

            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut(duration: duration), value: progress) // Smooth animation

            Text("\(Int(progress * 60))")
                .font(.headline)
                .bold()
                .transition(.opacity) 
                .contentTransition(.numericText(value: progress * 60))
            
        }
    }
}
