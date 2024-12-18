import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    @Binding var color: Color
    @Binding var type: PKInkingTool.InkType
    @Binding var isDraw: Bool
    @State var toolPicker = PKToolPicker()

    var pencil: PKInkingTool {
        PKInkingTool(type, color: UIColor(color))
    }
    let eraser = PKEraserTool(.bitmap)

    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.tool = isDraw ? pencil : eraser
        showToolPicker()
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = isDraw ? pencil : eraser
    }

    private func showToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
    }
}

