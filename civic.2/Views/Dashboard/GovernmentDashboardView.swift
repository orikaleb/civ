import SwiftUI

struct GovernmentDashboardView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedCategory: DashboardCategory = .all
    @State private var showingFeedback = false
    @State private var feedbackText = ""
    @State private var selectedDetail: DashboardDetail?
    @State private var showingNewPost = false
    @State private var performanceToShare: PerformanceCardData?
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.dynamicBackground(for: appViewModel.themeMode))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
            }
            
            // Scrollable Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Performance Cards
                        performanceCardsSection
                    
                    // Category Filter
                    categoryFilterSection
                    
                    // Charts Section
                    chartsSection
                    
                    // Citizen Feedback
                    citizenFeedbackSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .padding(.bottom, 100) // Add bottom padding to prevent content from being hidden behind tab bar
            }
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
        .navigationBarHidden(true)
        .navigationDestination(item: $selectedDetail) { detail in
            DashboardDetailView(detail: detail)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
        .sheet(isPresented: $showingNewPost) {
            if let performanceData = performanceToShare {
                NewPostView(
                    onSubmit: { content, postType, images, poll, _ in
                        // Handle post creation with performance reference
                        let performanceRef = PerformanceReference(
                            title: performanceData.title,
                            percentage: performanceData.percentage,
                            change: performanceData.change,
                            category: performanceData.category.displayName,
                            icon: performanceData.icon,
                            colorName: colorToName(performanceData.color)
                        )
                        
                        // Create post with performance reference
                        let post = Post(
                            userId: appViewModel.currentUser?.id ?? "",
                            username: appViewModel.currentUser?.username ?? "",
                            userProfileImage: appViewModel.currentUser?.profileImage,
                            content: content,
                            postType: .performance,
                            images: images,
                            poll: poll,
                            performanceReference: performanceRef
                        )
                        
                        // Add to feed (this would typically be handled by a view model)
                        // For now, we'll just dismiss
                        showingNewPost = false
                        performanceToShare = nil
                    }
                )
                .environmentObject(appViewModel)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Government")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.primary)
                    
                    Text("Performance Dashboard")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Last Updated")
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text("Aug 2025")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                )
            }
            
            // Subtle divider
            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }
    
    // MARK: - Performance Cards Section
    // MARK: - Filtered Performance Cards
    private var filteredPerformanceCards: [PerformanceCardData] {
        let allCards = [
            PerformanceCardData(
                title: "Economy",
                percentage: 68,
                change: -2,
                icon: "circle.fill",
                color: .red,
                category: .economy
            ),
            PerformanceCardData(
                title: "Health",
                percentage: 72,
                change: 5,
                icon: "cross.circle.fill",
                color: .green,
                category: .health
            ),
            PerformanceCardData(
                title: "Education",
                percentage: 81,
                change: 8,
                icon: "graduationcap.fill",
                color: .blue,
                category: .education
            ),
            PerformanceCardData(
                title: "Security",
                percentage: 54,
                change: -6,
                icon: "shield.fill",
                color: .orange,
                category: .security
            ),
            PerformanceCardData(
                title: "Energy",
                percentage: 76,
                change: 3,
                icon: "bolt.circle.fill",
                color: .yellow,
                category: .economy // Energy is part of economy
            ),
            PerformanceCardData(
                title: "Food Security",
                percentage: 63,
                change: -1,
                icon: "leaf.circle.fill",
                color: .mint,
                category: .health // Food security is part of health
            )
        ]
        
        if selectedCategory == .all {
            return allCards
        } else {
            return allCards.filter { $0.category == selectedCategory }
        }
    }
    
    private var performanceCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Performance Indicators")
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(filteredPerformanceCards, id: \.title) { cardData in
                    PerformanceCard(
                        title: cardData.title,
                        percentage: cardData.percentage,
                        change: cardData.change,
                        icon: cardData.icon,
                        color: cardData.color,
                        onTap: { showDetail(for: cardData.title, change: cardData.change) },
                        onShare: { sharePerformanceData(cardData) }
                    )
                }
            }
        }
    }

    private func showDetail(for title: String, change: Int) {
        // Create the detail object
        let detail: DashboardDetail
        if change >= 0 {
            detail = DashboardDetail(
                title: title,
                isImproved: true,
                items: improvementItems[title] ?? [
                    KPIItem(
                        title: "Expanded Access",
                        description: "Government initiatives to improve public service accessibility and reach.",
                        category: "Public Service",
                        impact: "Medium Impact",
                        relatedArticles: [],
                        charts: [],
                        images: []
                    )
                ]
            )
        } else {
            detail = DashboardDetail(
                title: title,
                isImproved: false,
                items: declineItems[title] ?? [
                    KPIItem(
                        title: "Funding Constraints",
                        description: "Budget limitations affecting service delivery and program implementation.",
                        category: "Budget",
                        impact: "High Impact",
                        relatedArticles: [],
                        charts: [],
                        images: []
                    )
                ]
            )
        }
        
        // Set the selected detail for navigation
        selectedDetail = detail
    }
    
    private func sharePerformanceData(_ cardData: PerformanceCardData) {
        performanceToShare = cardData
        showingNewPost = true
    }
    
    private func colorToName(_ color: Color) -> String {
        // Convert Color to string name for storage
        switch color {
        case .red: return "red"
        case .green: return "green"
        case .blue: return "blue"
        case .orange: return "orange"
        case .yellow: return "yellow"
        case .mint: return "mint"
        default: return "primary"
        }
    }

    private var improvementItems: [String: [KPIItem]] {[
        "Economy": [
            KPIItem(
                title: "SME Tax Relief Enacted",
                description: "Government implemented comprehensive tax relief measures for small and medium enterprises to boost economic growth and job creation across all sectors.",
                category: "Tax Policy",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "SME Tax Relief Boosts Local Businesses", source: "Ghana Business News", date: Date(), url: "", summary: "New tax relief measures show positive impact on small business growth."),
                    Article(title: "Economic Recovery Through Tax Incentives", source: "Financial Times Ghana", date: Date(), url: "", summary: "Analysis of government tax relief program effectiveness."),
                    Article(title: "Small Business Growth Surges", source: "Daily Graphic", date: Date(), url: "", summary: "Local entrepreneurs report increased investment and hiring.")
                ],
                charts: [
                    ChartData(title: "SME Growth Rate", type: .line, data: [("Jan", 2.1), ("Feb", 2.8), ("Mar", 3.2), ("Apr", 3.5), ("May", 3.8), ("Jun", 4.1), ("Jul", 4.3), ("Aug", 4.5)], color: .green)
                ],
                images: ["sme_tax_relief", "business_growth", "entrepreneurs"]
            ),
            KPIItem(
                title: "Local Manufacturing Grants",
                description: "Financial support provided to local manufacturers to enhance production capacity, improve competitiveness, and create sustainable employment opportunities.",
                category: "Manufacturing",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Manufacturing Sector Receives Boost", source: "Industrial Weekly", date: Date(), url: "", summary: "Government grants help local manufacturers expand operations."),
                    Article(title: "Local Production Capacity Increases", source: "Manufacturing Today", date: Date(), url: "", summary: "Grant recipients report 30% increase in production output.")
                ],
                charts: [
                    ChartData(title: "Manufacturing Output", type: .bar, data: [("Q1", 85), ("Q2", 92), ("Q3", 88), ("Q4", 95), ("Q1+1", 98), ("Q2+1", 102)], color: .blue)
                ],
                images: ["manufacturing_grants", "production_facility", "factory_workers"]
            ),
            KPIItem(
                title: "Export Facilitation Program",
                description: "Streamlined export procedures and reduced bureaucratic barriers to boost international trade and foreign exchange earnings.",
                category: "Trade Policy",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Export Procedures Simplified", source: "Trade Journal", date: Date(), url: "", summary: "New digital platform reduces export processing time by 50%."),
                    Article(title: "Foreign Exchange Earnings Rise", source: "Economic Times", date: Date(), url: "", summary: "Export facilitation leads to 15% increase in forex earnings.")
                ],
                charts: [
                    ChartData(title: "Export Volume", type: .line, data: [("Jan", 120), ("Feb", 135), ("Mar", 142), ("Apr", 158), ("May", 165), ("Jun", 172)], color: .orange)
                ],
                images: ["export_docks", "shipping_containers", "customs_office"]
            ),
            KPIItem(
                title: "Digital Infrastructure Investment",
                description: "Major investments in digital infrastructure to support e-commerce, digital payments, and online business operations.",
                category: "Technology",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Digital Infrastructure Expansion", source: "Tech Ghana", date: Date(), url: "", summary: "Government invests $50M in digital infrastructure upgrades."),
                    Article(title: "E-commerce Growth Accelerates", source: "Digital Business", date: Date(), url: "", summary: "Improved digital infrastructure drives 40% e-commerce growth.")
                ],
                charts: [
                    ChartData(title: "Digital Adoption Rate", type: .bar, data: [("2022", 35), ("2023", 48), ("2024", 62), ("2025", 75)], color: .purple)
                ],
                images: ["digital_infrastructure", "fiber_cables", "data_center"]
            ),
            KPIItem(
                title: "Agricultural Modernization Initiative",
                description: "Comprehensive program to modernize agricultural practices, improve yields, and support rural economic development.",
                category: "Agriculture",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Farmers Adopt Modern Techniques", source: "Agricultural Weekly", date: Date(), url: "", summary: "Modernization program reaches 10,000 farmers nationwide."),
                    Article(title: "Crop Yields Increase Significantly", source: "Farm Journal", date: Date(), url: "", summary: "Average crop yields increase by 25% with new techniques.")
                ],
                charts: [
                    ChartData(title: "Crop Yield Improvement", type: .line, data: [("Q1", 100), ("Q2", 108), ("Q3", 115), ("Q4", 125), ("Q1+1", 130), ("Q2+1", 135)], color: .green)
                ],
                images: ["modern_farming", "tractor_field", "harvest_celebration"]
            ),
            KPIItem(
                title: "Tourism Development Program",
                description: "Strategic investments in tourism infrastructure and marketing to boost visitor numbers and hospitality sector growth.",
                category: "Tourism",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Tourist Arrivals Increase", source: "Tourism Today", date: Date(), url: "", summary: "New marketing campaign attracts 20% more international visitors."),
                    Article(title: "Hospitality Sector Booms", source: "Hotel & Resort News", date: Date(), url: "", summary: "Hotels report 85% occupancy rates during peak season.")
                ],
                charts: [
                    ChartData(title: "Tourist Arrivals", type: .bar, data: [("Jan", 45), ("Feb", 52), ("Mar", 68), ("Apr", 75), ("May", 82), ("Jun", 88)], color: .cyan)
                ],
                images: ["tourist_attractions", "hotel_resort", "cultural_festival"]
            )
        ],
        "Health": [
            KPIItem(
                title: "Primary Care Clinics Upgraded",
                description: "Comprehensive upgrades to primary healthcare facilities across the country to improve service delivery and patient outcomes.",
                category: "Healthcare Infrastructure",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Healthcare Access Improves Nationwide", source: "Health Ghana", date: Date(), url: "", summary: "Upgraded clinics provide better healthcare services to communities."),
                    Article(title: "Patient Wait Times Reduced", source: "Medical Journal", date: Date(), url: "", summary: "New facilities reduce average wait time from 3 hours to 45 minutes.")
                ],
                charts: [
                    ChartData(title: "Patient Satisfaction", type: .pie, data: [("Satisfied", 75), ("Neutral", 20), ("Dissatisfied", 5)], color: .green)
                ],
                images: ["clinic_upgrade", "healthcare_workers", "modern_equipment"]
            ),
            KPIItem(
                title: "Vaccine Rollout Accelerated",
                description: "Massive vaccination campaign to improve immunization coverage and prevent disease outbreaks across all age groups.",
                category: "Public Health",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Immunization Rates Reach 90%", source: "Public Health News", date: Date(), url: "", summary: "National vaccination campaign achieves record immunization coverage."),
                    Article(title: "Disease Outbreaks Prevented", source: "Epidemiology Today", date: Date(), url: "", summary: "Vaccination program prevents 5 major disease outbreaks this year.")
                ],
                charts: [
                    ChartData(title: "Vaccination Coverage", type: .line, data: [("Jan", 65), ("Feb", 72), ("Mar", 78), ("Apr", 82), ("May", 85), ("Jun", 88), ("Jul", 90), ("Aug", 92)], color: .blue)
                ],
                images: ["vaccination_center", "health_workers", "vaccine_cold_chain"]
            ),
            KPIItem(
                title: "Frontline Staff Hiring",
                description: "Recruitment and training of additional healthcare professionals to address staffing shortages and improve service quality.",
                category: "Human Resources",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "5,000 New Healthcare Workers Hired", source: "HR Today", date: Date(), url: "", summary: "Government recruits and trains thousands of new healthcare professionals."),
                    Article(title: "Staff-to-Patient Ratio Improves", source: "Healthcare Management", date: Date(), url: "", summary: "New hires reduce staff-to-patient ratio from 1:50 to 1:25.")
                ],
                charts: [
                    ChartData(title: "Healthcare Staff Growth", type: .bar, data: [("2022", 15), ("2023", 18), ("2024", 22), ("2025", 28)], color: .green)
                ],
                images: ["new_doctors", "nurse_training", "medical_students"]
            ),
            KPIItem(
                title: "Mental Health Services Expansion",
                description: "Comprehensive mental health program including new facilities, trained professionals, and community outreach initiatives.",
                category: "Mental Health",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Mental Health Awareness Campaign", source: "Psychology Today", date: Date(), url: "", summary: "National campaign reduces mental health stigma by 40%."),
                    Article(title: "New Mental Health Centers Open", source: "Wellness Weekly", date: Date(), url: "", summary: "20 new mental health centers provide services to underserved areas.")
                ],
                charts: [
                    ChartData(title: "Mental Health Service Access", type: .line, data: [("Q1", 25), ("Q2", 32), ("Q3", 38), ("Q4", 45), ("Q1+1", 52), ("Q2+1", 58)], color: .purple)
                ],
                images: ["mental_health_center", "counseling_session", "community_outreach"]
            ),
            KPIItem(
                title: "Emergency Response System",
                description: "Enhanced emergency medical services with improved response times, better equipment, and trained paramedics.",
                category: "Emergency Services",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Emergency Response Time Cut in Half", source: "Emergency Medicine", date: Date(), url: "", summary: "New system reduces average response time from 30 to 15 minutes."),
                    Article(title: "Lives Saved Through Quick Response", source: "Medical Emergency News", date: Date(), url: "", summary: "Improved emergency services save 200+ lives in first quarter.")
                ],
                charts: [
                    ChartData(title: "Emergency Response Time", type: .line, data: [("Jan", 30), ("Feb", 28), ("Mar", 25), ("Apr", 22), ("May", 20), ("Jun", 18), ("Jul", 16), ("Aug", 15)], color: .red)
                ],
                images: ["ambulance_fleet", "paramedics", "emergency_equipment"]
            ),
            KPIItem(
                title: "Telemedicine Platform Launch",
                description: "Digital healthcare platform enabling remote consultations, reducing travel costs, and improving access to specialists.",
                category: "Digital Health",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Telemedicine Reaches Rural Areas", source: "Digital Health News", date: Date(), url: "", summary: "New platform connects rural patients with urban specialists."),
                    Article(title: "Healthcare Costs Reduced", source: "Health Economics", date: Date(), url: "", summary: "Telemedicine reduces patient travel costs by 60%.")
                ],
                charts: [
                    ChartData(title: "Telemedicine Consultations", type: .bar, data: [("Jan", 500), ("Feb", 750), ("Mar", 1200), ("Apr", 1800), ("May", 2200), ("Jun", 2800)], color: .cyan)
                ],
                images: ["telemedicine_setup", "video_consultation", "mobile_health_app"]
            )
        ],
        "Education": [
            KPIItem(
                title: "Teacher Training Program",
                description: "Comprehensive training program for educators to improve teaching quality, student outcomes, and classroom management skills.",
                category: "Teacher Development",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Teachers Receive Advanced Training", source: "Education Today", date: Date(), url: "", summary: "New training program enhances teaching methodologies across schools."),
                    Article(title: "Student Test Scores Improve", source: "Academic Review", date: Date(), url: "", summary: "Trained teachers report 25% improvement in student performance.")
                ],
                charts: [
                    ChartData(title: "Student Performance", type: .line, data: [("2022", 65), ("2023", 72), ("2024", 78), ("2025", 85)], color: .blue)
                ],
                images: ["teacher_training", "classroom_improvement", "student_success"]
            ),
            KPIItem(
                title: "STEM Curriculum Update",
                description: "Modernized science, technology, engineering, and mathematics curriculum to prepare students for future careers.",
                category: "Curriculum Development",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "STEM Education Revolution", source: "Science Education", date: Date(), url: "", summary: "New curriculum includes coding, robotics, and advanced mathematics."),
                    Article(title: "Student Interest in STEM Grows", source: "Technology in Education", date: Date(), url: "", summary: "STEM enrollment increases by 40% after curriculum update.")
                ],
                charts: [
                    ChartData(title: "STEM Enrollment", type: .bar, data: [("2022", 35), ("2023", 42), ("2024", 48), ("2025", 55)], color: .green)
                ],
                images: ["stem_laboratory", "coding_class", "robotics_workshop"]
            ),
            KPIItem(
                title: "School Infrastructure Rehabilitation",
                description: "Comprehensive renovation and modernization of school buildings, classrooms, and learning facilities nationwide.",
                category: "Infrastructure",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "500 Schools Renovated", source: "Infrastructure Weekly", date: Date(), url: "", summary: "Major renovation program improves learning environments across the country."),
                    Article(title: "Student Attendance Increases", source: "Education Statistics", date: Date(), url: "", summary: "Improved facilities lead to 15% increase in student attendance.")
                ],
                charts: [
                    ChartData(title: "School Condition Index", type: .line, data: [("Q1", 45), ("Q2", 52), ("Q3", 58), ("Q4", 65), ("Q1+1", 72), ("Q2+1", 78)], color: .orange)
                ],
                images: ["renovated_classroom", "new_library", "modern_cafeteria"]
            ),
            KPIItem(
                title: "Digital Learning Platform",
                description: "Implementation of comprehensive digital learning management system with online resources and interactive content.",
                category: "Digital Education",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Digital Learning Reaches Rural Schools", source: "EdTech News", date: Date(), url: "", summary: "Online platform provides quality education to remote areas."),
                    Article(title: "Student Engagement Soars", source: "Learning Analytics", date: Date(), url: "", summary: "Digital tools increase student engagement by 60%.")
                ],
                charts: [
                    ChartData(title: "Digital Platform Usage", type: .bar, data: [("Jan", 1200), ("Feb", 1800), ("Mar", 2500), ("Apr", 3200), ("May", 3800), ("Jun", 4500)], color: .purple)
                ],
                images: ["digital_classroom", "online_learning", "tablet_students"]
            ),
            KPIItem(
                title: "Scholarship Program Expansion",
                description: "Increased funding for merit-based and need-based scholarships to improve access to quality education.",
                category: "Student Support",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "10,000 New Scholarships Awarded", source: "Student Affairs", date: Date(), url: "", summary: "Expanded scholarship program helps more students access education."),
                    Article(title: "University Enrollment Increases", source: "Higher Education", date: Date(), url: "", summary: "Scholarship program boosts university enrollment by 30%.")
                ],
                charts: [
                    ChartData(title: "Scholarship Recipients", type: .line, data: [("2022", 5000), ("2023", 6500), ("2024", 8000), ("2025", 10000)], color: .cyan)
                ],
                images: ["scholarship_ceremony", "graduation_cap", "happy_students"]
            ),
            KPIItem(
                title: "Early Childhood Education Initiative",
                description: "Comprehensive program to improve early childhood education with trained teachers and age-appropriate facilities.",
                category: "Early Education",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Kindergarten Enrollment Doubles", source: "Early Education Today", date: Date(), url: "", summary: "New initiative makes early education accessible to more children."),
                    Article(title: "Reading Skills Improve", source: "Literacy Foundation", date: Date(), url: "", summary: "Early education program improves reading readiness by 45%.")
                ],
                charts: [
                    ChartData(title: "Early Education Enrollment", type: .bar, data: [("2022", 25), ("2023", 35), ("2024", 45), ("2025", 55)], color: .pink)
                ],
                images: ["kindergarten_class", "children_reading", "playground_activities"]
            )
        ],
        "Security": [
            KPIItem(
                title: "Community Patrols Expanded",
                description: "Increased community policing initiatives to enhance security, reduce crime rates, and build trust with local communities.",
                category: "Public Safety",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Community Policing Reduces Crime", source: "Security Weekly", date: Date(), url: "", summary: "Expanded patrols show significant reduction in local crime rates."),
                    Article(title: "Public Trust in Police Increases", source: "Community Relations", date: Date(), url: "", summary: "Community policing improves police-community relations by 35%.")
                ],
                charts: [
                    ChartData(title: "Crime Reduction", type: .bar, data: [("Theft", -15), ("Assault", -8), ("Burglary", -12), ("Robbery", -20), ("Fraud", -10)], color: .green)
                ],
                images: ["community_patrol", "police_officers", "neighborhood_watch"]
            ),
            KPIItem(
                title: "CCTV Coverage Increased",
                description: "Strategic installation of surveillance cameras in high-crime areas and public spaces to enhance security monitoring.",
                category: "Surveillance",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Crime Detection Rate Improves", source: "Security Technology", date: Date(), url: "", summary: "CCTV system helps solve 40% more crimes through video evidence."),
                    Article(title: "Public Safety Perception Rises", source: "Community Survey", date: Date(), url: "", summary: "Residents report feeling 25% safer with increased surveillance.")
                ],
                charts: [
                    ChartData(title: "CCTV Coverage Area", type: .line, data: [("Q1", 30), ("Q2", 45), ("Q3", 60), ("Q4", 75), ("Q1+1", 85), ("Q2+1", 92)], color: .blue)
                ],
                images: ["cctv_cameras", "monitoring_center", "security_control"]
            ),
            KPIItem(
                title: "Inter-agency Coordination Improved",
                description: "Enhanced collaboration between police, military, and intelligence agencies for better security coordination and response.",
                category: "Coordination",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Security Agencies Work Together", source: "Defense News", date: Date(), url: "", summary: "New coordination protocols improve response to security threats."),
                    Article(title: "Intelligence Sharing Increases", source: "Security Intelligence", date: Date(), url: "", summary: "Inter-agency cooperation prevents 15 major security incidents.")
                ],
                charts: [
                    ChartData(title: "Coordination Effectiveness", type: .bar, data: [("2022", 60), ("2023", 70), ("2024", 80), ("2025", 88)], color: .orange)
                ],
                images: ["security_meeting", "inter_agency_drill", "coordination_center"]
            ),
            KPIItem(
                title: "Border Security Enhancement",
                description: "Strengthened border control measures with advanced technology and increased personnel to prevent illegal activities.",
                category: "Border Control",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Border Security Technology Upgraded", source: "Border Security News", date: Date(), url: "", summary: "New scanning equipment and surveillance systems improve border control."),
                    Article(title: "Illegal Crossings Reduced", source: "Immigration Report", date: Date(), url: "", summary: "Enhanced border security reduces illegal crossings by 50%.")
                ],
                charts: [
                    ChartData(title: "Border Incidents", type: .line, data: [("Jan", 25), ("Feb", 22), ("Mar", 18), ("Apr", 15), ("May", 12), ("Jun", 10), ("Jul", 8), ("Aug", 6)], color: .red)
                ],
                images: ["border_checkpoint", "security_scanner", "border_patrol"]
            ),
            KPIItem(
                title: "Cyber Security Initiative",
                description: "Comprehensive cyber security program to protect government systems and critical infrastructure from digital threats.",
                category: "Cyber Security",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Government Systems Protected", source: "Cyber Security Today", date: Date(), url: "", summary: "New cyber security measures prevent 200+ attempted breaches."),
                    Article(title: "Digital Infrastructure Secured", source: "IT Security", date: Date(), url: "", summary: "Critical infrastructure protected from cyber attacks.")
                ],
                charts: [
                    ChartData(title: "Cyber Threats Blocked", type: .bar, data: [("Jan", 45), ("Feb", 52), ("Mar", 38), ("Apr", 42), ("May", 35), ("Jun", 28)], color: .purple)
                ],
                images: ["cyber_security_center", "network_monitoring", "digital_protection"]
            ),
            KPIItem(
                title: "Emergency Response System",
                description: "Enhanced emergency response capabilities with improved communication systems and rapid deployment protocols.",
                category: "Emergency Response",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Emergency Response Time Improved", source: "Emergency Services", date: Date(), url: "", summary: "New system reduces emergency response time by 40%."),
                    Article(title: "Disaster Preparedness Enhanced", source: "Crisis Management", date: Date(), url: "", summary: "Improved protocols help manage 3 major emergencies effectively.")
                ],
                charts: [
                    ChartData(title: "Response Time (minutes)", type: .line, data: [("Jan", 25), ("Feb", 22), ("Mar", 20), ("Apr", 18), ("May", 16), ("Jun", 15), ("Jul", 14), ("Aug", 13)], color: .red)
                ],
                images: ["emergency_center", "response_vehicles", "communication_system"]
            )
        ],
        "Energy": [
            KPIItem(
                title: "Renewable Energy Expansion",
                description: "Major investments in solar, wind, and hydroelectric power generation to increase clean energy capacity and reduce dependence on fossil fuels.",
                category: "Clean Energy",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Solar Farm Projects Launch", source: "Energy Today", date: Date(), url: "", summary: "Government announces $200M investment in solar energy infrastructure."),
                    Article(title: "Wind Power Capacity Doubles", source: "Renewable Energy News", date: Date(), url: "", summary: "New wind farms increase clean energy generation by 150%.")
                ],
                charts: [
                    ChartData(title: "Renewable Energy Capacity", type: .line, data: [("2022", 45), ("2023", 58), ("2024", 72), ("2025", 85)], color: .green)
                ],
                images: ["solar_panels", "wind_turbines", "hydro_dam"]
            ),
            KPIItem(
                title: "Grid Modernization Program",
                description: "Comprehensive upgrade of national electricity grid to improve reliability, reduce transmission losses, and support increased renewable energy integration.",
                category: "Infrastructure",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Smart Grid Implementation", source: "Power Systems", date: Date(), url: "", summary: "Advanced grid technology reduces power outages by 40%."),
                    Article(title: "Transmission Efficiency Improves", source: "Electrical Engineering", date: Date(), url: "", summary: "Grid modernization cuts transmission losses by 25%.")
                ],
                charts: [
                    ChartData(title: "Grid Reliability Index", type: .bar, data: [("Q1", 78), ("Q2", 82), ("Q3", 85), ("Q4", 88), ("Q1+1", 91)], color: .blue)
                ],
                images: ["smart_grid", "transmission_towers", "control_center"]
            ),
            KPIItem(
                title: "Energy Storage Solutions",
                description: "Deployment of large-scale battery storage systems to stabilize renewable energy supply and ensure consistent power availability.",
                category: "Storage Technology",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Battery Storage Facilities Open", source: "Storage Solutions", date: Date(), url: "", summary: "New battery storage systems provide 500MW backup capacity."),
                    Article(title: "Energy Storage Costs Drop", source: "Tech Innovation", date: Date(), url: "", summary: "Battery technology costs decrease by 30% enabling wider adoption.")
                ],
                charts: [
                    ChartData(title: "Storage Capacity (MW)", type: .line, data: [("Jan", 200), ("Feb", 250), ("Mar", 300), ("Apr", 350), ("May", 400), ("Jun", 450)], color: .orange)
                ],
                images: ["battery_facility", "energy_storage", "power_management"]
            ),
            KPIItem(
                title: "Rural Electrification Initiative",
                description: "Expansion of electricity access to remote rural communities through mini-grids and off-grid renewable energy solutions.",
                category: "Rural Development",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Rural Communities Get Power", source: "Rural Development", date: Date(), url: "", summary: "500 rural communities connected to electricity through renewable mini-grids."),
                    Article(title: "Off-Grid Solutions Transform Lives", source: "Community Impact", date: Date(), url: "", summary: "Solar home systems provide reliable power to 50,000 rural households.")
                ],
                charts: [
                    ChartData(title: "Rural Electrification Rate", type: .bar, data: [("2022", 65), ("2023", 72), ("2024", 78), ("2025", 84)], color: .green)
                ],
                images: ["rural_solar", "mini_grid", "village_power"]
            ),
            KPIItem(
                title: "Energy Efficiency Programs",
                description: "Government initiatives to promote energy-efficient appliances, building standards, and industrial processes to reduce overall energy consumption.",
                category: "Efficiency",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Energy-Efficient Appliance Subsidies", source: "Consumer News", date: Date(), url: "", summary: "Government provides 30% subsidy on energy-efficient appliances."),
                    Article(title: "Building Standards Updated", source: "Construction Weekly", date: Date(), url: "", summary: "New building codes require 20% better energy efficiency.")
                ],
                charts: [
                    ChartData(title: "Energy Efficiency Index", type: .line, data: [("Q1", 70), ("Q2", 73), ("Q3", 76), ("Q4", 79), ("Q1+1", 82)], color: .purple)
                ],
                images: ["efficient_appliances", "green_building", "energy_audit"]
            )
        ],
        "Food Security": [
            KPIItem(
                title: "Agricultural Technology Adoption",
                description: "Promotion of modern farming techniques, precision agriculture, and smart irrigation systems to increase crop yields and farming efficiency.",
                category: "Agricultural Innovation",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Precision Agriculture Boosts Yields", source: "Farm Technology", date: Date(), url: "", summary: "Smart farming techniques increase crop yields by 35%."),
                    Article(title: "Drones Revolutionize Farming", source: "Agricultural Innovation", date: Date(), url: "", summary: "Drone technology helps farmers monitor crops and optimize irrigation.")
                ],
                charts: [
                    ChartData(title: "Crop Yield (tons/hectare)", type: .line, data: [("2022", 2.8), ("2023", 3.2), ("2024", 3.6), ("2025", 4.1)], color: .green)
                ],
                images: ["precision_farming", "agricultural_drones", "smart_irrigation"]
            ),
            KPIItem(
                title: "Food Storage Infrastructure",
                description: "Construction of modern grain silos, cold storage facilities, and food processing plants to reduce post-harvest losses and ensure food availability.",
                category: "Infrastructure",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Modern Grain Silos Reduce Losses", source: "Storage Solutions", date: Date(), url: "", summary: "New storage facilities cut post-harvest losses by 40%."),
                    Article(title: "Cold Storage Network Expands", source: "Food Processing", date: Date(), url: "", summary: "Cold storage facilities extend shelf life of perishable foods.")
                ],
                charts: [
                    ChartData(title: "Post-Harvest Loss Reduction", type: .bar, data: [("2022", 25), ("2023", 20), ("2024", 16), ("2025", 12)], color: .blue)
                ],
                images: ["grain_silos", "cold_storage", "food_processing"]
            ),
            KPIItem(
                title: "Climate-Resilient Crop Development",
                description: "Research and development of drought-resistant, flood-tolerant, and high-yield crop varieties to ensure food production under changing climate conditions.",
                category: "Research & Development",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Drought-Resistant Crops Developed", source: "Agricultural Research", date: Date(), url: "", summary: "New crop varieties survive 30% longer without water."),
                    Article(title: "Climate-Smart Agriculture Grows", source: "Climate Adaptation", date: Date(), url: "", summary: "Climate-resilient farming practices adopted by 60% of farmers.")
                ],
                charts: [
                    ChartData(title: "Climate-Resilient Crop Adoption", type: .line, data: [("2022", 35), ("2023", 48), ("2024", 62), ("2025", 75)], color: .orange)
                ],
                images: ["resilient_crops", "research_facility", "field_testing"]
            ),
            KPIItem(
                title: "Food Distribution Networks",
                description: "Improvement of transportation and logistics systems to ensure efficient food distribution from production areas to markets and consumers.",
                category: "Logistics",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Food Distribution Network Upgraded", source: "Logistics Today", date: Date(), url: "", summary: "New distribution centers reduce food transport time by 50%."),
                    Article(title: "Mobile Markets Reach Remote Areas", source: "Rural Development", date: Date(), url: "", summary: "Mobile food markets serve 200 remote communities.")
                ],
                charts: [
                    ChartData(title: "Food Distribution Efficiency", type: .bar, data: [("Q1", 68), ("Q2", 72), ("Q3", 75), ("Q4", 78), ("Q1+1", 81)], color: .green)
                ],
                images: ["distribution_center", "food_trucks", "logistics_network"]
            ),
            KPIItem(
                title: "Nutritional Security Programs",
                description: "Government initiatives to improve nutritional quality of food, promote diverse diets, and address malnutrition through fortified foods and education.",
                category: "Nutrition",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Fortified Foods Reduce Malnutrition", source: "Nutrition Science", date: Date(), url: "", summary: "Fortified staple foods reduce micronutrient deficiencies by 45%."),
                    Article(title: "Nutrition Education Programs Launch", source: "Public Health", date: Date(), url: "", summary: "Community nutrition education reaches 1 million households.")
                ],
                charts: [
                    ChartData(title: "Malnutrition Reduction Rate", type: .line, data: [("2022", 18), ("2023", 15), ("2024", 12), ("2025", 9)], color: .red)
                ],
                images: ["fortified_foods", "nutrition_education", "health_workers"]
            )
        ]
    ]}

    private var declineItems: [String: [KPIItem]] {[
        "Economy": [
            KPIItem(
                title: "Global Commodity Slowdown",
                description: "International commodity price fluctuations affecting local export revenues and economic growth across multiple sectors.",
                category: "Global Markets",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Commodity Prices Impact Local Economy", source: "Economic Review", date: Date(), url: "", summary: "Global market trends affecting Ghana's export sector."),
                    Article(title: "Export Revenue Declines", source: "Trade Journal", date: Date(), url: "", summary: "Commodity price drops reduce export earnings by 15%."),
                    Article(title: "Mining Sector Struggles", source: "Mining Weekly", date: Date(), url: "", summary: "Gold and cocoa prices hit 3-year lows.")
                ],
                charts: [
                    ChartData(title: "Export Revenue", type: .line, data: [("Jan", 120), ("Feb", 115), ("Mar", 108), ("Apr", 102), ("May", 98), ("Jun", 95), ("Jul", 92), ("Aug", 88)], color: .red)
                ],
                images: ["commodity_prices", "export_docks", "mining_site"]
            ),
            KPIItem(
                title: "Credit Access Tightened",
                description: "Restrictive lending policies and high interest rates limiting business expansion and investment opportunities.",
                category: "Financial Services",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Banking Sector Tightens Lending", source: "Financial Times", date: Date(), url: "", summary: "Interest rates rise to 25%, affecting business loans."),
                    Article(title: "SMEs Struggle for Funding", source: "Business Daily", date: Date(), url: "", summary: "Small businesses report 40% reduction in loan approvals.")
                ],
                charts: [
                    ChartData(title: "Loan Approval Rate", type: .bar, data: [("Q1", 65), ("Q2", 58), ("Q3", 52), ("Q4", 45), ("Q1+1", 38), ("Q2+1", 32)], color: .red)
                ],
                images: ["bank_building", "loan_documents", "business_owner"]
            ),
            KPIItem(
                title: "Delayed Capital Projects",
                description: "Infrastructure development projects postponed due to funding constraints and bureaucratic delays.",
                category: "Infrastructure",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Infrastructure Projects Delayed", source: "Construction Weekly", date: Date(), url: "", summary: "15 major projects postponed due to funding issues."),
                    Article(title: "Road Construction Stalls", source: "Infrastructure News", date: Date(), url: "", summary: "Highway projects face 6-month delays.")
                ],
                charts: [
                    ChartData(title: "Project Completion Rate", type: .line, data: [("Jan", 85), ("Feb", 82), ("Mar", 78), ("Apr", 75), ("May", 72), ("Jun", 68), ("Jul", 65), ("Aug", 62)], color: .orange)
                ],
                images: ["construction_site", "delayed_project", "infrastructure_plan"]
            ),
            KPIItem(
                title: "Inflation Pressure",
                description: "Rising inflation rates affecting consumer purchasing power and business operational costs.",
                category: "Monetary Policy",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Inflation Hits 18%", source: "Economic Times", date: Date(), url: "", summary: "Consumer prices rise significantly, affecting living costs."),
                    Article(title: "Business Costs Soar", source: "Business Review", date: Date(), url: "", summary: "Operating expenses increase by 22% for local businesses.")
                ],
                charts: [
                    ChartData(title: "Inflation Rate", type: .line, data: [("Jan", 12), ("Feb", 13.5), ("Mar", 15), ("Apr", 16.5), ("May", 17.2), ("Jun", 18), ("Jul", 18.5), ("Aug", 19)], color: .red)
                ],
                images: ["shopping_market", "price_tags", "inflation_chart"]
            ),
            KPIItem(
                title: "Foreign Investment Decline",
                description: "Reduced foreign direct investment due to global economic uncertainty and local policy concerns.",
                category: "Investment",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "FDI Drops by 30%", source: "Investment Weekly", date: Date(), url: "", summary: "Foreign investment reaches 5-year low."),
                    Article(title: "Investor Confidence Wanes", source: "Capital Markets", date: Date(), url: "", summary: "Global investors pull back from emerging markets.")
                ],
                charts: [
                    ChartData(title: "Foreign Investment", type: .bar, data: [("2022", 2.5), ("2023", 2.1), ("2024", 1.8), ("2025", 1.5)], color: .red)
                ],
                images: ["investment_meeting", "foreign_office", "capital_flow"]
            ),
            KPIItem(
                title: "Unemployment Rate Increase",
                description: "Rising unemployment due to economic slowdown and reduced job creation in key sectors.",
                category: "Labor Market",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Unemployment Reaches 12%", source: "Labor Statistics", date: Date(), url: "", summary: "Job market shows signs of stress."),
                    Article(title: "Youth Unemployment Crisis", source: "Youth Development", date: Date(), url: "", summary: "25% of young people unable to find work.")
                ],
                charts: [
                    ChartData(title: "Unemployment Rate", type: .line, data: [("Q1", 8.5), ("Q2", 9.2), ("Q3", 10.1), ("Q4", 11.2), ("Q1+1", 12.0), ("Q2+1", 12.8)], color: .red)
                ],
                images: ["job_center", "unemployed_workers", "employment_office"]
            )
        ],
        "Health": [
            KPIItem(
                title: "Drug Supply Interruptions",
                description: "Temporary disruptions in pharmaceutical supply chain affecting healthcare delivery and patient outcomes.",
                category: "Supply Chain",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Healthcare Supply Chain Challenges", source: "Medical News", date: Date(), url: "", summary: "Supply chain issues impact drug availability in healthcare facilities."),
                    Article(title: "Essential Medicines Shortage", source: "Pharmacy Today", date: Date(), url: "", summary: "Critical medications unavailable in 40% of facilities.")
                ],
                charts: [
                    ChartData(title: "Drug Availability", type: .bar, data: [("Essential", 85), ("Non-essential", 60), ("Specialty", 45), ("Emergency", 70), ("Chronic", 55)], color: .orange)
                ],
                images: ["pharmacy_supply", "healthcare_facility", "medicine_shortage"]
            ),
            KPIItem(
                title: "Facility Maintenance Backlog",
                description: "Deferred maintenance on healthcare infrastructure leading to equipment failures and service disruptions.",
                category: "Infrastructure",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Hospital Equipment Failures", source: "Healthcare Infrastructure", date: Date(), url: "", summary: "Critical equipment breakdowns increase by 35%."),
                    Article(title: "Maintenance Budget Cuts", source: "Health Finance", date: Date(), url: "", summary: "Facility maintenance funding reduced by 20%.")
                ],
                charts: [
                    ChartData(title: "Equipment Functionality", type: .line, data: [("Jan", 88), ("Feb", 85), ("Mar", 82), ("Apr", 79), ("May", 76), ("Jun", 73), ("Jul", 70), ("Aug", 67)], color: .red)
                ],
                images: ["broken_equipment", "maintenance_worker", "hospital_room"]
            ),
            KPIItem(
                title: "Rising Case Severity",
                description: "Increase in complex medical cases requiring specialized care and longer treatment periods.",
                category: "Patient Care",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Complex Cases Increase", source: "Medical Journal", date: Date(), url: "", summary: "Severe cases rise by 25%, straining resources."),
                    Article(title: "Specialist Shortage", source: "Healthcare Staffing", date: Date(), url: "", summary: "Lack of specialists affects patient outcomes.")
                ],
                charts: [
                    ChartData(title: "Case Severity Index", type: .bar, data: [("Mild", 45), ("Moderate", 35), ("Severe", 20), ("Critical", 15), ("Emergency", 12)], color: .red)
                ],
                images: ["intensive_care", "medical_team", "patient_monitoring"]
            ),
            KPIItem(
                title: "Healthcare Worker Burnout",
                description: "High stress levels and workload leading to increased staff turnover and reduced service quality.",
                category: "Human Resources",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Healthcare Workers Quit", source: "Medical Staff News", date: Date(), url: "", summary: "15% of healthcare workers leave profession."),
                    Article(title: "Burnout Crisis", source: "Healthcare Psychology", date: Date(), url: "", summary: "80% of staff report high stress levels.")
                ],
                charts: [
                    ChartData(title: "Staff Retention Rate", type: .line, data: [("Q1", 85), ("Q2", 82), ("Q3", 78), ("Q4", 75), ("Q1+1", 72), ("Q2+1", 68)], color: .red)
                ],
                images: ["tired_doctor", "staff_meeting", "healthcare_worker"]
            ),
            KPIItem(
                title: "Patient Wait Times Increase",
                description: "Longer waiting periods for appointments and procedures due to resource constraints.",
                category: "Service Delivery",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Wait Times Double", source: "Patient Care", date: Date(), url: "", summary: "Average wait time increases from 2 to 4 hours."),
                    Article(title: "Appointment Backlog", source: "Healthcare Access", date: Date(), url: "", summary: "50,000 patients waiting for specialist appointments.")
                ],
                charts: [
                    ChartData(title: "Average Wait Time (hours)", type: .line, data: [("Jan", 2.1), ("Feb", 2.3), ("Mar", 2.6), ("Apr", 2.9), ("May", 3.2), ("Jun", 3.5), ("Jul", 3.8), ("Aug", 4.1)], color: .red)
                ],
                images: ["waiting_room", "appointment_book", "patient_queue"]
            ),
            KPIItem(
                title: "Preventive Care Decline",
                description: "Reduced access to preventive healthcare services leading to late-stage disease detection.",
                category: "Preventive Care",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Screening Rates Drop", source: "Preventive Medicine", date: Date(), url: "", summary: "Cancer screening rates fall by 30%."),
                    Article(title: "Late Diagnosis Increase", source: "Medical Diagnosis", date: Date(), url: "", summary: "Advanced stage diseases rise by 40%.")
                ],
                charts: [
                    ChartData(title: "Preventive Care Uptake", type: .bar, data: [("Vaccinations", 65), ("Screenings", 45), ("Check-ups", 55), ("Health Education", 35), ("Wellness Programs", 25)], color: .orange)
                ],
                images: ["vaccination_clinic", "health_screening", "preventive_care"]
            )
        ],
        "Education": [
            KPIItem(
                title: "Teacher Attrition",
                description: "High turnover rate among educators affecting continuity in student learning across all levels.",
                category: "Human Resources",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Teacher Retention Challenges", source: "Education Weekly", date: Date(), url: "", summary: "High teacher turnover rates impact educational quality."),
                    Article(title: "Teachers Leave Profession", source: "Teaching Today", date: Date(), url: "", summary: "20% of teachers quit within first 3 years.")
                ],
                charts: [
                    ChartData(title: "Teacher Retention", type: .line, data: [("2022", 75), ("2023", 68), ("2024", 62), ("2025", 58)], color: .red)
                ],
                images: ["teacher_shortage", "empty_classroom", "education_crisis"]
            ),
            KPIItem(
                title: "Infrastructure Deterioration",
                description: "Aging school buildings and facilities requiring urgent repairs and modernization.",
                category: "Infrastructure",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "School Buildings Collapse", source: "Infrastructure Report", date: Date(), url: "", summary: "5 schools closed due to structural issues."),
                    Article(title: "Classroom Shortage", source: "Education Infrastructure", date: Date(), url: "", summary: "Need for 2,000 new classrooms nationwide.")
                ],
                charts: [
                    ChartData(title: "Facility Condition Index", type: .bar, data: [("Excellent", 15), ("Good", 25), ("Fair", 30), ("Poor", 20), ("Critical", 10)], color: .red)
                ],
                images: ["dilapidated_school", "construction_needed", "classroom_shortage"]
            ),
            KPIItem(
                title: "Student Performance Decline",
                description: "Decreasing academic achievement scores and learning outcomes across multiple subjects.",
                category: "Academic Performance",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Test Scores Drop", source: "Academic Review", date: Date(), url: "", summary: "National exam scores fall by 12%."),
                    Article(title: "Learning Gap Widens", source: "Education Research", date: Date(), url: "", summary: "Rural-urban achievement gap increases.")
                ],
                charts: [
                    ChartData(title: "Average Test Scores", type: .line, data: [("2022", 68), ("2023", 65), ("2024", 62), ("2025", 59)], color: .red)
                ],
                images: ["test_papers", "student_struggling", "academic_performance"]
            ),
            KPIItem(
                title: "Digital Divide Widens",
                description: "Unequal access to technology and digital learning resources affecting educational equity.",
                category: "Technology Access",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Rural Schools Lack Internet", source: "Digital Education", date: Date(), url: "", summary: "60% of rural schools have no internet access."),
                    Article(title: "Device Shortage", source: "EdTech News", date: Date(), url: "", summary: "Students share devices at 5:1 ratio.")
                ],
                charts: [
                    ChartData(title: "Digital Access Rate", type: .bar, data: [("Urban", 75), ("Rural", 25), ("Private Schools", 90), ("Public Schools", 45), ("Remote Areas", 15)], color: .orange)
                ],
                images: ["computer_lab", "digital_divide", "technology_gap"]
            ),
            KPIItem(
                title: "Dropout Rate Increase",
                description: "Rising number of students leaving school before completion due to various socio-economic factors.",
                category: "Student Retention",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Dropout Crisis", source: "Student Affairs", date: Date(), url: "", summary: "High school dropout rate reaches 18%."),
                    Article(title: "Economic Pressure", source: "Education Economics", date: Date(), url: "", summary: "Families pull children out to work.")
                ],
                charts: [
                    ChartData(title: "Dropout Rate", type: .line, data: [("2022", 12), ("2023", 14), ("2024", 16), ("2025", 18)], color: .red)
                ],
                images: ["empty_desk", "student_working", "dropout_crisis"]
            ),
            KPIItem(
                title: "Curriculum Relevance Issues",
                description: "Outdated curriculum not aligned with current job market needs and technological advancements.",
                category: "Curriculum Development",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Skills Mismatch", source: "Education Policy", date: Date(), url: "", summary: "Graduates lack skills needed for modern jobs."),
                    Article(title: "Curriculum Overhaul Needed", source: "Educational Reform", date: Date(), url: "", summary: "Current curriculum 10 years behind industry needs.")
                ],
                charts: [
                    ChartData(title: "Curriculum Relevance Score", type: .bar, data: [("STEM", 45), ("Vocational", 35), ("Arts", 60), ("Languages", 70), ("Technology", 30)], color: .orange)
                ],
                images: ["outdated_textbook", "modern_workplace", "curriculum_meeting"]
            )
        ],
        "Security": [
            KPIItem(
                title: "Cross-border Incidents",
                description: "Security challenges at border regions affecting national security and trade across all entry points.",
                category: "Border Security",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Border Security Challenges", source: "Security Report", date: Date(), url: "", summary: "Cross-border incidents require enhanced security measures."),
                    Article(title: "Illegal Crossings Increase", source: "Border Patrol", date: Date(), url: "", summary: "Unauthorized entries rise by 40%.")
                ],
                charts: [
                    ChartData(title: "Incident Frequency", type: .line, data: [("Jan", 5), ("Feb", 8), ("Mar", 12), ("Apr", 10), ("May", 15), ("Jun", 18), ("Jul", 22), ("Aug", 25)], color: .red)
                ],
                images: ["border_patrol", "security_checkpoint", "border_incident"]
            ),
            KPIItem(
                title: "Cyber Security Vulnerabilities",
                description: "Inadequate protection against cyber threats targeting government systems and critical infrastructure.",
                category: "Cyber Security",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Government Systems Hacked", source: "Cyber Security News", date: Date(), url: "", summary: "Multiple government websites compromised."),
                    Article(title: "Data Breach Incidents", source: "IT Security", date: Date(), url: "", summary: "Personal data of 100,000 citizens exposed.")
                ],
                charts: [
                    ChartData(title: "Cyber Attacks", type: .line, data: [("Jan", 15), ("Feb", 18), ("Mar", 22), ("Apr", 25), ("May", 28), ("Jun", 32), ("Jul", 35), ("Aug", 38)], color: .red)
                ],
                images: ["cyber_attack", "computer_security", "data_breach"]
            ),
            KPIItem(
                title: "Community Policing Breakdown",
                description: "Deteriorating relationship between police and communities affecting crime prevention and reporting.",
                category: "Community Relations",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Police-Community Tension", source: "Community Relations", date: Date(), url: "", summary: "Trust levels drop to 35% in urban areas."),
                    Article(title: "Crime Reporting Decreases", source: "Law Enforcement", date: Date(), url: "", summary: "Citizens reluctant to report crimes.")
                ],
                charts: [
                    ChartData(title: "Community Trust Level", type: .line, data: [("2022", 65), ("2023", 58), ("2024", 52), ("2025", 45)], color: .red)
                ],
                images: ["police_community", "trust_meeting", "community_tension"]
            ),
            KPIItem(
                title: "Organized Crime Increase",
                description: "Rising organized criminal activities including drug trafficking, human smuggling, and financial crimes.",
                category: "Organized Crime",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Drug Cartels Expand", source: "Crime Investigation", date: Date(), url: "", summary: "International drug networks establish local operations."),
                    Article(title: "Money Laundering Cases", source: "Financial Crimes", date: Date(), url: "", summary: "Complex financial crimes increase by 60%.")
                ],
                charts: [
                    ChartData(title: "Organized Crime Cases", type: .bar, data: [("Drug Trafficking", 45), ("Human Smuggling", 25), ("Money Laundering", 35), ("Arms Dealing", 15), ("Cyber Crime", 30)], color: .red)
                ],
                images: ["organized_crime", "drug_bust", "money_laundering"]
            ),
            KPIItem(
                title: "Emergency Response Delays",
                description: "Inadequate emergency response capabilities leading to delayed assistance during crises and disasters.",
                category: "Emergency Services",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Emergency Response Slow", source: "Emergency Services", date: Date(), url: "", summary: "Average response time increases to 45 minutes."),
                    Article(title: "Disaster Preparedness Weak", source: "Crisis Management", date: Date(), url: "", summary: "Limited resources for natural disaster response.")
                ],
                charts: [
                    ChartData(title: "Response Time (minutes)", type: .line, data: [("Jan", 25), ("Feb", 28), ("Mar", 32), ("Apr", 35), ("May", 38), ("Jun", 42), ("Jul", 45), ("Aug", 48)], color: .red)
                ],
                images: ["emergency_vehicle", "disaster_response", "crisis_management"]
            ),
            KPIItem(
                title: "Intelligence Gathering Weakness",
                description: "Insufficient intelligence capabilities for proactive threat detection and prevention.",
                category: "Intelligence",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Intelligence Gaps", source: "Security Intelligence", date: Date(), url: "", summary: "Limited capacity for threat assessment."),
                    Article(title: "Information Sharing Poor", source: "Intelligence Cooperation", date: Date(), url: "", summary: "Agencies fail to share critical information.")
                ],
                charts: [
                    ChartData(title: "Intelligence Effectiveness", type: .bar, data: [("Threat Detection", 40), ("Information Sharing", 35), ("Analysis Quality", 45), ("Prevention Rate", 30), ("Coordination", 25)], color: .orange)
                ],
                images: ["intelligence_center", "information_sharing", "threat_analysis"]
            )
        ],
        "Energy": [
            KPIItem(
                title: "Power Grid Instability",
                description: "Frequent power outages and grid failures affecting electricity supply reliability across urban and rural areas.",
                category: "Grid Infrastructure",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Power Outages Increase", source: "Energy Report", date: Date(), url: "", summary: "Grid instability causes 30% more power outages this quarter."),
                    Article(title: "Aging Infrastructure Fails", source: "Power Systems", date: Date(), url: "", summary: "Outdated transmission lines and equipment cause frequent failures.")
                ],
                charts: [
                    ChartData(title: "Outage Frequency (hours/month)", type: .line, data: [("Jan", 45), ("Feb", 52), ("Mar", 48), ("Apr", 61), ("May", 58), ("Jun", 67)], color: .red)
                ],
                images: ["power_outage", "grid_failure", "transmission_tower"]
            ),
            KPIItem(
                title: "Fossil Fuel Dependence",
                description: "High reliance on imported fossil fuels for electricity generation, making the energy sector vulnerable to price fluctuations and supply disruptions.",
                category: "Energy Security",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Fuel Import Costs Rise", source: "Energy Economics", date: Date(), url: "", summary: "Fossil fuel imports increase energy costs by 25%."),
                    Article(title: "Supply Chain Vulnerabilities", source: "Energy Security", date: Date(), url: "", summary: "International fuel supply disruptions affect local power generation.")
                ],
                charts: [
                    ChartData(title: "Fossil Fuel Dependency", type: .bar, data: [("Coal", 35), ("Oil", 28), ("Gas", 22), ("Renewables", 15)], color: .orange)
                ],
                images: ["fossil_fuel_plant", "oil_tanker", "coal_mine"]
            ),
            KPIItem(
                title: "Renewable Energy Integration Challenges",
                description: "Technical and regulatory barriers preventing effective integration of renewable energy sources into the national grid.",
                category: "Renewable Integration",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Grid Integration Issues", source: "Renewable Energy", date: Date(), url: "", summary: "Technical challenges limit renewable energy capacity to 20%."),
                    Article(title: "Regulatory Barriers", source: "Energy Policy", date: Date(), url: "", summary: "Outdated regulations slow renewable energy adoption.")
                ],
                charts: [
                    ChartData(title: "Renewable Integration Rate", type: .line, data: [("2022", 12), ("2023", 15), ("2024", 18), ("2025", 20)], color: .yellow)
                ],
                images: ["solar_panels_disconnected", "wind_turbine_offline", "grid_connection"]
            ),
            KPIItem(
                title: "Energy Access Inequality",
                description: "Significant disparities in electricity access between urban and rural areas, with many rural communities lacking reliable power.",
                category: "Energy Equity",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Rural Electrification Lags", source: "Rural Development", date: Date(), url: "", summary: "Only 40% of rural areas have reliable electricity access."),
                    Article(title: "Urban-Rural Energy Gap", source: "Energy Access", date: Date(), url: "", summary: "Urban areas have 90% electrification while rural areas have 40%.")
                ],
                charts: [
                    ChartData(title: "Electrification Rate by Region", type: .bar, data: [("Urban", 90), ("Rural", 40), ("Remote", 15)], color: .red)
                ],
                images: ["rural_village_dark", "urban_lights", "energy_inequality"]
            ),
            KPIItem(
                title: "Energy Efficiency Deficiencies",
                description: "Low energy efficiency standards and practices leading to excessive energy consumption and waste across residential and industrial sectors.",
                category: "Energy Efficiency",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Energy Waste Increases", source: "Efficiency Report", date: Date(), url: "", summary: "Poor efficiency practices waste 30% of generated electricity."),
                    Article(title: "Building Standards Lacking", source: "Construction News", date: Date(), url: "", summary: "Most buildings don't meet modern energy efficiency standards.")
                ],
                charts: [
                    ChartData(title: "Energy Efficiency Index", type: .line, data: [("2022", 45), ("2023", 42), ("2024", 40), ("2025", 38)], color: .orange)
                ],
                images: ["energy_waste", "inefficient_building", "power_meter"]
            )
        ],
        "Food Security": [
            KPIItem(
                title: "Climate Change Impact on Agriculture",
                description: "Increasing frequency of droughts, floods, and extreme weather events severely affecting crop yields and food production.",
                category: "Climate Impact",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Drought Reduces Crop Yields", source: "Agricultural Report", date: Date(), url: "", summary: "Prolonged drought causes 40% reduction in staple crop production."),
                    Article(title: "Flooding Destroys Farmland", source: "Climate Impact", date: Date(), url: "", summary: "Severe flooding damages 25% of agricultural land.")
                ],
                charts: [
                    ChartData(title: "Crop Yield Reduction (%)", type: .line, data: [("2022", 15), ("2023", 25), ("2024", 35), ("2025", 40)], color: .red)
                ],
                images: ["drought_field", "flooded_farm", "withered_crops"]
            ),
            KPIItem(
                title: "Post-Harvest Losses",
                description: "Significant food losses due to inadequate storage facilities, poor transportation, and lack of processing infrastructure.",
                category: "Food Loss",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Food Losses Reach 30%", source: "Food Security", date: Date(), url: "", summary: "Poor storage and transport cause massive food waste."),
                    Article(title: "Storage Infrastructure Lacking", source: "Agricultural Infrastructure", date: Date(), url: "", summary: "Inadequate storage facilities lead to spoilage of 25% of harvests.")
                ],
                charts: [
                    ChartData(title: "Post-Harvest Loss Rate", type: .bar, data: [("Grains", 25), ("Vegetables", 35), ("Fruits", 40), ("Dairy", 20)], color: .red)
                ],
                images: ["spoiled_grain", "broken_storage", "wasted_food"]
            ),
            KPIItem(
                title: "Food Price Volatility",
                description: "Unstable food prices due to supply chain disruptions, market speculation, and external economic factors affecting food affordability.",
                category: "Price Stability",
                impact: "High Impact",
                relatedArticles: [
                    Article(title: "Food Prices Spike 50%", source: "Market Report", date: Date(), url: "", summary: "Volatile markets cause dramatic food price increases."),
                    Article(title: "Supply Chain Disruptions", source: "Food Logistics", date: Date(), url: "", summary: "Transportation issues and market speculation drive price volatility.")
                ],
                charts: [
                    ChartData(title: "Food Price Index", type: .line, data: [("Jan", 100), ("Feb", 110), ("Mar", 125), ("Apr", 140), ("May", 150), ("Jun", 145)], color: .orange)
                ],
                images: ["expensive_food", "market_chaos", "price_chart"]
            ),
            KPIItem(
                title: "Agricultural Input Shortages",
                description: "Limited access to quality seeds, fertilizers, pesticides, and farming equipment affecting agricultural productivity and food production.",
                category: "Input Access",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Fertilizer Shortage Affects Yields", source: "Agricultural Inputs", date: Date(), url: "", summary: "Limited fertilizer access reduces crop productivity by 20%."),
                    Article(title: "Quality Seeds Unavailable", source: "Seed Industry", date: Date(), url: "", summary: "Farmers struggle to access high-quality, climate-resistant seeds.")
                ],
                charts: [
                    ChartData(title: "Input Availability Index", type: .bar, data: [("Seeds", 60), ("Fertilizer", 45), ("Pesticides", 55), ("Equipment", 40)], color: .yellow)
                ],
                images: ["empty_seed_bag", "fertilizer_shortage", "broken_equipment"]
            ),
            KPIItem(
                title: "Nutritional Quality Decline",
                description: "Decreasing nutritional value of available food due to soil degradation, limited dietary diversity, and reliance on processed foods.",
                category: "Nutrition Quality",
                impact: "Medium Impact",
                relatedArticles: [
                    Article(title: "Soil Degradation Reduces Nutrition", source: "Soil Health", date: Date(), url: "", summary: "Poor soil quality produces less nutritious crops."),
                    Article(title: "Dietary Diversity Declines", source: "Nutrition Report", date: Date(), url: "", summary: "Limited food variety leads to micronutrient deficiencies.")
                ],
                charts: [
                    ChartData(title: "Nutritional Quality Index", type: .line, data: [("2022", 70), ("2023", 65), ("2024", 60), ("2025", 55)], color: .red)
                ],
                images: ["malnourished_child", "poor_soil", "limited_food_variety"]
            )
        ]
    ]}
    
    // MARK: - Category Filter Section
    private var categoryFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filter by Category")
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(DashboardCategory.allCases, id: \.self) { category in
                        CategoryFilterButton(
                            title: category.displayName,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Charts Section
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Analytics & Insights")
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            // Health Sector Performance - Yahoo Finance Style
            VStack(alignment: .leading, spacing: 0) {
                // Header with timeframe tabs
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Health Sector Performance")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("72.5")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(.green)
                        
                        Text("+2.3%")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.green)
                    }
                    
                    // Timeframe tabs
                    HStack(spacing: 8) {
                        ForEach(["1M", "3M", "6M", "1Y", "ALL"], id: \.self) { period in
                            Text(period)
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(period == "1Y" ? .white : .secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(period == "1Y" ? Color.blue : Color.clear)
                                .cornerRadius(12)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Main chart
                LineChartView(
                    data: [
                        ("Jan", 75.0),
                        ("Feb", 78.0),
                        ("Mar", 82.0),
                        ("Apr", 79.0),
                        ("May", 85.0),
                        ("Jun", 88.0),
                        ("Jul", 91.0),
                        ("Aug", 89.0),
                        ("Sep", 87.0),
                        ("Oct", 84.0),
                        ("Nov", 86.0),
                        ("Dec", 90.0)
                    ],
                    color: .green
                )
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                
            }
            .background(Color.dynamicBackground(for: appViewModel.themeMode))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Economic Performance - Yahoo Finance Style
            VStack(alignment: .leading, spacing: 0) {
                // Header with timeframe tabs
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Economic Performance")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("78.3")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(.orange)
                        
                        Text("+1.8%")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.orange)
                    }
                    
                    // Timeframe tabs
                    HStack(spacing: 8) {
                        ForEach(["1M", "3M", "6M", "1Y", "ALL"], id: \.self) { period in
                            Text(period)
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(period == "6M" ? .white : .secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(period == "6M" ? Color.blue : Color.clear)
                                .cornerRadius(12)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Main chart
                BarChartView(
                    data: [
                        ("Q1", 65.0),
                        ("Q2", 72.0),
                        ("Q3", 78.0),
                        ("Q4", 85.0),
                        ("Q5", 82.0)
                    ],
                    color: .orange
                )
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                
            }
            .background(Color.dynamicBackground(for: appViewModel.themeMode))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Third row - Full width sector distribution
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("Sector Distribution")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("100%")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.blue)
                    
                    Text("Total")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Pie chart centered
                HStack {
                    Spacer()
                    
                    SectorPieChartView(
                        data: [
                            ("Health", 35.0, Color.blue),
                            ("Education", 28.0, Color.green),
                            ("Economy", 22.0, Color.orange),
                            ("Security", 15.0, Color.red)
                        ]
                    )
                    .frame(width: 200, height: 200)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.dynamicBackground(for: appViewModel.themeMode))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Citizen Feedback Section
    private var citizenFeedbackSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Citizen Feedback")
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showingFeedback = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            // Feedback Input
            HStack(spacing: 12) {
                TextField("Share your feedback...", text: $feedbackText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    )
                
                Button(action: {
                    // Submit feedback
                    feedbackText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(feedbackText.isEmpty ? Color.gray : Color.blue)
                        )
                        .shadow(
                            color: feedbackText.isEmpty ? Color.clear : Color.blue.opacity(0.3),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                }
                .disabled(feedbackText.isEmpty)
                .animation(.easeInOut(duration: 0.2), value: feedbackText.isEmpty)
            }
            
            // Sample Feedback
            VStack(spacing: 12) {
                CitizenFeedbackRow(
                    username: "Sarah M.",
                    feedback: "The new healthcare initiatives are making a real difference in our community. Keep up the great work!",
                    isPositive: true,
                    timestamp: "2 hours ago"
                )
                
                CitizenFeedbackRow(
                    username: "Michael R.",
                    feedback: "Would like to see more investment in public transportation infrastructure.",
                    isPositive: false,
                    timestamp: "5 hours ago"
                )
                
                CitizenFeedbackRow(
                    username: "Lisa K.",
                    feedback: "The education reforms are showing positive results. My kids are thriving!",
                    isPositive: true,
                    timestamp: "1 day ago"
                )
            }
        }
        .padding(20)
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

   

// MARK: - Performance Card
struct PerformanceCard: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let title: String
    let percentage: Int
    let change: Int
    let icon: String
    let color: Color
    var onTap: (() -> Void)? = nil
    var onShare: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if title == "Economy" {
                    ZStack {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                        
                        Text("₵")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption)
                            .foregroundColor(change >= 0 ? .green : .red)
                        
                        Text("\(abs(change))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(change >= 0 ? .green : .red)
                    }
                    
                    // Share button
                    Button(action: { onShare?() }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(4)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("\(percentage)%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
        .cornerRadius(16)
        // Primary shadow (main depth)
        .shadow(
            color: Color.black.opacity(0.12),
            radius: 16,
            x: 0,
            y: 6
        )
        // Secondary shadow (ambient depth)
        .shadow(
            color: Color.black.opacity(0.06),
            radius: 8,
            x: 0,
            y: 2
        )
        // Tertiary shadow (soft glow)
        .shadow(
            color: Color.black.opacity(0.03),
            radius: 4,
            x: 0,
            y: 1
        )
        // Inner shadow effect with gradient overlay
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.clear,
                            Color.black.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        // Subtle inner highlight
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                .blendMode(.overlay)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { onTap?() }
    }
}

// MARK: - Category Filter Button
struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
                // Enhanced shadows for filter buttons
                .shadow(
                    color: Color.black.opacity(isSelected ? 0.15 : 0.05),
                    radius: isSelected ? 8 : 4,
                    x: 0,
                    y: isSelected ? 3 : 1
                )
                .shadow(
                    color: Color.black.opacity(isSelected ? 0.08 : 0.02),
                    radius: isSelected ? 4 : 2,
                    x: 0,
                    y: isSelected ? 1 : 0
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isSelected ? 0.2 : 0.1),
                                    Color.clear,
                                    Color.black.opacity(isSelected ? 0.1 : 0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Health Trends Chart
struct HealthTrendsChart: View {
    let data: [(String, Double)] = [
        ("Jan", 65), ("Feb", 68), ("Mar", 70), ("Apr", 69),
        ("May", 71), ("Jun", 73), ("Jul", 72), ("Aug", 72)
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            // Chart area
            ZStack {
                // Background grid
                VStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { _ in
                        Divider()
                            .opacity(0.3)
                        Spacer()
                    }
                }
                
                // Data points and line
                Path { path in
                    let width = UIScreen.main.bounds.width * 0.35
                    let height: CGFloat = 160
                    let pointWidth = width / CGFloat(data.count - 1)
                    let maxValue = data.map { $0.1 }.max() ?? 80
                    let minValue = data.map { $0.1 }.min() ?? 60
                    let valueRange = maxValue - minValue
                    
                    for (index, item) in data.enumerated() {
                        let x = CGFloat(index) * pointWidth
                        let normalizedValue = (item.1 - minValue) / valueRange
                        let y = height - (normalizedValue * height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.green, lineWidth: 3)
                
                // Data points
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    let width = UIScreen.main.bounds.width * 0.35
                    let height: CGFloat = 160
                    let pointWidth = width / CGFloat(data.count - 1)
                    let maxValue = data.map { $0.1 }.max() ?? 80
                    let minValue = data.map { $0.1 }.min() ?? 60
                    let valueRange = maxValue - minValue
                    
                    let x = CGFloat(index) * pointWidth
                    let normalizedValue = (item.1 - minValue) / valueRange
                    let y = height - (normalizedValue * height)
                    
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
            .frame(height: 160)
            
            // X-axis labels
            HStack {
                ForEach(data, id: \.0) { item in
                    Text(item.0)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Citizen Feedback Row
struct CitizenFeedbackRow: View {
    let username: String
    let feedback: String
    let isPositive: Bool
    let timestamp: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(username.prefix(1)))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(username)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: isPositive ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                        .font(.caption)
                        .foregroundColor(isPositive ? .green : .red)
                }
                
                Text(feedback)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(timestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Dashboard Category
enum DashboardCategory: String, CaseIterable {
    case all = "all"
    case economy = "economy"
    case health = "health"
    case education = "education"
    case security = "security"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .economy: return "Economy"
        case .health: return "Health"
        case .education: return "Education"
        case .security: return "Security"
        }
    }
}

// MARK: - Performance Card Data Model
struct PerformanceCardData {
    let title: String
    let percentage: Int
    let change: Int
    let icon: String
    let color: Color
    let category: DashboardCategory
}

// MARK: - Detail Sheet Models & View
struct DashboardDetail: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let isImproved: Bool
    let items: [KPIItem]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DashboardDetail, rhs: DashboardDetail) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - KPI Item Model
struct KPIItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let impact: String
    let relatedArticles: [Article]
    let charts: [ChartData]
    let images: [String]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: KPIItem, rhs: KPIItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Article Model
struct Article: Identifiable {
    let id = UUID()
    let title: String
    let source: String
    let date: Date
    let url: String
    let summary: String
}

// MARK: - Chart Data Model
struct ChartData: Identifiable {
    let id = UUID()
    let title: String
    let type: ChartType
    let data: [(String, Double)]
    let color: Color
}

enum ChartType {
    case line, bar, pie
}

struct DashboardDetailView: View {
    let detail: DashboardDetail
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedKPIItem: KPIItem?
    
    var body: some View {
        List {
            Section(header: Text(detail.isImproved ? "Government Actions" : "Reasons for Decline")) {
                ForEach(detail.items, id: \.self) { item in
                    KPIItemRow(item: item) {
                        selectedKPIItem = item
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
        .navigationTitle(detail.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedKPIItem) { kpiItem in
            KPIItemDetailView(item: kpiItem)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
    }
}

// MARK: - KPI Item Row
struct KPIItemRow: View {
    let item: KPIItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(item.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(item.category)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                            )
                        
                        Spacer()
                        
                        Text(item.impact)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.1))
                            )
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(item.relatedArticles.count)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - KPI Item Detail View
struct KPIItemDetailView: View {
    let item: KPIItem
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text(item.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(item.description)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                    
                    HStack {
                        Text(item.category)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                            )
                        
                        Text(item.impact)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                            )
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Tab Selector
                Picker("Content", selection: $selectedTab) {
                    Text("Charts").tag(0)
                    Text("Articles").tag(1)
                    Text("Images").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case 0:
                        chartsSection
                    case 1:
                        articlesSection
                    case 2:
                        imagesSection
                    default:
                        chartsSection
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analytics & Trends")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            ForEach(item.charts) { chart in
                VStack(alignment: .leading, spacing: 12) {
                    Text(chart.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    ChartView(chart: chart)
                        .frame(height: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
                        )
                }
            }
        }
    }
    
    private var articlesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Related Articles")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            ForEach(item.relatedArticles) { article in
                ArticleCard(article: article)
            }
        }
    }
    
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Visual Documentation")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(item.images, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Chart View
struct ChartView: View {
    let chart: ChartData
    
    var body: some View {
        VStack(spacing: 8) {
            switch chart.type {
            case .line:
                LineChartView(data: chart.data, color: chart.color)
            case .bar:
                BarChartView(data: chart.data, color: chart.color)
            case .pie:
                PieChartView(data: chart.data, color: chart.color)
            }
        }
        .padding(16)
    }
}

// MARK: - Professional Line Chart View (Stock App Style)
struct LineChartView: View {
    let data: [(String, Double)]
    let color: Color
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let chartHeight = height - 60 // Space for labels
            let chartWidth = width - 80 // Space for Y-axis labels
            
            ZStack {
                // Background grid
                GridView(width: chartWidth, height: chartHeight, data: data)
                
                // Chart area
                VStack(spacing: 0) {
                    // Y-axis labels
                    HStack {
                        YAxisLabels(data: data, height: chartHeight)
                            .frame(width: 60)
                        
                        // Main chart area
                        ZStack {
                            // Chart line
                            ChartLine(data: data, color: color, width: chartWidth, height: chartHeight)
                            
                            // Data points
                            DataPoints(data: data, color: color, width: chartWidth, height: chartHeight, selectedIndex: $selectedIndex)
                            
                            // Interactive overlay
                            InteractiveOverlay(data: data, width: chartWidth, height: chartHeight, selectedIndex: $selectedIndex)
                        }
                        .frame(width: chartWidth, height: chartHeight)
                    }
                    
                    // X-axis labels
                    XAxisLabels(data: data, width: chartWidth)
                        .frame(height: 40)
                }
                
                // Tooltip
                if let selectedIndex = selectedIndex {
                    TooltipView(data: data, selectedIndex: selectedIndex, width: chartWidth, height: chartHeight)
                }
            }
        }
    }
}

// MARK: - Grid View
struct GridView: View {
    let width: CGFloat
    let height: CGFloat
    let data: [(String, Double)]
    
    var body: some View {
        ZStack {
            // Horizontal grid lines
            VStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { i in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 0.5)
                    if i < 4 {
                        Spacer()
                    }
                }
            }
            .frame(width: width, height: height)
            
            // Vertical grid lines
            HStack(spacing: 0) {
                ForEach(0..<data.count, id: \.self) { i in
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 0.5)
                    if i < data.count - 1 {
                        Spacer()
                    }
                }
            }
            .frame(width: width, height: height)
        }
        .offset(x: 60) // Offset for Y-axis labels
    }
}

// MARK: - Chart Line
struct ChartLine: View {
    let data: [(String, Double)]
    let color: Color
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Path { path in
            let pointWidth = width / CGFloat(data.count - 1)
            let maxValue = data.map { $0.1 }.max() ?? 100
            let minValue = data.map { $0.1 }.min() ?? 0
            let valueRange = maxValue - minValue
            
            // Add some padding to prevent clipping
            let padding: CGFloat = 10
            let adjustedHeight = height - (padding * 2)
            let adjustedMinValue = minValue - (valueRange * 0.1)
            let adjustedMaxValue = maxValue + (valueRange * 0.1)
            let adjustedValueRange = adjustedMaxValue - adjustedMinValue
            
            for (index, item) in data.enumerated() {
                let x = CGFloat(index) * pointWidth
                let normalizedValue = (item.1 - adjustedMinValue) / adjustedValueRange
                let y = padding + (adjustedHeight - (normalizedValue * adjustedHeight))
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(
            LinearGradient(
                colors: [color.opacity(0.6), color, color.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }
}

// MARK: - Data Points
struct DataPoints: View {
    let data: [(String, Double)]
    let color: Color
    let width: CGFloat
    let height: CGFloat
    @Binding var selectedIndex: Int?
    
    var body: some View {
        let pointWidth = width / CGFloat(data.count - 1)
        let maxValue = data.map { $0.1 }.max() ?? 100
        let minValue = data.map { $0.1 }.min() ?? 0
        let valueRange = maxValue - minValue
        
        // Add some padding to prevent clipping (matching ChartLine)
        let padding: CGFloat = 10
        let adjustedHeight = height - (padding * 2)
        let adjustedMinValue = minValue - (valueRange * 0.1)
        let adjustedMaxValue = maxValue + (valueRange * 0.1)
        let adjustedValueRange = adjustedMaxValue - adjustedMinValue
        
        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
            let x = CGFloat(index) * pointWidth
            let normalizedValue = (item.1 - adjustedMinValue) / adjustedValueRange
            let y = padding + (adjustedHeight - (normalizedValue * adjustedHeight))
            let isSelected = selectedIndex == index
            
            Circle()
                .fill(isSelected ? color : Color.white)
                .frame(width: isSelected ? 14 : 10, height: isSelected ? 14 : 10)
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: isSelected ? 3 : 2)
                )
                .position(x: x, y: y)
                .scaleEffect(isSelected ? 1.3 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .shadow(color: color.opacity(0.3), radius: isSelected ? 4 : 2, x: 0, y: 2)
        }
    }
}

// MARK: - Interactive Overlay
struct InteractiveOverlay: View {
    let data: [(String, Double)]
    let width: CGFloat
    let height: CGFloat
    @Binding var selectedIndex: Int?
    
    var body: some View {
        let pointWidth = width / CGFloat(data.count - 1)
        
        HStack(spacing: 0) {
            ForEach(0..<data.count, id: \.self) { index in
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: pointWidth, height: height)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedIndex = selectedIndex == index ? nil : index
                        }
                    }
            }
        }
    }
}

// MARK: - Y-Axis Labels
struct YAxisLabels: View {
    let data: [(String, Double)]
    let height: CGFloat
    
    var body: some View {
        let maxValue = data.map { $0.1 }.max() ?? 100
        let minValue = data.map { $0.1 }.min() ?? 0
        let valueRange = maxValue - minValue
        
        VStack {
            ForEach(0..<5, id: \.self) { i in
                let value = maxValue - (Double(i) / 4.0 * valueRange)
                Text(String(format: "%.1f", value))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .frame(height: height)
    }
}

// MARK: - X-Axis Labels
struct XAxisLabels: View {
    let data: [(String, Double)]
    let width: CGFloat
    
    var body: some View {
        let pointWidth = width / CGFloat(data.count - 1)
        
        HStack(spacing: 0) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                Text(item.0)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: pointWidth)
            }
        }
        .offset(x: 60) // Offset for Y-axis labels
    }
}

// MARK: - Tooltip View
struct TooltipView: View {
    let data: [(String, Double)]
    let selectedIndex: Int
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        let pointWidth = width / CGFloat(data.count - 1)
        let maxValue = data.map { $0.1 }.max() ?? 100
        let minValue = data.map { $0.1 }.min() ?? 0
        let valueRange = maxValue - minValue
        
        // Add some padding to prevent clipping (matching ChartLine and DataPoints)
        let padding: CGFloat = 10
        let adjustedHeight = height - (padding * 2)
        let adjustedMinValue = minValue - (valueRange * 0.1)
        let adjustedMaxValue = maxValue + (valueRange * 0.1)
        let adjustedValueRange = adjustedMaxValue - adjustedMinValue
        
        let x = CGFloat(selectedIndex) * pointWidth
        let normalizedValue = (data[selectedIndex].1 - adjustedMinValue) / adjustedValueRange
        let y = padding + (adjustedHeight - (normalizedValue * adjustedHeight))
        
        VStack(spacing: 4) {
            Text(data[selectedIndex].0)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(String(format: "%.1f", data[selectedIndex].1))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .position(x: x + 60, y: y - 35) // Offset for Y-axis labels and position above point
    }
}

// MARK: - Professional Bar Chart View (Stock App Style)
struct BarChartView: View {
    let data: [(String, Double)]
    let color: Color
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let chartHeight = height - 60 // Space for labels
            let chartWidth = width - 80 // Space for Y-axis labels
            
            ZStack {
                // Background grid
                BarGridView(width: chartWidth, height: chartHeight, data: data)
                
                // Chart area
                VStack(spacing: 0) {
                    // Y-axis labels
                    HStack {
                        YAxisLabels(data: data, height: chartHeight)
                            .frame(width: 60)
                        
                        // Main chart area
                        ZStack {
                            // Bars
                            BarBars(data: data, color: color, width: chartWidth, height: chartHeight, selectedIndex: $selectedIndex)
                            
                            // Interactive overlay
                            BarInteractiveOverlay(data: data, width: chartWidth, height: chartHeight, selectedIndex: $selectedIndex)
                        }
                        .frame(width: chartWidth, height: chartHeight)
                    }
                    
                    // X-axis labels
                    BarXAxisLabels(data: data, width: chartWidth)
                        .frame(height: 40)
                }
                
                // Tooltip
                if let selectedIndex = selectedIndex {
                    BarTooltipView(data: data, selectedIndex: selectedIndex, width: chartWidth, height: chartHeight)
                }
            }
        }
    }
}

// MARK: - Bar Grid View
struct BarGridView: View {
    let width: CGFloat
    let height: CGFloat
    let data: [(String, Double)]
    
    var body: some View {
        ZStack {
            // Horizontal grid lines
            VStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { i in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 0.5)
                    if i < 4 {
                        Spacer()
                    }
                }
            }
            .frame(width: width, height: height)
        }
        .offset(x: 60) // Offset for Y-axis labels
    }
}

// MARK: - Bar Bars
struct BarBars: View {
    let data: [(String, Double)]
    let color: Color
    let width: CGFloat
    let height: CGFloat
    @Binding var selectedIndex: Int?
    
    var body: some View {
        let maxValue = data.map { $0.1 }.max() ?? 100
        let barWidth = (width - CGFloat(data.count - 1) * 12) / CGFloat(data.count)
        
        // Add some padding to prevent clipping
        let padding: CGFloat = 10
        let adjustedHeight = height - (padding * 2)
        let adjustedMaxValue = maxValue + (maxValue * 0.1)
        
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                let barHeight = (item.1 / adjustedMaxValue) * adjustedHeight
                let isSelected = selectedIndex == index
                
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: isSelected ? [color, color.opacity(0.8)] : [color.opacity(0.9), color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: barWidth, height: max(barHeight, 4)) // Minimum height for visibility
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    LinearGradient(
                                        colors: [color.opacity(0.3), color.opacity(0.1)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                        .shadow(color: color.opacity(0.2), radius: isSelected ? 6 : 3, x: 0, y: 2)
                }
            }
        }
        .padding(.bottom, padding)
    }
}

// MARK: - Bar Interactive Overlay
struct BarInteractiveOverlay: View {
    let data: [(String, Double)]
    let width: CGFloat
    let height: CGFloat
    @Binding var selectedIndex: Int?
    
    var body: some View {
        let barWidth = (width - CGFloat(data.count - 1) * 12) / CGFloat(data.count)
        
        HStack(spacing: 12) {
            ForEach(0..<data.count, id: \.self) { index in
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: barWidth, height: height)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedIndex = selectedIndex == index ? nil : index
                        }
                    }
            }
        }
    }
}

// MARK: - Bar X-Axis Labels
struct BarXAxisLabels: View {
    let data: [(String, Double)]
    let width: CGFloat
    
    var body: some View {
        let barWidth = (width - CGFloat(data.count - 1) * 12) / CGFloat(data.count)
        
        HStack(spacing: 12) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                Text(item.0)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: barWidth)
            }
        }
        .offset(x: 60) // Offset for Y-axis labels
    }
}

// MARK: - Bar Tooltip View
struct BarTooltipView: View {
    let data: [(String, Double)]
    let selectedIndex: Int
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        let barWidth = (width - CGFloat(data.count - 1) * 12) / CGFloat(data.count)
        let maxValue = data.map { $0.1 }.max() ?? 100
        let adjustedMaxValue = maxValue + (maxValue * 0.1)
        let padding: CGFloat = 10
        let adjustedHeight = height - (padding * 2)
        let barHeight = (data[selectedIndex].1 / adjustedMaxValue) * adjustedHeight
        
        let x = CGFloat(selectedIndex) * (barWidth + 12) + barWidth / 2
        let y = height - barHeight - padding - 35
        
        VStack(spacing: 4) {
            Text(data[selectedIndex].0)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(String(format: "%.1f", data[selectedIndex].1))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .position(x: x + 60, y: y) // Offset for Y-axis labels
    }
}

// MARK: - Professional Pie Chart View (Stock App Style)
struct PieChartView: View {
    let data: [(String, Double)]
    let color: Color
    @State private var selectedSegment: Int? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) - 40
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // Pie chart
                PieChartSegments(data: data, color: color, size: size, center: center, selectedSegment: $selectedSegment)
                
                // Center text
                VStack {
                    Text("Total")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.0f", data.map { $0.1 }.reduce(0, +)))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                // Legend
                PieChartLegend(data: data, color: color, selectedSegment: $selectedSegment)
                    .offset(x: size / 2 + 20, y: 0)
            }
        }
    }
}

// MARK: - Sector Pie Chart View
struct SectorPieChartView: View {
    let data: [(String, Double, Color)]
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) - 20
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let total = data.map { $0.1 }.reduce(0, +)
            
            ZStack {
                // Pie chart segments
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    let percentage = item.1 / total
                    let startAngle = calculateStartAngle(for: index, data: data, total: total)
                    let endAngle = startAngle + (percentage * 360)
                    let midAngle = startAngle + (percentage * 360 / 2)
                    
                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: size / 2,
                            startAngle: .degrees(startAngle),
                            endAngle: .degrees(endAngle),
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .fill(item.2)
                    .stroke(Color.white, lineWidth: 2)
                    
                    // Percentage text in each segment
                    if percentage > 0.05 { // Only show text for segments larger than 5%
                        let textRadius = size * 0.35
                        let textX = center.x + textRadius * cos(midAngle * .pi / 180)
                        let textY = center.y + textRadius * sin(midAngle * .pi / 180)
                        
                        Text("\(Int(item.1))%")
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .position(x: textX, y: textY)
                    }
                }
            }
        }
    }
    
    private func calculateStartAngle(for index: Int, data: [(String, Double, Color)], total: Double) -> Double {
        let previousData = data.prefix(index)
        let previousTotal = previousData.map { $0.1 }.reduce(0, +)
        return (previousTotal / total) * 360
    }
}

// MARK: - Pie Chart Segments
struct PieChartSegments: View {
    let data: [(String, Double)]
    let color: Color
    let size: CGFloat
    let center: CGPoint
    @Binding var selectedSegment: Int?
    
    var body: some View {
        let total = data.map { $0.1 }.reduce(0, +)
        
        ZStack {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                let percentage = item.1 / total
                let startAngle = calculateStartAngle(for: index, data: data, total: total)
                let endAngle = startAngle + (percentage * 360)
                let isSelected = selectedSegment == index
                
                Path { path in
                    path.move(to: center)
                    path.addArc(
                        center: center,
                        radius: size / 2,
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(endAngle),
                        clockwise: false
                    )
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: isSelected ? [color, color.opacity(0.8)] : [color.opacity(0.9), color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: size / 2,
                            startAngle: .degrees(startAngle),
                            endAngle: .degrees(endAngle),
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .stroke(Color.white, lineWidth: 2)
                )
                .scaleEffect(isSelected ? 1.08 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .shadow(color: color.opacity(0.3), radius: isSelected ? 8 : 4, x: 0, y: 2)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSegment = selectedSegment == index ? nil : index
                    }
                }
            }
        }
    }
    
    private func calculateStartAngle(for index: Int, data: [(String, Double)], total: Double) -> Double {
        var startAngle: Double = -90
        for i in 0..<index {
            let percentage = data[i].1 / total
            startAngle += percentage * 360
        }
        return startAngle
    }
}

// MARK: - Pie Chart Legend
struct PieChartLegend: View {
    let data: [(String, Double)]
    let color: Color
    @Binding var selectedSegment: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                let isSelected = selectedSegment == index
                let percentage = (item.1 / data.map { $0.1 }.reduce(0, +)) * 100
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(isSelected ? color : color.opacity(0.7))
                        .frame(width: 12, height: 12)
                        .scaleEffect(isSelected ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.0)
                            .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                            .foregroundColor(.primary)
                        
                        Text(String(format: "%.1f%%", percentage))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Article Card
struct ArticleCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Text(article.summary)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text(article.source)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(article.date, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dynamicSecondaryBackground(for: AppViewModel().themeMode))
        )
    }
}
