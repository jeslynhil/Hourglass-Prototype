//
//  ContentView.swift
//  Hourglass
//
//  Created by Jeslyn Lie on 28/10/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var showHourglass = true
    @State private var showPasswordPrompt = false
    @State private var passwordInput = ""
    @State private var isAuthenticated = false
    @State private var rotationAngle = 0.0
    @State private var expandedMenu: MenuOption? = nil
    @State private var selectedApps: Set<String> = []
    @State private var timeLimits: [String: TimeLimit] = [:]
    @State private var selectedLoops: Set<String> = []
    @State private var selectedColor: PastelColor = .lightBlue
    @State private var countdownTime: TimeLimit? = nil
    @State private var remainingTime: Int = 0
    @State private var isCountingDown = false

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

                    ForEach(MenuOption.allCases, id: \.self) { option in
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

                    Button(action: startCountdown) {
                        Text("Start Countdown")
                            .font(.title3)
                            .padding()
                            .background(selectedColor.buttonBackgroundColor)
                            .foregroundColor(selectedColor.textColor)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)

                    if isCountingDown {
                        VStack {
                            Image(systemName: "hourglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(rotationAngle))
                                .foregroundColor(selectedColor.textColor)
                                .onAppear {
                                    withAnimation(Animation.linear(duration: 60).repeatForever(autoreverses: false)) {
                                        rotationAngle += 180
                                    }
                                }

                            Text("Time Remaining: \(formattedTime(remainingTime))")
                                .font(.headline)
                                .foregroundColor(selectedColor.textColor)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding()
            }
        }
        .alert("Enter Password", isPresented: $showPasswordPrompt, actions: {
            SecureField("Password", text: $passwordInput)
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
    }

    private func toggleMenu(_ option: MenuOption) {
        withAnimation {
            if expandedMenu == option {
                expandedMenu = nil
            } else {
                expandedMenu = option
            }
        }
    }

    @ViewBuilder
    private func menuContent(for option: MenuOption) -> some View {
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
                        Button(action: {
                            toggleTimeLimit(for: app)
                        }) {
                            Text("Set Time")
                                .foregroundColor(.blue)
                        }
                    }
                    if let timeLimit = timeLimits[app] {
                        VStack {
                            Text("Time Limit: \(timeLimit.hours)h \(timeLimit.minutes)m \(timeLimit.seconds)s")
                                .foregroundColor(selectedColor.textColor)
                            TimeLimitPicker(app: app, timeLimit: Binding(get: {
                                timeLimits[app] ?? TimeLimit(hours: 0, minutes: 0, seconds: 0)
                            }, set: { newValue in
                                timeLimits[app] = newValue
                            })) // Pass binding
                        }
                    }
                }
            }
        case .loops:
            VStack(alignment: .leading) {
                Text("Select loop options:")
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
                ForEach(PastelColor.allCases, id: \.self) { color in
                    HStack {
                        Text(color.rawValue)
                            .foregroundColor(selectedColor.textColor)
                        Spacer()
                        Image(systemName: selectedColor == color ? "checkmark.circle.fill" : "circle")
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
            timeLimits.removeValue(forKey: platform)
        } else {
            selectedApps.insert(platform)
        }
    }

    private func toggleTimeLimit(for app: String) {
        if timeLimits[app] == nil {
            timeLimits[app] = TimeLimit(hours: 0, minutes: 0, seconds: 0)
        }
    }

    private func toggleLoopSelection(for loop: String) {
        if selectedLoops.contains(loop) {
            selectedLoops.remove(loop)
        } else {
            selectedLoops.insert(loop)
        }
    }

    private func startCountdown() {
        if let timeLimit = timeLimits.first?.value {
            remainingTime = timeLimit.hours * 3600 + timeLimit.minutes * 60 + timeLimit.seconds
            isCountingDown = true
            startTimer()
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                isCountingDown = false
                timer.invalidate()
            }
        }
    }

    private func formattedTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
    }
}

struct TimeLimitPicker: View {
    let app: String
    @Binding var timeLimit: TimeLimit

    var body: some View {
        VStack {
            Stepper(value: $timeLimit.hours, in: 0...23) {
                Text("Hours: \(timeLimit.hours)")
            }
            Stepper(value: $timeLimit.minutes, in: 0...59) {
                Text("Minutes: \(timeLimit.minutes)")
            }
            Stepper(value: $timeLimit.seconds, in: 0...59) {
                Text("Seconds: \(timeLimit.seconds)")
            }
        }
    }
}

enum MenuOption: String, CaseIterable {
    case apps = "Apps"
    case limits = "Limits"
    case loops = "Loops"
    case customisation = "Customisation"
}

struct TimeLimit: Identifiable {
    let id = UUID()
    var hours: Int
    var minutes: Int
    var seconds: Int
}

enum PastelColor: String, CaseIterable {
    case lightBlue = "Light Blue"
    case lightGreen = "Light Green"
    case lightPink = "Light Pink"
    case lightYellow = "Light Yellow"

    var backgroundColor: Color {
        switch self {
        case .lightBlue: return Color.blue.opacity(0.15)
        case .lightGreen: return Color.green.opacity(0.15)
        case .lightPink: return Color.pink.opacity(0.15)
        case .lightYellow: return Color.yellow.opacity(0.15)
        }
    }

    var textColor: Color {
        switch self {
        case .lightBlue: return Color.blue
        case .lightGreen: return Color.green
        case .lightPink: return Color.pink
        case .lightYellow: return Color.yellow
        }
    }

    var buttonBackgroundColor: Color {
        switch self {
        case .lightBlue: return Color.blue.opacity(0.25)
        case .lightGreen: return Color.green.opacity(0.25)
        case .lightPink: return Color.pink.opacity(0.25)
        case .lightYellow: return Color.yellow.opacity(0.25)
        }
    }

    var menuBackgroundColor: Color {
        switch self {
        case .lightBlue: return Color.blue.opacity(0.08)
        case .lightGreen: return Color.green.opacity(0.08)
        case .lightPink: return Color.pink.opacity(0.08)
        case .lightYellow: return Color.yellow.opacity(0.08)
        }
    }
}

struct Hourglass: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
