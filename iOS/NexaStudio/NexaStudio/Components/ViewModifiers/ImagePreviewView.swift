import SwiftUI
import PhotosUI

struct ImagePreviewView: View {
    let images: [URL]
    let selectedImage: URL?
    @State private var currentIndex: Int = 0
    @State private var toast: AnyToast?
    @State private var showShareSheet: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { i in
                    ZStack {
                        let image = UIImage(contentsOfFile: images[i].path())
                        Image(uiImage: image ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tag(i)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .modalNavigationBar("", action: {
                dismiss()
            })
            .background(Color.Background.primary)
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 8) {
                    button(with: .download)
                        .anyButton {
                            save()
                        }
                    button(with: .squareArrowOutUpRight)
                        .anyButton {
                            showShareSheet = true
                        }

                    button(with: .copy24)
                        .anyButton {
                            let image = UIImage(contentsOfFile: images[currentIndex].path())
                            if let image, let data = image.pngData() {
                                UIPasteboard.general.setData(data, forPasteboardType: "public.png")
                            }
                        }
                }
            }
            .toast($toast)
            .sheet(isPresented: $showShareSheet) {
                let image = UIImage(contentsOfFile: images[currentIndex].path())
                if let image {
                    ShareView(activityItems: [image])
                }
            }
        }
        .onAppear {
            if let index = images.firstIndex(where: { $0 == selectedImage }) {
                currentIndex = index
            }
        }
    }

    private func button(with image: ImageResource) -> some View {
        Image(image)
            .primaryStyle()
            .square(24)
            .padding(12)
            .cornerRadiusBackground(with: Color.Button.Tertiary.Bg.default, cornerRadius: 24, borderColor: Color.Button.Tertiary.Border.default)
            .contentShape(Rectangle())
    }

    private func save() {
        let image = UIImage(contentsOfFile: images[currentIndex].path())
        guard let image else {
            toast = .error("Save fail...")
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                toast = .success("success saved")
            } else {
                toast = .error("We need access to your photo library to save the image.")
            }
        }
    }
}

#Preview {
    ImagePreviewView(images: [URL(string: Constants.randomImage)!, URL(string: Constants.randomImage)!], selectedImage: nil)
}
