import SwiftUI

struct ShareCardView: View {
    let word: Word

    var body: some View {
        ZStack {
            Color(red: 0.953, green: 0.910, blue: 0.812)

            RoundedRectangle(cornerRadius: 46, style: .continuous)
                .fill(Color(red: 0.984, green: 0.957, blue: 0.902))
                .padding(54)
                .overlay(
                    RoundedRectangle(cornerRadius: 46, style: .continuous)
                        .stroke(Color(red: 0.705, green: 0.596, blue: 0.423), lineWidth: 3)
                        .padding(54)
                )

            VStack(spacing: 34) {
                Text("Lexora")
                    .font(.custom("Times New Roman", size: 38))
                    .textCase(.uppercase)
                    .tracking(8)
                    .foregroundStyle(Color(red: 0.430, green: 0.346, blue: 0.235))

                Spacer(minLength: 70)

                VStack(spacing: 18) {
                    Text(word.category)
                        .font(.custom("Times New Roman", size: 28))
                        .textCase(.uppercase)
                        .tracking(5)
                        .foregroundStyle(Color(red: 0.430, green: 0.346, blue: 0.235))

                    Text(word.word)
                        .font(.custom("Times New Roman", size: 112))
                        .minimumScaleFactor(0.58)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(red: 0.176, green: 0.141, blue: 0.102))

                    Text(word.language)
                        .font(.custom("Times New Roman", size: 36))
                        .foregroundStyle(Color(red: 0.430, green: 0.346, blue: 0.235))

                    if let pronunciation = word.pronunciation, !pronunciation.isEmpty {
                        Text(pronunciation)
                            .font(.custom("Times New Roman", size: 34))
                            .foregroundStyle(Color(red: 0.430, green: 0.346, blue: 0.235))
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.965, green: 0.918, blue: 0.824))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color(red: 0.705, green: 0.596, blue: 0.423), lineWidth: 2)
                            )
                    }
                }

                Text(word.shortMeaning)
                    .font(.custom("Times New Roman", size: 44))
                    .lineSpacing(10)
                    .minimumScaleFactor(0.72)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(red: 0.176, green: 0.141, blue: 0.102))
                    .padding(.horizontal, 72)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 70)

                Text("word of the day")
                    .font(.custom("Times New Roman", size: 30))
                    .textCase(.uppercase)
                    .tracking(4)
                    .foregroundStyle(Color(red: 0.430, green: 0.346, blue: 0.235))
            }
            .padding(.horizontal, 72)
            .padding(.vertical, 76)
        }
        .frame(width: 1080, height: 1080)
    }
}
