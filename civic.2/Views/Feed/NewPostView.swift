import SwiftUI

struct NewPostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var content = ""
    @State private var selectedPostType: PostType = .text
    @State private var showingImagePicker = false
    @State private var selectedImages: [String] = []
    @State private var showingPollCreator = false
    @State private var pollQuestion = ""
    @State private var pollOptions = ["", ""]
    
    let onSubmit: (String, PostType, [String]?, Poll?, PerformanceReference?) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                postTypeSelector
                contentArea
                bottomToolbar
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPollCreator) {
                PollCreatorView(
                    question: $pollQuestion,
                    options: $pollOptions
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView(selectedImages: $selectedImages)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
    }
    
    // MARK: - View Components
    
    private var postTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PostType.allCases, id: \.self) { postType in
                    PostTypeChip(
                        postType: postType,
                        isSelected: selectedPostType == postType
                    ) {
                        selectedPostType = postType
                        if postType == .poll {
                            showingPollCreator = true
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
    }
    
    private var contentArea: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                userInfoSection
                textInputSection
                selectedImagesSection
                pollPreviewSection
                Spacer(minLength: 100)
            }
        }
    }
    
    private var userInfoSection: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: appViewModel.currentUser?.profileImage ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(appViewModel.currentUser?.username ?? "User")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Share your thoughts...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    private var textInputSection: some View {
        TextField("What's happening in your community?", text: $content, axis: .vertical)
            .textFieldStyle(PlainTextFieldStyle())
            .lineLimit(5...10)
            .padding(.horizontal, 16)
    }
    
    private var selectedImagesSection: some View {
        Group {
            if !selectedImages.isEmpty {
                ImagePreviewGrid(images: selectedImages) {
                    selectedImages.removeAll()
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var pollPreviewSection: some View {
        Group {
            if selectedPostType == .poll && !pollQuestion.isEmpty {
                PollPreviewCard(
                    question: pollQuestion,
                    options: pollOptions.filter { !$0.isEmpty }
                )
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var bottomToolbar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                addImageButton
                addPollButton
                Spacer()
                characterCount
                postButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }
    
    private var addImageButton: some View {
        Button(action: {
            showingImagePicker = true
        }) {
            Image(systemName: "photo")
                .font(.title2)
                .foregroundColor(Color.appPrimary)
        }
    }
    
    private var addPollButton: some View {
        Button(action: {
            showingPollCreator = true
        }) {
            Image(systemName: "vote.yea")
                .font(.title2)
                .foregroundColor(Color.appPrimary)
        }
    }
    
    private var characterCount: some View {
        Text("\(content.count)/280")
            .font(.caption)
            .foregroundColor(content.count > 280 ? .red : .secondary)
    }
    
    private var postButton: some View {
        CivicButton(
            "Post",
            isLoading: false
        ) {
            let finalContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
            if !finalContent.isEmpty {
                let poll = selectedPostType == .poll && !pollQuestion.isEmpty ? 
                    Poll(
                        question: pollQuestion,
                        options: pollOptions.filter { !$0.isEmpty }.map { PollOption(text: $0) },
                        endDate: Date().addingTimeInterval(7 * 24 * 3600),
                        category: "Community",
                        createdBy: appViewModel.currentUser?.username ?? "User"
                    ) : nil
                
                onSubmit(
                    finalContent,
                    selectedPostType,
                    selectedImages.isEmpty ? nil : selectedImages,
                    poll,
                    nil // Performance reference will be handled by the calling view
                )
            }
        }
        .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || content.count > 280)
    }
}

struct PostTypeChip: View {
    let postType: PostType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: postType.icon)
                    .font(.caption)
                
                Text(postType.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : Color.appPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.appPrimary : Color.appPrimary.opacity(0.1))
            )
        }
    }
}

struct ImagePreviewGrid: View {
    let images: [String]
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Selected Images")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Remove All", action: onRemove)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageUrl in
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                            )
                    }
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

struct PollPreviewCard: View {
    let question: String
    let options: [String]
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Poll Preview")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(question)
                .font(.body)
                .fontWeight(.medium)
            
            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    HStack {
                        Text(option)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("0%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PollCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var question: String
    @Binding var options: [String]
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Poll Question")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("Enter your question...", text: $question, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .lineLimit(2...4)
                        .padding(12)
                        .background(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Options")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("Add Option") {
                            if options.count < 5 {
                                options.append("")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(Color.appPrimary)
                        .disabled(options.count >= 5)
                    }
                    
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        HStack {
                            TextField("Option \(index + 1)", text: $options[index])
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(12)
                                .background(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
                                .cornerRadius(8)
                            
                            if options.count > 2 {
                                Button(action: {
                                    options.remove(at: index)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .navigationTitle("Create Poll")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(question.isEmpty || options.filter { !$0.isEmpty }.count < 2)
                }
            }
        }
    }
}

struct ImagePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedImages: [String]
    
    // Mock images for demonstration
    private let mockImages = [
        "https://picsum.photos/400/300?random=1",
        "https://picsum.photos/400/300?random=2",
        "https://picsum.photos/400/300?random=3",
        "https://picsum.photos/400/300?random=4",
        "https://picsum.photos/400/300?random=5",
        "https://picsum.photos/400/300?random=6"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 2) {
                    ForEach(mockImages, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(height: 120)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(selectedImages.contains(imageUrl) ? Color.appPrimary : Color.clear, lineWidth: 3)
                        )
                        .onTapGesture {
                            if selectedImages.contains(imageUrl) {
                                selectedImages.removeAll { $0 == imageUrl }
                            } else if selectedImages.count < 4 {
                                selectedImages.append(imageUrl)
                            }
                        }
                    }
                }
                .padding(2)
            }
            .navigationTitle("Select Images")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NewPostView { content, postType, images, poll, performanceRef in
        print("Creating post: \(content)")
    }
    .environmentObject(AppViewModel())
}







