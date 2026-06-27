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

    private var selectedAnswerIndex: Int? {
        practice.selectedAnswerForCurrentQuestion
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
                        feedback: feedback(for: index)
                    ) {
                        practice.selectAnswer(index)
                    }
                }
            }

            HStack(spacing: 10) {
                Button {
                    practice.moveBackward()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.lexoraHeadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(practice.canMoveBackward ? LexoraColors.cardBackgroundSoft : LexoraColors.border.opacity(0.24))
                        .foregroundStyle(practice.canMoveBackward ? LexoraColors.accent : LexoraColors.secondaryText.opacity(0.72))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(LexoraColors.border.opacity(0.68), lineWidth: 0.8)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!practice.canMoveBackward)
                .accessibilityLabel("Back")

                Button {
                    practice.advance()
                } label: {
                    Text(nextButtonTitle)
                        .font(.lexoraHeadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(canContinue ? LexoraColors.primaryText : LexoraColors.border.opacity(0.35))
                        .foregroundStyle(canContinue ? LexoraColors.cardBackground : LexoraColors.secondaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!canContinue)
                .accessibilityLabel(nextButtonTitle)
            }
        }
        .lexoraCard()
    }

    private var canContinue: Bool {
        if isLastQuestion {
            return practice.hasAnsweredCurrentQuestion && practice.allQuestionsAnswered
        }

        return practice.hasAnsweredCurrentQuestion
    }

    private var nextButtonTitle: String {
        isLastQuestion ? "Complete Practice" : "Next"
    }

    private func feedback(for index: Int) -> PracticeChoiceFeedback {
        guard let selectedAnswerIndex else { return .unanswered }

        if index == question.correctIndex {
            return index == selectedAnswerIndex ? .selectedCorrect : .correctAnswer
        }

        if index == selectedAnswerIndex {
            return .selectedIncorrect
        }

        return .answeredNeutral
    }
}

private enum PracticeChoiceFeedback {
    case unanswered
    case answeredNeutral
    case selectedCorrect
    case selectedIncorrect
    case correctAnswer

    var isLocked: Bool {
        self != .unanswered
    }

    var isSelected: Bool {
        switch self {
        case .selectedCorrect, .selectedIncorrect:
            return true
        case .unanswered, .answeredNeutral, .correctAnswer:
            return false
        }
    }

    var background: Color {
        switch self {
        case .selectedCorrect, .correctAnswer:
            return Color(red: 0.880, green: 0.925, blue: 0.850)
        case .selectedIncorrect:
            return Color(red: 0.950, green: 0.870, blue: 0.850)
        case .answeredNeutral:
            return LexoraColors.cardBackground.opacity(0.72)
        case .unanswered:
            return LexoraColors.cardBackground
        }
    }

    var border: Color {
        switch self {
        case .selectedCorrect, .correctAnswer:
            return Color(red: 0.420, green: 0.545, blue: 0.345)
        case .selectedIncorrect:
            return Color(red: 0.610, green: 0.305, blue: 0.270)
        case .answeredNeutral, .unanswered:
            return LexoraColors.border.opacity(0.62)
        }
    }

    var foreground: Color {
        switch self {
        case .selectedCorrect, .correctAnswer:
            return Color(red: 0.250, green: 0.380, blue: 0.205)
        case .selectedIncorrect:
            return Color(red: 0.500, green: 0.210, blue: 0.180)
        case .answeredNeutral, .unanswered:
            return LexoraColors.secondaryText
        }
    }

    var iconName: String {
        switch self {
        case .selectedCorrect:
            return "checkmark.circle.fill"
        case .selectedIncorrect:
            return "xmark.circle.fill"
        case .correctAnswer:
            return "checkmark.circle"
        case .answeredNeutral:
            return "circle"
        case .unanswered:
            return "circle"
        }
    }

    var statusText: String? {
        switch self {
        case .selectedCorrect:
            return "Correct"
        case .selectedIncorrect:
            return "Your answer"
        case .correctAnswer:
            return "Correct answer"
        case .unanswered, .answeredNeutral:
            return nil
        }
    }

    var accessibilityStatus: String {
        switch self {
        case .selectedCorrect:
            return "selected answer, correct"
        case .selectedIncorrect:
            return "selected answer, incorrect"
        case .correctAnswer:
            return "correct answer"
        case .answeredNeutral:
            return "not selected"
        case .unanswered:
            return "not selected"
        }
    }
}

private struct PracticeChoiceButton: View {
    let text: String
    let feedback: PracticeChoiceFeedback
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: feedback.iconName)
                    .font(.title3)
                    .foregroundStyle(feedback.foreground)

                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(.lexoraBody)
                        .foregroundStyle(LexoraColors.primaryText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    if let statusText = feedback.statusText {
                        Text(statusText)
                            .font(.lexoraFootnote)
                            .foregroundStyle(feedback.foreground)
                            .textCase(.uppercase)
                            .tracking(0.8)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(feedback.background)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(feedback.border.opacity(0.72), lineWidth: feedback.isSelected ? 1.1 : 0.9)
            )
        }
        .buttonStyle(.plain)
        .disabled(feedback.isLocked)
        .accessibilityLabel("\(text), \(feedback.accessibilityStatus)")
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
