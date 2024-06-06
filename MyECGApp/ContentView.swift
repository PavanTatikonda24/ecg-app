import SwiftUI
import UIKit

struct ContentView: View {
    @State private var voltageValues: [Double] = []

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hi Pavan!")
            
            List(voltageValues, id: \.self) { value in
                Text("\(value) mV")
            }
            .frame(height: 400) // Adjust the frame as needed

            ECGViewControllerRepresentable(voltageValues: $voltageValues)
                .frame(height: 0) // Hidden but necessary to trigger the data loading
        }
        .padding()
    }
}

struct ECGViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var voltageValues: [Double]

    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        let values = uiViewController.getVoltageValues()
        DispatchQueue.main.async {
            voltageValues = values
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

