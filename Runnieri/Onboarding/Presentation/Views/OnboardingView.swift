import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                OnboardingPageView(page: page)
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .animation(.easeInOut, value: viewModel.currentPage)
        .overlay(alignment: .bottom) {
            VStack(spacing: 20) {
                if viewModel.isLastPage {
                    Button("Get Started") {
                        viewModel.completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    HStack {
                        if viewModel.currentPage > 0 {
                            Button("Back") {
                                viewModel.onTapPrevious()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Spacer()
                        
                        Button("Next") {
                            viewModel.onTapNext()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
        }
        .alert("Permission Required", isPresented: $viewModel.isPermissionAlertDisplayed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.permissionAlertMessage)
        }
    }
} 
