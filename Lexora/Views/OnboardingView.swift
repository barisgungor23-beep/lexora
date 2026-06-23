import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var repository: WordRepository
    @EnvironmentObject private var notifications: NotificationManager
    @State private var selectedPage = 0
    @State private var wantsDailyReminder = false

    let onComplete: () -> Void

    private let dailyService = DailyWordService()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") {
                    onComplete()
                }
                .font(.lexoraBody)
                .foregroundStyle(LexoraColors.secondaryText)
            }
            .padding(.horizontal)
            .padding(.top, 18)

            TabView(selection: $selectedPage) {
                OnboardingPage(
                    icon: "sun.max",
                    title: "Discover a word each day",
                    text: "Lexora brings one meaningful word from languages around the world into your day."
                )
                .tag(0)

                OnboardingPage(
                    icon: "heart",
                    title: "Save what resonates",
                    text: "Keep the words that stay with you in a small personal collection."
                )
                .tag(1)

                VStack(spacing: 24) {
                    OnboardingPage(
                        icon: "bell",
                        title: "Make it part of your day",
                        text: "Use quiet reminders when you want them. Premium also unlocks the widget and share cards."
                    )

                    Toggle("Daily reminder", isOn: $wantsDailyReminder)
                        .font(.lexoraBody)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(LexoraColors.cardBackgroundSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(LexoraColors.border, lineWidth: 0.8)
                        )
                        .padding(.horizontal, 28)
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                continueTapped()
            } label: {
                Text(selectedPage == 2 ? "Done" : "Continue")
                    .font(.lexoraHeadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(LexoraColors.accent)
            .padding(.horizontal)
            .padding(.bottom, 22)
        }
        .lexoraPageBackground()
    }

    private func continueTapped() {
        guard selectedPage == 2 else {
            withAnimation(.easeInOut) {
                selectedPage += 1
            }
            return
        }

        if wantsDailyReminder {
            notifications.isEnabled = true
            Task {
                await notifications.updateSchedule(using: dailyService.word(words: repository.words))
                onComplete()
            }
        } else {
            onComplete()
        }
    }
}

private struct OnboardingPage: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(LexoraColors.accent)
                .frame(width: 84, height: 84)
                .background(LexoraColors.cardBackgroundSoft)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(LexoraColors.border, lineWidth: 0.8)
                )

            VStack(spacing: 12) {
                Text(title)
                    .font(.lexoraTitle)
                    .foregroundStyle(LexoraColors.primaryText)
                    .multilineTextAlignment(.center)

                Text(text)
                    .font(.lexoraBody)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 34)
            }

            Spacer()
        }
    }
}
