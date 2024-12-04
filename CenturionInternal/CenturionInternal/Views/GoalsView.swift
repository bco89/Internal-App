import SwiftUI
import Foundation

struct SalesGoal: Identifiable, Codable {
    let id: UUID
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date
    var notes: String
    
    var progress: Double {
        currentAmount / targetAmount
    }
}

struct DateRange {
    let startDate: Date
    let endDate: Date
    let title: String
}

enum TimeFrame: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
    
    var id: String { self.rawValue }
}

@MainActor
final class GoalsViewModel: ObservableObject {
    @Published var goals: [SalesGoal] = []
    @Published var showingAddGoal = false
    @Published var agentReports: [AgentReport] = []
    
    private let ghlService = GHLService()
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "salesGoals"),
           let decoded = try? JSONDecoder().decode([SalesGoal].self, from: data) {
            goals = decoded
        }
    }
    
    func loadAgentReports(startDate: Date, endDate: Date) async {
        do {
            agentReports = try await ghlService.fetchAgentReports(startDate: startDate, endDate: endDate)
        } catch {
            print("Error loading agent reports:", error)
        }
    }
    
    func addGoal(_ goal: SalesGoal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: SalesGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoal(_ goal: SalesGoal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: "salesGoals")
        }
    }
}

struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    @State private var selectedTimeFrame = TimeFrame.month
    @State private var showingDatePicker = false
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    @Binding var isAuthenticated: Bool
    
    var dateRanges: [DateRange] {
        let calendar = Calendar.current
        let now = Date()
        
        let thisMonth = DateRange(
            startDate: calendar.date(from: calendar.dateComponents([.year, .month], from: now))!,
            endDate: calendar.date(byAdding: DateComponents(month: 1, day: -1), 
                                 to: calendar.date(from: calendar.dateComponents([.year, .month], from: now))!)!,
            title: "This Month"
        )
        
        let lastMonth = DateRange(
            startDate: calendar.date(byAdding: .month, value: -1, 
                                   to: calendar.date(from: calendar.dateComponents([.year, .month], from: now))!)!,
            endDate: calendar.date(byAdding: .day, value: -1, 
                                 to: calendar.date(from: calendar.dateComponents([.year, .month], from: now))!)!,
            title: "Last Month"
        )
        
        let last3Months = DateRange(
            startDate: calendar.date(byAdding: .month, value: -3, 
                                   to: calendar.date(from: calendar.dateComponents([.year, .month], from: now))!)!,
            endDate: calendar.date(byAdding: .day, value: -1, 
                                 to: calendar.date(from: calendar.dateComponents([.year, .month], from: now))!)!,
            title: "Last 3 Months"
        )
        
        let ytd = DateRange(
            startDate: calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: 1, day: 1))!,
            endDate: now,
            title: "Year to Date"
        )
        
        return [thisMonth, lastMonth, last3Months, ytd]
    }
    
    @State private var selectedRange = 0
    
    var body: some View {
        NavigationView {
            List {
                Section("Performance Metrics") {
                    // Date Range Picker
                    Picker("Date Range", selection: $selectedRange) {
                        ForEach(0..<dateRanges.count, id: \.self) { index in
                            Text(dateRanges[index].title).tag(index)
                        }
                        Text("Custom").tag(dateRanges.count)
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedRange) { newValue in
                        if newValue == dateRanges.count {
                            showingDatePicker = true
                        } else {
                            Task {
                                await viewModel.loadAgentReports(
                                    startDate: dateRanges[newValue].startDate,
                                    endDate: dateRanges[newValue].endDate
                                )
                            }
                        }
                    }
                    
                    ForEach(viewModel.agentReports) { report in
                        AgentReportCard(report: report)
                    }
                }
                
                Section("Goals") {
                    ForEach(viewModel.goals) { goal in
                        GoalCard(goal: goal, viewModel: viewModel)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteGoal(viewModel.goals[index])
                        }
                    }
                }
            }
            .navigationTitle("Goals & Performance")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Logout") {
                        isAuthenticated = false
                    }
                    .foregroundColor(Theme.accent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showingAddGoal = true }) {
                        Text("+")
                            .font(.system(size: 24, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddGoal) {
                AddGoalView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingDatePicker) {
                NavigationView {
                    Form {
                        DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
                    }
                    .navigationTitle("Custom Date Range")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingDatePicker = false
                                selectedRange = 0
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Apply") {
                                Task {
                                    await viewModel.loadAgentReports(
                                        startDate: customStartDate,
                                        endDate: customEndDate
                                    )
                                }
                                showingDatePicker = false
                            }
                        }
                    }
                }
            }
            .task {
                await viewModel.loadAgentReports(
                    startDate: dateRanges[selectedRange].startDate,
                    endDate: dateRanges[selectedRange].endDate
                )
            }
        }
    }
}

struct GoalCard: View {
    let goal: SalesGoal
    @ObservedObject var viewModel: GoalsViewModel
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.title)
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingEditSheet = true }) {
                    Text("✎")
                        .font(.system(size: 18))
                        .foregroundColor(Theme.accent)
                }
            }
            
            ProgressView(value: goal.progress)
                .tint(Theme.accent)
            
            HStack {
                Text("$\(Int(goal.currentAmount))")
                Text("of")
                Text("$\(Int(goal.targetAmount))")
                    .fontWeight(.bold)
            }
            .font(.subheadline)
            .foregroundColor(Theme.textSecondary)
            
            if !goal.notes.isEmpty {
                Text(goal.notes)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Text("Due \(goal.deadline.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .padding()
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showingEditSheet) {
            EditGoalView(goal: goal, viewModel: viewModel)
        }
    }
}

struct AddGoalView: View {
    @ObservedObject var viewModel: GoalsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var targetAmount = 0.0
    @State private var currentAmount = 0.0
    @State private var deadline = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Title", text: $title)
                    TextField("Target Amount", value: $targetAmount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    TextField("Current Amount", value: $currentAmount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let goal = SalesGoal(
                            id: UUID(),
                            title: title,
                            targetAmount: targetAmount,
                            currentAmount: currentAmount,
                            deadline: deadline,
                            notes: notes
                        )
                        viewModel.addGoal(goal)
                        dismiss()
                    }
                    .disabled(title.isEmpty || targetAmount <= 0)
                }
            }
        }
    }
}

struct EditGoalView: View {
    let goal: SalesGoal
    @ObservedObject var viewModel: GoalsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var targetAmount: Double
    @State private var currentAmount: Double
    @State private var deadline: Date
    @State private var notes: String
    
    init(goal: SalesGoal, viewModel: GoalsViewModel) {
        self.goal = goal
        self.viewModel = viewModel
        _title = State(initialValue: goal.title)
        _targetAmount = State(initialValue: goal.targetAmount)
        _currentAmount = State(initialValue: goal.currentAmount)
        _deadline = State(initialValue: goal.deadline)
        _notes = State(initialValue: goal.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Title", text: $title)
                    TextField("Target Amount", value: $targetAmount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    TextField("Current Amount", value: $currentAmount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updatedGoal = SalesGoal(
                            id: goal.id,
                            title: title,
                            targetAmount: targetAmount,
                            currentAmount: currentAmount,
                            deadline: deadline,
                            notes: notes
                        )
                        viewModel.updateGoal(updatedGoal)
                        dismiss()
                    }
                    .disabled(title.isEmpty || targetAmount <= 0)
                }
            }
        }
    }
}

struct AgentReportCard: View {
    let report: AgentReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(report.agentName)
                .font(.headline)
            
            HStack {
                MetricView(title: "Total Leads", value: report.totalLeads)
                Spacer()
                MetricView(title: "SMS Sent", value: report.smsSent)
                Spacer()
                MetricView(title: "Emails Sent", value: report.emailsSent)
            }
            
            HStack {
                MetricView(title: "Calls Made", value: report.callsMade)
                Spacer()
                MetricView(title: "Conversions", value: report.conversions)
                Spacer()
                MetricView(title: "Conv. Rate", value: "\(Int(report.conversionRate * 100))%")
            }
        }
        .padding()
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MetricView: View {
    let title: String
    let value: String
    
    init(title: String, value: Any) {
        self.title = title
        self.value = String(describing: value)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(.headline)
                .foregroundColor(Theme.text)
        }
    }
} 