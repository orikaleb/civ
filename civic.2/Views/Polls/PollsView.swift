import SwiftUI

struct PollsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Text("Polls")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.dynamicBackground(for: appViewModel.themeMode))
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            }
            
            // Scrollable Content
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.polls) { poll in
                        NavigationLink(destination: PollDetailView(poll: poll)) {
                            PollCard(poll: poll)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100) // Add bottom padding to prevent content from being hidden behind tab bar
            }
            .refreshable {
                viewModel.refreshData()
            }
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
    }
}

struct PollDetailView: View {
    let poll: Poll
    @State private var selectedOption: PollOption?
    @State private var hasVoted = false
    @State private var showingVoteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Poll header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(poll.category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        
                        Spacer()
                        
                        if poll.isActive {
                            Text("Active")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    
                    Text(poll.question)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(nil)
                    
                    HStack {
                        Text("Created \(poll.createdAt, style: .relative)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if let endDate = poll.endDate {
                            Text("Ends \(endDate, style: .relative)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Poll options
                VStack(alignment: .leading, spacing: 16) {
                    Text("Options")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(poll.options) { option in
                        PollOptionRow(
                            option: option,
                            totalVotes: poll.totalVotes,
                            isSelected: selectedOption?.id == option.id,
                            hasVoted: hasVoted
                        ) {
                            if !hasVoted {
                                selectedOption = option
                            }
                        }
                    }
                }
                
                // Vote button
                if !hasVoted && poll.isActive {
                    CivicButton("Cast Your Vote") {
                        showingVoteConfirmation = true
                    }
                    .disabled(selectedOption == nil)
                }
                
                // Results summary
                if hasVoted || !poll.isActive {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Results")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Total votes: \(poll.totalVotes)")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100) // Add bottom padding to prevent content from being hidden behind tab bar
        }
        .navigationTitle("Poll Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Confirm Vote", isPresented: $showingVoteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Vote") {
                hasVoted = true
                // Here you would typically send the vote to the backend
            }
        } message: {
            if let selected = selectedOption {
                Text("Are you sure you want to vote for '\(selected.text)'? This action cannot be undone.")
            }
        }
    }
}

struct PollOptionRow: View {
    let option: PollOption
    let totalVotes: Int
    let isSelected: Bool
    let hasVoted: Bool
    let action: () -> Void
    
    private var percentage: Double {
        guard totalVotes > 0 else { return 0 }
        return Double(option.votes) / Double(totalVotes) * 100
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(option.text)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if hasVoted {
                            Text("\(Int(percentage))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if hasVoted {
                        ProgressView(value: percentage, total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(y: 0.8)
                    }
                    
                    if hasVoted {
                        Text("\(option.votes) votes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if isSelected && !hasVoted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .disabled(hasVoted)
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PollsView()
}


