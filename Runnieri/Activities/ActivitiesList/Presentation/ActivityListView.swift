import SwiftUI

struct ActivityListView: View {
    @StateObject var viewModel: ActivityListViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.activities) { activity in
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.date)
                        .font(.headline)
                    HStack {
                        Text(activity.distance)
                            .font(.subheadline)
                        Spacer()
                        Text(activity.calories)
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    Text("Duration: \(activity.duration)")
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Activities")
        }
    }
}

#Preview {
    ActivityListView(viewModel: ActivityListViewModel(activitiesRepo: PreviewActivitiesRepo()))
} 
