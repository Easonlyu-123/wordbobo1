//
//  StudyRouterView.swift
//  WordBoBo
//  根据当前学习阶段自动路由到对应视图

import SwiftUI

struct StudyRouterView: View {
    @EnvironmentObject var wordStore: WordStore

    var body: some View {
        Group {
            switch wordStore.currentSession?.currentStage {
            case 1:
                StudyStage1View()
            case 2:
                StudyStage2View()
            case 3:
                StudyStage3View()
            default:
                // No active session, go back
                Color.clear
                    .onAppear {
                        wordStore.currentSession = nil
                    }
            }
        }
    }
}
