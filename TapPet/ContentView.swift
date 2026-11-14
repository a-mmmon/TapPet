//
//  ContentView.swift
//  TapPet
//

import SwiftUI
internal import Combine

struct ContentView: View {
    @AppStorage("happiness") private var happiness = 50
    // The last time the app was used, saved as a number of seconds
    @AppStorage("lastSeen") private var lastSeen: Double = 0
    @State private var bounce = false

    // Tells us if the app is active, in the background, etc.
    @Environment(\.scenePhase) private var scenePhase

    // Fires once every 3 seconds
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var petFace: String {
        switch happiness {
        case 0..<30: return "😢"
        case 30..<70: return "😺"
        default: return "😻"
        }
    }

    var message: String {
        switch happiness {
        case 0..<30: return "I'm sad... play with me!"
        case 30..<70: return "I'm doing okay!"
        default: return "I love you!"
        }
    }

    // Works out how long you were away and lowers happiness
    func applyTimeAway() {
        let now = Date().timeIntervalSince1970
        if lastSeen > 0 {
            let secondsAway = now - lastSeen
            let lost = Int(secondsAway / 3)
            happiness = max(happiness - lost, 0)
        }
        lastSeen = now
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("My Pet")
                .font(.largeTitle.bold())

            Text(petFace)
                .font(.system(size: 120))
                .scaleEffect(bounce ? 1.3 : 1.0)
                .onTapGesture {
                    happiness = min(happiness + 10, 100)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                        bounce = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring()) {
                            bounce = false
                        }
                    }
                }

            Text(message)
                .font(.title3)

            Text("Happiness: \(happiness)")
                .font(.title2)

            ProgressView(value: Double(happiness), total: 100)
                .padding(.horizontal, 40)

            HStack(spacing: 16) {
                Button("Feed") {
                    happiness = min(happiness + 20, 100)
                }
                .buttonStyle(.borderedProminent)

                Button("Reset") {
                    happiness = 50
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .onReceive(timer) { _ in
            happiness = max(happiness - 1, 0)
            lastSeen = Date().timeIntervalSince1970
        }
        .onChange(of: scenePhase, initial: true) { _, newPhase in
            if newPhase == .active {
                applyTimeAway()
            } else {
                lastSeen = Date().timeIntervalSince1970
            }
        }
    }
}

#Preview {
    ContentView()
}
