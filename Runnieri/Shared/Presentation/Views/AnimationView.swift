import SwiftUI
import Lottie

struct AnimationView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFit
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        
        // Load the animation from the JSON file
        if let url = Bundle.main.url(forResource: name, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let animation = try LottieAnimation.from(data: data)
                animationView.animation = animation
                animationView.contentMode = contentMode
                animationView.loopMode = loopMode
                animationView.play()
            } catch {
                print("Error loading animation: \(error)")
            }
        } else {
            print("Could not find animation file: \(name).json")
        }
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
} 
