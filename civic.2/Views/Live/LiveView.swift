import SwiftUI

struct LiveView: View {
    @StateObject private var viewModel = LiveViewModel()
    @State private var showingLiveStream = false
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            categoryFilterSection
            liveStreamsContent
        }
        .navigationTitle("Live")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Start a live stream
                }) {
                    Image(systemName: "video.badge.plus")
                        .font(.title2)
                        .foregroundColor(Color.appPrimary)
                }
            }
        }
        .navigationDestination(isPresented: $showingLiveStream) {
            if let currentStream = viewModel.featuredStream {
                LiveStreamView(stream: currentStream, viewModel: viewModel)
            }
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
    }
    
    // MARK: - View Components
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                allCategoriesButton
                categoryFilterButtons
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
    }
    
    private var allCategoriesButton: some View {
        Button(action: {
            viewModel.setCategoryFilter(nil)
        }) {
            HStack(spacing: 4) {
                Image(systemName: "play.circle.fill")
                    .font(.caption)
                Text("All")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(viewModel.selectedCategory == nil ? .white : Color.appPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(viewModel.selectedCategory == nil ? Color.appPrimary : Color.appPrimary.opacity(0.1))
            )
        }
    }
    
    private var categoryFilterButtons: some View {
        ForEach(LiveStreamCategory.allCases, id: \.self) { category in
            categoryFilterButton(for: category)
        }
    }
    
    private func categoryFilterButton(for category: LiveStreamCategory) -> some View {
        Button(action: {
            viewModel.setCategoryFilter(category)
        }) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(viewModel.selectedCategory == category ? .white : category.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(viewModel.selectedCategory == category ? category.color : category.color.opacity(0.1))
            )
        }
    }
    
    private var liveStreamsContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredStreams) { stream in
                    LiveStreamCard(stream: stream) {
                        viewModel.joinStream(stream)
                        showingLiveStream = true
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .refreshable {
            // Refresh live streams
        }
    }
}

// MARK: - Live Stream Components

struct LiveStreamCard: View {
    let stream: LiveStream
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Thumbnail with live indicator
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: stream.thumbnailUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(height: 200)
                    .clipped()
                    
                    // Live indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("LIVE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.9))
                    .cornerRadius(12)
                    .padding(8)
                }
                
                // Stream info
                VStack(alignment: .leading, spacing: 8) {
                    Text(stream.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    HStack {
                        AsyncImage(url: URL(string: stream.thumbnailUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        
                        Text(stream.createdBy)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(stream.viewerCount) watching")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .buttonStyle(PlainButtonStyle())
    }
}

struct LiveStreamView: View {
    let stream: LiveStream
    @ObservedObject var viewModel: LiveViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Stream header
            HStack {
                Button("Back") {
                    dismiss()
                }
                
                Spacer()
                
                Text(stream.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    // Handle leaving stream
                }) {
                    Image(systemName: "video.slash")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            // Stream content placeholder
            Rectangle()
                .fill(Color.black)
                .overlay(
                    VStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("Live Stream")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Stream would play here")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                )
            
            // Stream info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AsyncImage(url: URL(string: stream.thumbnailUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(stream.createdBy)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Live Now")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("\(stream.viewerCount)")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Viewers")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(stream.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.systemBackground))
        }
        .onAppear {
            viewModel.joinStream(stream)
        }
        .onDisappear {
            // Handle leaving stream
        }
    }
}


#Preview {
    LiveView()
        .environmentObject(AppViewModel())
}