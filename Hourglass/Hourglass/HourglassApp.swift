//
//  HourglassApp.swift
//  Hourglass
//
//  Created by Jeslyn Lie on 28/10/2024.
//

import SwiftUI
import Combine

@main
struct HourglassApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


enum HourglassMenuOption: String, CaseIterable {
    case apps = "Select Apps"
    case limits = "Set Time Limits"
    case loops = "Select Loops"
    case customisation = "Customisation"
}


enum HourglassPastelColor: String, CaseIterable {
    case blue = "Blue"
    case green = "Green"
    case yellow = "Yellow"
    case orange = "Orange"
    case pink = "Pink"
    
    var backgroundColor: Color {
        switch self {
        case .blue: return Color.blue.opacity(0.1)
        case .green: return Color.green.opacity(0.1)
        case .yellow: return Color.yellow.opacity(0.1)
        case .orange: return Color.orange.opacity(0.1)
        case .pink: return Color.pink.opacity(0.1)
        }
    }

    var textColor: Color {
        switch self {
        case .blue: return Color.blue
        case .green: return Color.green
        case .yellow: return Color.yellow
        case .orange: return Color.orange
        case .pink: return Color.pink
        }
    }

    var buttonBackgroundColor: Color {
        switch self {
        case .blue: return Color.blue
        case .green: return Color.green
        case .yellow: return Color.yellow
        case .orange: return Color.orange
        case .pink: return Color.pink
        }
    }

    var menuBackgroundColor: Color {
        switch self {
        case .blue: return Color.blue.opacity(0.3)
        case .green: return Color.green.opacity(0.3)
        case .yellow: return Color.yellow.opacity(0.3)
        case .orange: return Color.orange.opacity(0.3)
        case .pink: return Color.pink.opacity(0.3)
        }
    }
}


struct HourglassTimeLimit {
    var hours: Int
    var minutes: Int
    var seconds: Int
}


struct MainContentView: View {
    @State private var showHourglass = true
    @State private var showPasswordPrompt = false
    @State private var passwordInput = ""
    @State private var isAuthenticated = false
    @State private var rotationAngle = 0.0
    @State private var expandedMenu: HourglassMenuOption? = nil
    @State private var selectedApps: Set<String> = []
    @State private var timeLimits: [String: HourglassTimeLimit] = [:]
    @State private var selectedLoops: Set<String> = []
    @State private var selectedColor: HourglassPastelColor = .blue
    @State private var countdownTime: Int = 0
    @State private var isCountingDown = false

    // Use @State to hold the timer's AnyCancellable
    @State private var timer: AnyCancellable? = nil
    let socialMediaPlatforms = ["Instagram", "TikTok", "Snapchat", "Facebook", "YouTube"]
    let loopOptions = ["Daily", "Weekly", "Monthly", "Yearly"]

    var body: some View {
        ZStack {
            selectedColor.backgroundColor
                .ignoresSafeArea()

            if showHourglass {
                VStack {
                    Text("Hourglass")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(selectedColor.textColor)
                        .transition(.opacity)
                        .padding(.bottom, 20)

                    Image(systemName: "hourglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(selectedColor.textColor)
                        .rotationEffect(.degrees(rotationAngle))
                        .onAppear {
                            withAnimation(Animation.linear(duration: 1.8)) {
                                rotationAngle = 180
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                withAnimation {
                                    showHourglass = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showPasswordPrompt = true
                                }
                            }
                        }
                }
            } else if isAuthenticated {
                VStack {
                    Text("Main Menu")
                        .font(.largeTitle)
                        .foregroundColor(selectedColor.textColor)
                        .padding(.bottom, 20)

                    ForEach(HourglassMenuOption.allCases, id: \.self) { option in
                        VStack {
                            Button(action: {
                                toggleMenu(option)
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                        .font(.title2)
                                        .padding()
                                        .foregroundColor(selectedColor.textColor)
                                    Spacer()
                                    Image(systemName: expandedMenu == option ? "chevron.up" : "chevron.down")
                                        .foregroundColor(selectedColor.textColor)
                                }
                                .frame(maxWidth: .infinity)
                                .background(selectedColor.buttonBackgroundColor)
                                .cornerRadius(10)
                            }
                            .padding(.vertical, 5)

                            if expandedMenu == option {
                                menuContent(for: option)
                                    .padding()
                                    .background(selectedColor.menuBackgroundColor)
                                    .cornerRadius(8)
                            }
                        }
                    }

                    Button("Start Countdown") {
                        startCountdown()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(10)

                    if isCountingDown {
                        Text("Countdown: \(countdownTime) seconds")
                            .font(.headline)
                            .foregroundColor(selectedColor.textColor)
                            .padding()
                    }
                }
                .padding()
            }
        }
        .alert("Enter Password", isPresented: $showPasswordPrompt, actions: {
            TextField("Password", text: $passwordInput)
            Button("Submit") {
                if passwordInput == "uts123" {
                    isAuthenticated = true
                    showPasswordPrompt = false
                } else {
                    passwordInput = ""
                }
            }
            Button("Cancel", role: .cancel) {
                showPasswordPrompt = false
            }
        }, message: {
            Text("Please enter the password to proceed.")
        })
        .onAppear {
            
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    if isCountingDown && countdownTime > 0 {
                        countdownTime -= 1
                    } else if countdownTime == 0 {
                        isCountingDown = false
                    }
                }
        }
        .onDisappear {
            timer?.cancel()
        }
    }

    private func startCountdown() {
        countdownTime = 60
        isCountingDown = true
    }

    private func toggleMenu(_ option: HourglassMenuOption) {
        withAnimation {
            if expandedMenu == option {
                expandedMenu = nil
            } else {
                expandedMenu = option
            }
        }
    }

    @ViewBuilder
    private func menuContent(for option: HourglassMenuOption) -> some View {
        switch option {
        case .apps:
            VStack(alignment: .leading) {
                Text("Select social media apps:")
                    .font(.headline)
                    .foregroundColor(selectedColor.textColor)
                ForEach(socialMediaPlatforms, id: \.self) { platform in
                    HStack {
                        Text(platform)
                            .foregroundColor(selectedColor.textColor)
                        Spacer()
                        Image(systemName: selectedApps.contains(platform) ? "checkmark.square" : "square")
                            .onTapGesture {
                                toggleSelection(for: platform)
                            }
                            .foregroundColor(selectedColor.textColor)
                    }
                    .padding(.vertical, 5)
                }
            }
        case .limits:
            VStack(alignment: .leading) {
                Text("Set time limits for selected apps:")
                    .font(.headline)
                    .foregroundColor(selectedColor.textColor)
                ForEach(Array(selectedApps.sorted()), id: \.self) { app in
                    HStack {
                        Text(app)
                            .foregroundColor(selectedColor.textColor)
                        Spacer()
                        HourglassTimeLimitPicker(app: app, timeLimit: Binding(
                            get: { timeLimits[app, default: HourglassTimeLimit(hours: 0, minutes: 0, seconds: 0)] },
                            set: { timeLimits[app] = $0 }
                        ))
                    }
                    .padding(.vertical, 5)
                }
            }
        case .loops:
            VStack(alignment: .leading) {
                Text("Select loops:")
                    .font(.headline)
                    .foregroundColor(selectedColor.textColor)
                ForEach(loopOptions, id: \.self) { loop in
                    HStack {
                        Text(loop)
                            .foregroundColor(selectedColor.textColor)
                        Spacer()
                        Image(systemName: selectedLoops.contains(loop) ? "checkmark.square" : "square")
                            .onTapGesture {
                                toggleLoopSelection(for: loop)
                            }
                            .foregroundColor(selectedColor.textColor)
                    }
                    .padding(.vertical, 5)
                }
            }
        case .customisation:
            VStack(alignment: .leading) {
                Text("Select a color:")
                    .font(.headline)
                    .foregroundColor(selectedColor.textColor)
                ForEach(HourglassPastelColor.allCases, id: \.self) { color in
                    HStack {
                        Text(color.rawValue)
                            .foregroundColor(selectedColor.textColor)
                        Spacer()
                        Image(systemName: selectedColor == color ? "checkmark.square" : "square")
                            .onTapGesture {
                                selectedColor = color
                            }
                            .foregroundColor(selectedColor.textColor)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }

    private func toggleSelection(for platform: String) {
        if selectedApps.contains(platform) {
            selectedApps.remove(platform)
        } else {
            selectedApps.insert(platform)
        }
    }

    private func toggleLoopSelection(for loop: String) {
        if selectedLoops.contains(loop) {
            selectedLoops.remove(loop)
        } else {
            selectedLoops.insert(loop)
        }
    }
}


struct HourglassTimeLimitPicker: View {
    var app: String
    @Binding var timeLimit: HourglassTimeLimit

    var body: some View {
        HStack {
            Text("H: \(timeLimit.hours) M: \(timeLimit.minutes) S: \(timeLimit.seconds)")
            Spacer()
                    }
    }
}
