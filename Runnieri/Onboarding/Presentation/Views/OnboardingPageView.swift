import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: page.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundStyle(.tint)
                .symbolEffect(.bounce, options: .repeating)
            
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
                    .symbolEffect(.bounce)
            }
        }
        .padding()
    }
} 
