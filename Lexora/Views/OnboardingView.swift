import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var repository: WordRepository
    @EnvironmentObject private var notifications: NotificationManager
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
                        title: "Make it a daily ritual",
                        text: "Discover one meaningful word each day. Premium opens deeper notes, stories, widgets, and share cards.",
                        kind: .ritual,
                        isActive: hasAppeared && selectedPage == 2
                    )

                    Toggle("Daily reminder", isOn: $wantsDailyReminder)
                        .font(.lexoraBody)
                        .foregroundStyle(LexoraColors.primaryText)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 13)
                        .background(LexoraColors.cardBackgroundSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(LexoraColors.border, lineWidth: 0.8)
                        )
                        .padding(.horizontal, 28)
                        .opacity(hasAppeared && selectedPage == 2 ? 1 : 0)
                        .offset(y: hasAppeared && selectedPage == 2 ? 0 : 12)
                        .animation(.easeOut(duration: 0.45).delay(0.18), value: selectedPage)
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
                            .animation(.easeInOut(duration: 0.25), value: selectedPage)
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
            withAnimation(.easeOut(duration: 0.55)) {
                hasAppeared = true
            }
        }
    }

    private func continueTapped() {
        guard selectedPage == 2 else {
            withAnimation(.easeInOut(duration: 0.35)) {
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
    let title: String
    let text: String
    let kind: OnboardingVisualKind
    let isActive: Bool

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 24)

            ZStack {
                PaperAccent()
                    .offset(x: -112, y: -86)
                    .opacity(isActive ? 0.42 : 0)
                    .offset(y: isActive ? 0 : 14)

                PaperAccent(width: 86, height: 118)
                    .offset(x: 118, y: 78)
                    .opacity(isActive ? 0.28 : 0)
                    .rotationEffect(.degrees(9))

                visual
                    .opacity(isActive ? 1 : 0)
                    .scaleEffect(isActive ? 1 : 0.96)
                    .offset(y: isActive ? 0 : 18)
            }
            .frame(height: 310)
            .animation(.easeOut(duration: 0.65), value: isActive)

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
            .offset(y: isActive ? 0 : 12)
            .animation(.easeOut(duration: 0.5).delay(0.1), value: isActive)

            Spacer(minLength: 24)
        }
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
                .stroke(LexoraColors.border, lineWidth: 0.9)
        )
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
        .offset(y: isActive ? -4 : 8)
        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isActive)
    }
}

private struct WordCollectionStack: View {
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
        .offset(y: isActive ? -3 : 8)
        .animation(.easeInOut(duration: 2.1).repeatForever(autoreverses: true), value: isActive)
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
                .stroke(LexoraColors.border, lineWidth: 0.8)
        )
        .rotationEffect(.degrees(angle))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 7)
    }
}

private struct DailyRitualCards: View {
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
                    }
                    .padding()
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(LexoraColors.border, lineWidth: 0.9)
                )

            HStack(spacing: 10) {
                Image(systemName: "rectangle.inset.filled")
                Image(systemName: "square.and.arrow.up")
                Image(systemName: "book.pages")
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(LexoraColors.accent)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(LexoraColors.cardBackgroundSoft)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(LexoraColors.border, lineWidth: 0.8)
            )
            .offset(y: 112)
        }
        .offset(y: isActive ? -2 : 9)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isActive)
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
