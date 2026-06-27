import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var practice: PracticeSessionManager
    @EnvironmentObject private var premium: PremiumManager
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false

    var body: some View {
        Group {
            if practice.isLoading && practice.practiceSet == nil {
                ProgressView("Preparing today’s practice")
                    .font(.lexoraBody)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .lexoraPageBackground()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        PracticeHeader()

                        switch practice.attemptState {
                        case .notStarted:
                            PracticeStartCard {
                                practice.startOrContinue()
                            }
                        case .inProgress:
                            if let question = practice.currentQuestion {
                                PracticeQuestionView(question: question)
                            } else {
                                PracticeUnavailableView()
                            }
                        case .completed:
                            PracticeResultView(
                                hasPremium: premium.hasPremium,
                                onBackToToday: { dismiss() },
                                onLockedReview: { showPaywall = true }
                            )
                        }
                    }
                    .padding()
                }
                .lexoraPageBackground()
            }
        }
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(LexoraColors.pageBackground, for: .navigationBar)
        .task {
            await practice.loadPracticeIfNeeded()
            practice.startOrContinue()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

private struct PracticeHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Daily Word Practice")
                .font(.lexoraCaption)
                .foregroundStyle(LexoraColors.secondaryText)
                .textCase(.uppercase)
                .tracking(1.4)

            Text("A quiet way to revisit today’s words.")
                .font(.lexoraTitle)
                .foregroundStyle(LexoraColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct PracticeStartCard: View {
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today’s Practice")
                .font(.lexoraHeadline)
                .foregroundStyle(LexoraColors.primaryText)

            Text("10 words. One quiet challenge.")
                .font(.lexoraBody)
                .foregroundStyle(LexoraColors.secondaryText)

            Button(action: onStart) {
                Text("Start Practice")
                    .font(.lexoraHeadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(LexoraColors.primaryText)
                    .foregroundStyle(LexoraColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Start Practice")
        }
        .lexoraCard()
    }
}

private struct PracticeQuestionView: View {
    @EnvironmentObject private var practice: PracticeSessionManager
    let question: PracticeQuestion

    private var isLastQuestion: Bool {
        practice.currentQuestionIndex >= practice.questionCount - 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("\(practice.currentQuestionIndex + 1) / \(practice.questionCount)")
                    .font(.lexoraCaption)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Spacer()

                Text("Practice")
                    .font(.lexoraCaption)
                    .foregroundStyle(LexoraColors.accent)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(question.word)
                    .font(.lexoraDisplay)
                    .foregroundStyle(LexoraColors.primaryText)
                    .minimumScaleFactor(0.72)

                Text(question.language)
                    .font(.lexoraCallout)
                    .foregroundStyle(LexoraColors.secondaryText)
            }

            Text(question.question)
                .font(.lexoraHeadline)
                .foregroundStyle(LexoraColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ForEach(question.choices.indices, id: \.self) { index in
                    PracticeChoiceButton(
                        text: question.choices[index],
                        isSelected: practice.selectedAnswerForCurrentQuestion == index
                    ) {
                        practice.selectAnswer(index)
                    }
                }
            }

            Button {
                practice.advance()
            } label: {
                Text(isLastQuestion ? "Finish Practice" : "Continue")
                    .font(.lexoraHeadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(canContinue ? LexoraColors.primaryText : LexoraColors.border.opacity(0.35))
                    .foregroundStyle(canContinue ? LexoraColors.cardBackground : LexoraColors.secondaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canContinue)
            .accessibilityLabel(isLastQuestion ? "Finish Practice" : "Continue")
        }
        .lexoraCard()
    }

    private var canContinue: Bool {
        practice.selectedAnswerForCurrentQuestion != nil
    }
}

private struct PracticeChoiceButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? LexoraColors.accent : LexoraColors.secondaryText)

                Text(text)
                    .font(.lexoraBody)
                    .foregroundStyle(LexoraColors.primaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(isSelected ? LexoraColors.cardBackgroundSoft.opacity(0.82) : LexoraColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? LexoraColors.accent.opacity(0.55) : LexoraColors.border.opacity(0.62), lineWidth: 0.9)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSelected ? "\(text), selected" : text)
    }
}

private struct PracticeResultView: View {
    @EnvironmentObject private var practice: PracticeSessionManager
    let hasPremium: Bool
    let onBackToToday: () -> Void
    let onLockedReview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Today’s Result")
                .font(.lexoraCaption)
                .foregroundStyle(LexoraColors.secondaryText)
                .textCase(.uppercase)
                .tracking(1.2)

            VStack(alignment: .leading, spacing: 8) {
                Text("\(practice.score ?? 0)/\(practice.questionCount)")
                    .font(.lexoraHero)
                    .foregroundStyle(LexoraColors.primaryText)

                Text(practice.scoreLabel)
                    .font(.lexoraTitle)
                    .foregroundStyle(LexoraColors.accent)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("A small measure of attention for today’s archive.")
                .font(.lexoraBody)
                .foregroundStyle(LexoraColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                Button(action: onBackToToday) {
                    Text("Back to Today")
                        .font(.lexoraHeadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(LexoraColors.primaryText)
                        .foregroundStyle(LexoraColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                if hasPremium {
                    NavigationLink {
                        PracticeReviewView()
                    } label: {
                        Text("Review Answers")
                            .font(.lexoraHeadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(LexoraColors.cardBackgroundSoft)
                            .foregroundStyle(LexoraColors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(LexoraColors.border.opacity(0.72), lineWidth: 0.8)
                            )
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: onLockedReview) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Review Answers")
                        }
                        .font(.lexoraHeadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(LexoraColors.cardBackgroundSoft)
                        .foregroundStyle(LexoraColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(LexoraColors.border.opacity(0.72), lineWidth: 0.8)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Review Answers, Premium required")

                    Text("Premium unlocks answer review after practice.")
                        .font(.lexoraFootnote)
                        .foregroundStyle(LexoraColors.secondaryText)
                }
            }
        }
        .lexoraCard()
    }
}

private struct PracticeReviewView: View {
    @EnvironmentObject private var practice: PracticeSessionManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Answer Review")
                        .font(.lexoraCaption)
                        .foregroundStyle(LexoraColors.secondaryText)
                        .textCase(.uppercase)
                        .tracking(1.2)

                    Text("A quiet look back at today’s choices.")
                        .font(.lexoraTitle)
                        .foregroundStyle(LexoraColors.primaryText)
                }

                ForEach(practice.reviewItems) { item in
                    PracticeReviewRow(item: item)
                }
            }
            .padding()
        }
        .lexoraPageBackground()
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(LexoraColors.pageBackground, for: .navigationBar)
    }
}

private struct PracticeReviewRow: View {
    let item: PracticeReviewItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(item.word)
                    .font(.lexoraHeadline)
                    .foregroundStyle(LexoraColors.primaryText)

                Spacer()

                Label(item.isCorrect ? "Correct" : "Review", systemImage: item.isCorrect ? "checkmark.circle.fill" : "xmark.circle")
                    .font(.lexoraFootnote)
                    .foregroundStyle(item.isCorrect ? LexoraColors.accent : LexoraColors.favorite)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Your answer")
                    .font(.lexoraCaption)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .textCase(.uppercase)
                    .tracking(1.0)

                Text(item.selectedAnswer)
                    .font(.lexoraBody)
                    .foregroundStyle(LexoraColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Correct answer")
                    .font(.lexoraCaption)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .textCase(.uppercase)
                    .tracking(1.0)

                Text(item.correctAnswer)
                    .font(.lexoraBody)
                    .foregroundStyle(LexoraColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .lexoraCard(background: LexoraColors.cardBackground, padding: 16)
        .accessibilityElement(children: .combine)
    }
}

private struct PracticeUnavailableView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Practice is unavailable")
                .font(.lexoraHeadline)
                .foregroundStyle(LexoraColors.primaryText)

            Text("Please try again in a moment.")
                .font(.lexoraBody)
                .foregroundStyle(LexoraColors.secondaryText)
        }
        .lexoraCard()
    }
}
