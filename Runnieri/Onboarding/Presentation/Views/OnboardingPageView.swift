import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPageUIModel
    
    var body: some View {
        VStack(spacing: 20) {
            AnimationView(name: page.imageName)
                .frame(width: 200, height: 200)
            
            Text(page.title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            if page.permissionType != nil {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title)
                    .foregroundStyle(.tint)
            }
        }
        .padding()
    }
} 
