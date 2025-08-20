import SwiftUI
import SafariServices

struct MovieDetails: View {
    let movie: Movie
    @ObservedObject var viewModel: ProgramListViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    @State private var showingContentNotesList = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showingTrailer = false
    private let headerHeight: CGFloat = 400
    
    init(movie: Movie, viewModel: ProgramListViewModel) {
        self.movie = movie
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Background
                DemoMeshGradientBackground()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header with image and title
                        headerView
                        
                        // Content
                        contentView
                            .padding(.top, 24)
                    }
                    .background(GeometryReader { geo in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geo.frame(in: .global).minY
                        )
                    })
                }
                .ignoresSafeArea(edges: .top)
                .sheet(isPresented: $showingContentNotesList) {
                    ContentNotesListView(contentNotes: movie.contentNotes)
                }
                .sheet(isPresented: $showingTrailer) {
                    if let trailerURL = movie.trailerURL, let url = URL(string: trailerURL) {
                        SafariView(url: url)
                    }
                }
                
                // Custom back button
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("back".localized(languageManager.selectedLanguage))
                            }
                            .font(.abcGramercyDisplayBold(size: 17))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .contentShape(Rectangle())
                            .buttonStyle(ScaleButtonStyle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private var headerView: some View {
        GeometryReader { geo in
            let offset = geo.frame(in: .global).minY
            let height = headerHeight + (offset > 0 ? offset : 0)
            
            ZStack(alignment: .bottom) {
                // Movie image with gradient overlay
                if let imageURL = movie.imageURL, let imageUrl = URL(string: imageURL) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: height)
                            .clipped()
                            .background(
                                DemoMeshGradientBackground()
                            )
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .white, location: 0),
                                        .init(color: .white, location: 0.2),
                                        .init(color: .white, location: 0.4),
                                        .init(color: .white.opacity(0.8), location: 0.6),
                                        .init(color: .white.opacity(0.4), location: 0.8),
                                        .init(color: .clear, location: 1.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } placeholder: {
                        Color.black
                    }
                } else {
                    Color.black
                }
                
                // Movie info overlay
                VStack(spacing: 16) {
                    Text(movie.title)
                        .font(.abcGramercyDisplayBold(size: 34))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 32)
                    

                }
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(.bottom, 32)
            }
        }
        .frame(height: headerHeight)
    }
    
    private var movieInfoText: String {
        var parts: [String] = []
        
        // Country and Language
        if let country = movie.country, !country.isEmpty {
            parts.append(country)
        }
        
        if let lang = movie.originlang, !lang.isEmpty {
            var langText = lang
            if let subtitles = movie.subtitles, !subtitles.isEmpty {
                langText += " (\(subtitles))"
            }
            parts.append(langText)
        }
        
        // Duration
        parts.append("\(movie.duration) min")
        
        // Director
        if let director = movie.director, !director.isEmpty {
            parts.append("Regie: \(director)")
        }
        
        return parts.joined(separator: "  ")
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Movie info section
            VStack(alignment: .leading, spacing: 24) {
                // Movie metadata
                Text(movieInfoText)
                    .font(.cardoItalic(size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Description
                let description = languageManager.selectedLanguage == .german ? movie.description_de : movie.description_fr
                if let description = description {
                    Text(description)
                        .font(.abcGramercyFineLight(size: 16))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
            )
            .padding(.horizontal, 16)
            
            // Action buttons in a horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if !movie.contentNotes.isEmpty {
                        Button {
                            showingContentNotesList = true
                        } label: {
                            Label("Content Notes", systemImage: "exclamationmark.triangle")
                                .font(.abcGramercyFineLight(size: 15))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                    }
                    
                    if movie.trailerURL != nil {
                        Button {
                            showingTrailer = true
                        } label: {
                            Label("Trailer", systemImage: "play.fill")
                                .font(.abcGramercyFineLight(size: 15))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                    }
                    

                }
            }
            .padding(.horizontal, 24)
            
            // Showings section
            VStack(alignment: .leading, spacing: 16) {
                Text("screenings".localized(languageManager.selectedLanguage))
                    .font(.abcGramercyDisplayBold(size: 24))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(movie.showings, id: \.id) { showing in
                        ShowingRow(showing: showing, movie: movie, location: showing.locationID.flatMap(viewModel.getLocationByID), viewModel: viewModel)
                            .environmentObject(languageManager)
                        if showing.id != movie.showings.last?.id {
                            Divider()
                                .background(Color.white.opacity(0.15))
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal, 16)
            }
            
            // Bottom spacing
            Color.clear.frame(height: 32)
        }
    }
}

// MARK: - Supporting Views


private struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct ShowingRow: View {
    let showing: Showing
    let movie: Movie
    let location: Location?
    @ObservedObject var viewModel: ProgramListViewModel
    @EnvironmentObject var languageManager: LanguageManager
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/Zurich")!
        formatter.locale = languageManager.selectedLanguage == .german ? Locale(identifier: "de_CH") : Locale(identifier: "fr_CH")
        formatter.setLocalizedDateFormatFromTemplate("EEEEMMMMdyyyy")
        return formatter
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateFormatter.string(from: showing.date))
                    .font(.abcGramercyDisplayBold(size: 17))
                    .foregroundColor(.white)
                Spacer()
                Text(timeFormatter.string(from: showing.date))
                    .font(.abcGramercyDisplayBold(size: 17))
                    .foregroundColor(.white)
            }
            
            if let locationID = showing.locationID,
               let location = viewModel.getLocationByID(locationID) {
                NavigationLink(destination: LocationDetailView(location: location)) {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(location.name)
                                .font(.abcGramercyFineLight(size: 15))
                            Text(location.address)
                                .font(.abcGramercyFineLight(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .foregroundColor(.white)
                }
            }
            
            if let specialInfo = showing.special_info {
                Text(specialInfo)
                    .font(.abcGramercyFineLight(size: 15))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            if let weblink = showing.weblink, let url = URL(string: weblink) {
                Link(destination: url) {
                    Label("buy_tickets".localized(languageManager.selectedLanguage), systemImage: "ticket")
                        .font(.abcGramercyFineLight(size: 15))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
            
            Button {
                Task {
                    await viewModel.toggleShowing(showing)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.myProgramShowings.contains(where: { $0.id == showing.id }) ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .semibold))
                    Text(viewModel.myProgramShowings.contains(where: { $0.id == showing.id }) ? "remove_from_program".localized(languageManager.selectedLanguage) : "add_to_program".localized(languageManager.selectedLanguage))
                        .font(.abcGramercyFineLight(size: 15))
                }
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.vertical, 8)
    }
}

