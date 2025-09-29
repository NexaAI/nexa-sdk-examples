import SwiftUI
import Foundation

struct SliderView: UIViewRepresentable {

    final class Coordinator: NSObject {
        var value: Binding<Float>

        init(value: Binding<Float>) {
            self.value = value
        }

        @objc func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = sender.value
        }
    }

    var thumbColor: UIColor = UIColor.Component.Fills.white
    var minTrackColor: UIColor? = UIColor.Component.Fills.brand
    var maxTrackColor: UIColor? = UIColor.Component.Fills.primary
    var minimumValue: Float = 0.0
    var maximumValue: Float = 1.0
    @Binding var value: Float


    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.thumbTintColor = thumbColor
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        slider.value = value
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue

        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )

        return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.value = self.value
    }

    func makeCoordinator() -> SliderView.Coordinator {
        Coordinator(value: $value)
    }
}

#Preview {
    @Previewable @State var value: Float = 0.5
    SliderView(value: $value)
}
