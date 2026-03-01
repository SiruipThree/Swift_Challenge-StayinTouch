import SwiftUI

struct MoodEditSheet: View {
    @Binding var isPresented: Bool
    let onSave: (MoodEntry) -> Void

    @State private var emojiInput    = ""
    @State private var locationInput = ""
    @State private var vibeInput     = ""

    @FocusState private var focusedField: Field?

    private enum Field { case emoji, location, vibe }

    private var canSave: Bool {
        !emojiInput.trimmingCharacters(in: .whitespaces).isEmpty &&
        !vibeInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func dismissSheet() {
        focusedField = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isPresented = false
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Title ────────────────────────────────────────────────────────
            HStack {
                Text("How are you feeling?")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                Spacer()
                Button {
                    dismissSheet()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 20)

            Divider()
                .padding(.horizontal, 24)

            // ── Fields ───────────────────────────────────────────────────────
            VStack(spacing: 18) {

                // Emoji row
                fieldRow(
                    icon: "face.smiling",
                    title: "Emoji",
                    placeholder: "☕️  😊  🌙  💪  …"
                ) {
                    TextField("", text: $emojiInput)
                        .focused($focusedField, equals: .emoji)
                        .font(.title3)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                // Location row
                fieldRow(
                    icon: "mappin.and.ellipse",
                    title: "Location",
                    placeholder: "Home · Library · Café · …"
                ) {
                    TextField("", text: $locationInput)
                        .focused($focusedField, equals: .location)
                        .font(.body)
                        .textInputAutocapitalization(.words)
                }

                // Vibe row
                fieldRow(
                    icon: "sparkles",
                    title: "Vibe",
                    placeholder: "studying · working · chilling · …"
                ) {
                    TextField("", text: $vibeInput)
                        .focused($focusedField, equals: .vibe)
                        .font(.body)
                        .textInputAutocapitalization(.sentences)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            // ── Buttons ──────────────────────────────────────────────────────
            HStack(spacing: 14) {
                Button {
                    dismissSheet()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.primary)
                }

                Button {
                    focusedField = nil
                    let loc = locationInput.trimmingCharacters(in: .whitespaces)
                    let entry = MoodEntry(
                        emoji: emojiInput.trimmingCharacters(in: .whitespaces),
                        label: vibeInput.trimmingCharacters(in: .whitespaces),
                        activity: loc.isEmpty ? "Home" : loc,
                        timestamp: Date()
                    )
                    onSave(entry)
                    isPresented = false
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            canSave
                                ? Color(red: 0.22, green: 0.84, blue: 1.0)
                                : Color.gray.opacity(0.35),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .foregroundStyle(canSave ? .black : .secondary)
                }
                .disabled(!canSave)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .presentationDetents([.medium])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(28)
        .onAppear { focusedField = .emoji }
    }

    @ViewBuilder
    private func fieldRow<Content: View>(
        icon: String,
        title: String,
        placeholder: String,
        @ViewBuilder input: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            ZStack(alignment: .leading) {
                if inputIsEmpty(title) {
                    Text(placeholder)
                        .font(.body)
                        .foregroundStyle(.tertiary)
                }
                input()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func inputIsEmpty(_ title: String) -> Bool {
        switch title {
        case "Emoji":    return emojiInput.isEmpty
        case "Location": return locationInput.isEmpty
        case "Vibe":     return vibeInput.isEmpty
        default:         return true
        }
    }
}
