//
//  ReplayView.swift
//  StudyMaster
//
//  Created by DUTTON Natao on 25/11/2024.
//

import SwiftUI

struct ReplayView: View {
    var meanScore: Double
    var replayAction: () -> Void

    var body: some View {
        VStack {
            Text("Quiz Completed!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("Average Score: \(Int(meanScore))")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.bottom)

            Button(action: replayAction) {
                Text("Replay Quizzes")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}
