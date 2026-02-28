import SwiftUI
import PhotosUI

struct TodayEditSheet: View {
    @Binding var isPresented: Bool
    let onSave: (TodayPost) -> Void

    // Photo library selection
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var libraryImageData: Data? = nil
    @State private var isLibrarySelected = false

    // Scene selection
    @State private var selectedScene: PhotoOption = .campus
    @State private var captionInput = ""
    @FocusState private var captionFocused: Bool

    private var canSave: Bool {
        isLibrarySelected
            ? libraryImageData != nil
            : !captionInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    enum PhotoOption: String, CaseIterable {
        case campus  = "photo_campus"
        case coffee  = "photo_coffee"
        case park    = "photo_park_bench"
        case cherry  = "photo_cherry_blossom"
        case cooking = "photo_home_cooking"
        case sunset  = "photo_sunset"
        case flower  = "photo_flower"

        var label: String {
            switch self {
            case .campus:  "Campus"
            case .coffee:  "Coffee"
            case .park:    "Park"
            case .cherry:  "Cherry"
            case .cooking: "Cooking"
            case .sunset:  "Sunset"
            case .flower:  "Nature"
            }
        }

        var icon: String {
            switch self {
            case .campus:  "building.columns.fill"
            case .coffee:  "cup.and.saucer.fill"
            case .park:    "tree.fill"
            case .cherry:  "leaf.fill"
            case .cooking: "fork.knife"
            case .sunset:  "sun.horizon.fill"
            case .flower:  "camera.macro"
            }
        }

        var gradient: [Color] {
            switch self {
            case .campus:  [.blue.opacity(0.45), .gray.opacity(0.3)]
            case .coffee:  [.brown.opacity(0.55), .orange.opacity(0.3)]
            case .park:    [.green.opacity(0.5), .brown.opacity(0.3)]
            case .cherry:  [.pink.opacity(0.65), .purple.opacity(0.4)]
            case .cooking: [.orange.opacity(0.6), .yellow.opacity(0.3)]
            case .sunset:  [.orange.opacity(0.5), .purple.opacity(0.5)]
            case .flower:  [.orange.opacity(0.5), .pink.opacity(0.4)]
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Header ──────────────────────────────────────────────────────
            HStack {
                Text("Share Your Today")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 20)

            Divider().padding(.horizontal, 24)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // ── Scene / Photo picker ─────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Choose a Scene", systemImage: "photo.on.rectangle")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                // ── Leftmost: Photo Library picker ──────────
                                PhotosPicker(
                                    selection: $pickerItem,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    libraryPickerCell
                                }
                                .buttonStyle(.plain)
                                .onChange(of: pickerItem) { _, newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            libraryImageData = data
                                            isLibrarySelected = true
                                        }
                                    }
                                }

                                // ── Preset scenes ────────────────────────────
                                ForEach(PhotoOption.allCases, id: \.self) { option in
                                    Button {
                                        withAnimation(.spring(response: 0.28)) {
                                            selectedScene = option
                                            isLibrarySelected = false
                                        }
                                    } label: {
                                        sceneCell(option)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 2)
                            .padding(.vertical, 4)
                        }
                    }

                    // ── Preview ──────────────────────────────────────────────
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                colors: isLibrarySelected
                                    ? [.gray.opacity(0.3), .gray.opacity(0.2)]
                                    : selectedScene.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)

                        if isLibrarySelected, let data = libraryImageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else if isLibrarySelected {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.white.opacity(0.5))
                                Text("Tap to choose a photo")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        } else {
                            Image(systemName: selectedScene.icon)
                                .font(.system(size: 42))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                    }
                    .animation(.spring(response: 0.36), value: isLibrarySelected)
                    .animation(.spring(response: 0.36), value: selectedScene)

                    // ── Caption ──────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Caption", systemImage: "text.bubble")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        TextField("What's happening today?", text: $captionInput, axis: .vertical)
                            .focused($captionFocused)
                            .font(.body)
                            .lineLimit(2...4)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 8)
            }

            // ── 24h expiry notice ────────────────────────────────────────────
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 11))
                Text("Your post will disappear after 24 hours.")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 10)
            .padding(.horizontal, 24)

            // ── Action buttons ───────────────────────────────────────────────
            HStack(spacing: 14) {
                Button { isPresented = false } label: {
                    Text("Cancel")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.primary)
                }

                Button {
                    let post = TodayPost(
                        userId: "me",
                        photoName: isLibrarySelected ? "photo_library" : selectedScene.rawValue,
                        imageData: isLibrarySelected ? libraryImageData : nil,
                        caption: captionInput.trimmingCharacters(in: .whitespaces),
                        timestamp: Date(),
                        reactions: []
                    )
                    onSave(post)
                    isPresented = false
                } label: {
                    Text("Share")
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
        .presentationDetents([.medium, .large])
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(28)
    }

    // MARK: - Photo library picker cell

    private var libraryPickerCell: some View {
        let isSelected = isLibrarySelected
        return VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [.indigo.opacity(0.55), .purple.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 64, height: 64)

                if isSelected, let data = libraryImageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "photo.badge.plus")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color(red: 0.22, green: 0.84, blue: 1.0) : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
            .scaleEffect(isSelected ? 1.06 : 1.0)

            Text("Photo")
                .font(.caption2)
                .foregroundStyle(isSelected ? Color(red: 0.22, green: 0.84, blue: 1.0) : .secondary)
        }
    }

    // MARK: - Scene cell

    private func sceneCell(_ option: PhotoOption) -> some View {
        let isSelected = !isLibrarySelected && selectedScene == option
        return VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: option.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 64, height: 64)
                Image(systemName: option.icon)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color(red: 0.22, green: 0.84, blue: 1.0) : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
            .scaleEffect(isSelected ? 1.06 : 1.0)
            Text(option.label)
                .font(.caption2)
                .foregroundStyle(isSelected ? Color(red: 0.22, green: 0.84, blue: 1.0) : .secondary)
        }
    }
}
