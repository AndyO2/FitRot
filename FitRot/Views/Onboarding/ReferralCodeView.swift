#if os(iOS)
import SwiftUI

struct ReferralCodeView: View {
    @AppStorage("referralCode") private var referralCode: String = ""
    @State private var codeInput: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Referral code card
            VStack(alignment: .leading, spacing: 12) {
                Text("Referral Code")
                    .font(.system(size: 15, weight: .bold))

                TextField("Enter code", text: $codeInput)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFocused ? Color.primary.opacity(0.4) : Color.clear, lineWidth: 1.5)
                    )
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .onAppear {
            codeInput = referralCode
        }
        .onChange(of: codeInput) { _, newValue in
            referralCode = newValue.trimmingCharacters(in: .whitespaces)
        }
    }
}

#Preview {
    ReferralCodeView()
}
#endif
