import SwiftUI

struct ActivityTrackerView: View {
    @StateObject var viewModel: ActivityTrackerViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Walking Activity")
                .font(.largeTitle)
                .bold()
                .padding(.top, 60)
            
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Text("Distance:")
                    Text(viewModel.formattedActivity.distance)
                }
                .font(.title2)
                
                HStack(spacing: 8) {
                    Text("Duration:")
                    Text(viewModel.formattedActivity.duration)
                }
                .font(.title2)
                
                HStack(spacing: 8) {
                    Text("Calories:")
                    Text(viewModel.formattedActivity.calories)
                }
                .font(.title2)
                .foregroundColor(.orange)
            }
            
            Spacer()
            
            Button(action: {
                if viewModel.isTracking {
                    viewModel.stopTracking()
                } else {
                    viewModel.startTracking()
                }
            }) {
                Text(viewModel.isTracking ? "Stop" : "Start")
                    .font(.title)
                    .frame(width: 200, height: 60)
                    .background(viewModel.isTracking ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.bottom, 60)
        }
        .alert("Location Permission Denied", isPresented: $viewModel.showPermissionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enable location permissions in Settings to track your activity.")
        }
    }
}

#Preview {
    ActivityTrackerView(
        viewModel: ActivityTrackerViewModel(
            startActivityUseCase: PreviewStartActivityInteractor(),
            stopActivityUseCase: PreviewStopActivityInteractor(),
            locationService: PreviewLocationService(),
            activitiesRepository: PreviewActivitiesRepo()
        )
    )
} 
