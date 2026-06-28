import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var repository: WordRepository
    @EnvironmentObject private var notifications: NotificationManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedPage = 0
    @State private var wantsDailyReminder = false
    @State private var hasAppeared = false

    let onComplete: () -> Void

    private let dailyService = DailyWordService()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Lexora")
                    .font(.lexoraCaption)
                    .textCase(.uppercase)
                    .tracking(2.4)
                    .foregroundStyle(LexoraColors.secondaryText)

                Spacer()

                Button("Skip") {
                    onComplete()
                }
                .font(.lexoraBody)
                .foregroundStyle(LexoraColors.secondaryText)
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)

            TabView(selection: $selectedPage) {
                OnboardingRitualPage(
                    title: "Find a word for what you feel",
                    text: "Some feelings become easier to hold when they have a name.",
                    kind: .word,
                    isActive: hasAppeared && selectedPage == 0
                )
                .tag(0)

                OnboardingRitualPage(
                    title: "Keep the words that stay with you",
                    text: "Save the words that feel personal, and let them become a quiet archive.",
                    kind: .collection,
                    isActive: hasAppeared && selectedPage == 1
                )
                .tag(1)

                VStack(spacing: 22) {
                    OnboardingRitualPage(
                        title: "Return to one word each day",
                        text: "Return for one word each day, and a short Practice when you want to remember what stayed with you.",
                        kind: .ritual,
                        isActive: hasAppeared && selectedPage == 2,
                        usesFlexibleSpace: false,
                        visualHeight: 210
                    )

                    Toggle("Optional daily reminder", isOn: $wantsDailyReminder)
                        .font(.lexoraBody)
                        .foregroundStyle(LexoraColors.primaryText)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 13)
                        .background(LexoraColors.cardBackgroundSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(LexoraColors.border.opacity(0.7), lineWidth: 0.7)
                        )
                        .padding(.horizontal, 28)
                        .padding(.bottom, 4)
                        .opacity(hasAppeared && selectedPage == 2 ? 1 : 0)
                        .offset(y: reduceMotion || (hasAppeared && selectedPage == 2) ? 0 : 12)
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.45).delay(0.18), value: selectedPage)
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: 18) {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index == selectedPage ? LexoraColors.accent : LexoraColors.border)
                            .frame(width: index == selectedPage ? 28 : 8, height: 8)
                            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: selectedPage)
                            .accessibilityHidden(true)
                    }
                }

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
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 22)
        }
        .lexoraPageBackground()
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.55)) {
                hasAppeared = true
            }
        }
    }

    private func continueTapped() {
        guard selectedPage == 2 else {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
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

private enum OnboardingVisualKind {
    case word
    case collection
    case ritual
}

private struct OnboardingRitualPage: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let text: String
    let kind: OnboardingVisualKind
    let isActive: Bool
    var usesFlexibleSpace = true
    var visualHeight: CGFloat = 310

    var body: some View {
        VStack(spacing: 28) {
            if usesFlexibleSpace {
                Spacer(minLength: 24)
            }

            ZStack {
                PaperAccent()
                    .offset(x: -112, y: -86)
                    .opacity(isActive ? 0.42 : 0)
                    .offset(y: reduceMotion || isActive ? 0 : 14)
                    .accessibilityHidden(true)

                PaperAccent(width: 86, height: 118)
                    .offset(x: 118, y: 78)
                    .opacity(isActive ? 0.28 : 0)
                    .rotationEffect(.degrees(9))
                    .accessibilityHidden(true)

                visual
                    .opacity(isActive ? 1 : 0)
                    .scaleEffect(reduceMotion || isActive ? 1 : 0.96)
                    .offset(y: reduceMotion || isActive ? 0 : 18)
            }
            .frame(height: visualHeight)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.65), value: isActive)

            VStack(spacing: 13) {
                Text(title)
                    .font(.lexoraTitle)
                    .foregroundStyle(LexoraColors.primaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(text)
                    .font(.lexoraBody)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 34)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(isActive ? 1 : 0)
            .offset(y: reduceMotion || isActive ? 0 : 12)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(0.1), value: isActive)

            if usesFlexibleSpace {
                Spacer(minLength: 24)
            }
        }
        .padding(.vertical, usesFlexibleSpace ? 0 : 8)
    }

    @ViewBuilder
    private var visual: some View {
        switch kind {
        case .word:
            WordRitualCard(isActive: isActive)
        case .collection:
            WordCollectionStack(isActive: isActive)
        case .ritual:
            DailyRitualCards(isActive: isActive)
        }
    }
}

private struct WordRitualCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isActive: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("Saudade")
                .font(.custom("Times New Roman", size: 52, relativeTo: .largeTitle))
                .foregroundStyle(LexoraColors.primaryText)
                .minimumScaleFactor(0.8)

            Text("A longing that keeps memory warm.")
                .font(.lexoraHeadline)
                .foregroundStyle(LexoraColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Rectangle()
                .fill(LexoraColors.border)
                .frame(width: 120, height: 0.8)

            Text("word of the day")
                .font(.lexoraCaption)
                .textCase(.uppercase)
                .tracking(1.8)
                .foregroundStyle(LexoraColors.secondaryText)
        }
        .padding(28)
        .frame(width: 286, height: 214)
        .background(LexoraColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(LexoraColors.border.opacity(0.72), lineWidth: 0.8)
        )
        .shadow(color: .black.opacity(0.035), radius: 14, x: 0, y: 6)
        .offset(y: reduceMotion ? 0 : (isActive ? -4 : 8))
        .animation(reduceMotion ? nil : .easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isActive)
    }
}

private struct WordCollectionStack: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isActive: Bool

    var body: some View {
        ZStack {
            MiniWordCard(word: "Huzur", note: "calm", angle: -9)
                .offset(x: -34, y: 28)
            MiniWordCard(word: "Meraki", note: "care", angle: 8)
                .offset(x: 34, y: 12)
            MiniWordCard(word: "Komorebi", note: "light", angle: -1)
                .offset(y: -28)
        }
        .offset(y: reduceMotion ? 0 : (isActive ? -3 : 8))
        .animation(reduceMotion ? nil : .easeInOut(duration: 2.1).repeatForever(autoreverses: true), value: isActive)
    }
}

private struct MiniWordCard: View {
    let word: String
    let note: String
    let angle: Double

    var body: some View {
        VStack(spacing: 8) {
            Text(word)
                .font(.lexoraHeadline)
                .foregroundStyle(LexoraColors.primaryText)
            Text(note)
                .font(.lexoraCaption)
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(LexoraColors.secondaryText)
        }
        .frame(width: 176, height: 118)
        .background(LexoraColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(LexoraColors.border.opacity(0.7), lineWidth: 0.7)
        )
        .rotationEffect(.degrees(angle))
        .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}

private struct DailyRitualCards: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LexoraColors.cardBackground)
                .frame(width: 236, height: 198)
                .overlay(
                    VStack(spacing: 10) {
                        Text("Today")
                            .font(.lexoraCaption)
                            .textCase(.uppercase)
                            .tracking(1.5)
                            .foregroundStyle(LexoraColors.secondaryText)

                        Text("Yugen")
                            .font(.lexoraDisplay)
                            .foregroundStyle(LexoraColors.primaryText)

                        Text("a quiet sense of wonder")
                            .font(.lexoraSubheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(LexoraColors.secondaryText)

                        Rectangle()
                            .fill(LexoraColors.border)
                            .frame(width: 88, height: 0.8)

                        Text("one word each day")
                            .font(.lexoraCaption)
                            .textCase(.uppercase)
                            .tracking(1.4)
                            .foregroundStyle(LexoraColors.secondaryText)
                    }
                    .padding()
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(LexoraColors.border.opacity(0.72), lineWidth: 0.8)
                )
        }
        .offset(y: reduceMotion ? 0 : (isActive ? -2 : 9))
        .animation(reduceMotion ? nil : .easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isActive)
    }
}

private struct PaperAccent: View {
    var width: CGFloat = 70
    var height: CGFloat = 100

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(LexoraColors.cardBackgroundSoft)
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(LexoraColors.border.opacity(0.7), lineWidth: 0.8)
            )
    }
}
