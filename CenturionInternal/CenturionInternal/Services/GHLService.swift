import SwiftUI
import Foundation

struct GHLUser: Codable {
    let id: String
    let name: String
    let email: String?
    let role: String?
}

struct GHLResponse<T: Codable>: Codable {
    let users: [T]?
    let sites: [T]?
    let members: [T]?  // Try different response fields
}

struct AgentReport: Codable, Identifiable {
    let id: String
    let agentName: String
    let totalLeads: Int
    let smsSent: Int
    let emailsSent: Int
    let callsMade: Int
    let conversions: Int
    let conversionRate: Double
}

struct AgentMetrics: Codable {
    let dailyMetrics: [DailyMetric]
    let totalMetrics: TotalMetrics
}

struct DailyMetric: Codable {
    let date: String
    let leads: Int
    let appointments: Int
    let sales: Int
    let revenue: Double
}

struct TotalMetrics: Codable {
    let totalLeads: Int
    let smsSent: Int
    let emailsSent: Int
    let callsMade: Int
    let conversions: Int
    let conversionRate: Double
}

@MainActor
class GHLService: ObservableObject {
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJsb2NhdGlvbl9pZCI6IkJXMnRRMDhCcXNrS29NaTVxVXJnIiwidmVyc2lvbiI6MSwiaWF0IjoxNzMzMjY0ODE0MzA0LCJzdWIiOiJ5OWNzZEtRZFkzUDdPTjFYUDNrQSJ9.6NqtO_0EEREpKTMWulBewmTKrugPiwgsyLW83egKcKM"
    private let baseURL = "https://rest.gohighlevel.com/v1/"
    private let locationId = "BW2tQ08BqskKoMi5qUrg"
    
    func fetchAgentReports(startDate: Date, endDate: Date) async throws -> [AgentReport] {
        // First, get the users
        let users = try await fetchAgents()
        print("Found users:", users.map { $0.name })
        
        // Filter for just the sales agents we want
        let salesAgents = users.filter { user in
            ["Collin Jensen", "Tyler Killian", "Tanner Bilton"].contains(user.name)
        }
        
        print("Fetching data from \(startDate) to \(endDate)")
        
        // Try to get metrics for each agent
        var reports: [AgentReport] = []
        for agent in salesAgents {
            if let metrics = try? await fetchAgentMetrics(
                agentId: agent.id,
                startDate: startDate,
                endDate: endDate
            ) {
                let report = AgentReport(
                    id: agent.id,
                    agentName: agent.name,
                    totalLeads: metrics.totalMetrics.totalLeads,
                    smsSent: metrics.totalMetrics.smsSent,
                    emailsSent: metrics.totalMetrics.emailsSent,
                    callsMade: metrics.totalMetrics.callsMade,
                    conversions: metrics.totalMetrics.conversions,
                    conversionRate: metrics.totalMetrics.conversionRate
                )
                reports.append(report)
            } else {
                // Add agent with zero metrics if we can't get data
                reports.append(AgentReport(
                    id: agent.id,
                    agentName: agent.name,
                    totalLeads: 0,
                    smsSent: 0,
                    emailsSent: 0,
                    callsMade: 0,
                    conversions: 0,
                    conversionRate: 0.0
                ))
            }
        }
        
        return reports
    }
    
    func fetchAgents() async throws -> [GHLUser] {
        // Try different endpoints
        let endpoints = [
            "users",
            "locations/\(locationId)/users",
            "locations/\(locationId)/team-members",
            "locations/\(locationId)/members"
        ]
        
        var lastError: Error? = nil
        
        // Try each endpoint
        for endpoint in endpoints {
            do {
                let url = URL(string: baseURL + endpoint)!
                var request = URLRequest(url: url)
                request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                
                let (data, _) = try await URLSession.shared.data(for: request)
                
                // Debug print
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("\nTrying endpoint: \(endpoint)")
                    print("Response:", jsonString)
                }
                
                // Try to decode as different response types
                if let response = try? JSONDecoder().decode(GHLResponse<GHLUser>.self, from: data) {
                    if let users = response.users { return users }
                    if let members = response.members { return members }
                    if let sites = response.sites { return sites }
                }
                
                // Try direct array decode
                if let users = try? JSONDecoder().decode([GHLUser].self, from: data) {
                    return users
                }
                
            } catch {
                lastError = error
                continue
            }
        }
        
        throw lastError ?? URLError(.badServerResponse)
    }
    
    func fetchAgentMetrics(agentId: String, startDate: Date, endDate: Date) async throws -> AgentMetrics {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Get opportunities metrics
        let opportunitiesEndpoint = "locations/\(locationId)/opportunities"
            + "?assignedTo=\(agentId)"
            + "&startDate=\(dateFormatter.string(from: startDate))"
            + "&endDate=\(dateFormatter.string(from: endDate))"
        
        guard let url = URL(string: baseURL + opportunitiesEndpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Debug print
        if let jsonString = String(data: data, encoding: .utf8) {
            print("GHL Opportunities Response for \(agentId):", jsonString)
        }
        
        struct OpportunitiesResponse: Codable {
            let opportunities: [Opportunity]
            let total: Int
        }
        
        struct Opportunity: Codable {
            let id: String
            let status: String
            let value: Double?
            let createdAt: String
            let lastContacted: String?
            let source: String?
        }
        
        if let response = try? JSONDecoder().decode(OpportunitiesResponse.self, from: data) {
            let opportunities = response.opportunities
            
            // Calculate metrics
            let totalLeads = response.total
            let wonOpportunities = opportunities.filter { $0.status.lowercased() == "won" }
            let totalSales = wonOpportunities.count
            
            let totalRevenue = wonOpportunities.reduce(0.0) { sum, opp in
                sum + (opp.value ?? 0)
            }
            
            // Calculate communication metrics
            let smsSent = opportunities.filter { $0.lastContacted?.contains("sms") ?? false }.count
            let emailsSent = opportunities.filter { $0.lastContacted?.contains("email") ?? false }.count
            let callsMade = opportunities.filter { $0.lastContacted?.contains("call") ?? false }.count
            
            let conversionRate = totalLeads > 0 ? Double(totalSales) / Double(totalLeads) : 0.0
            
            return AgentMetrics(
                dailyMetrics: [],
                totalMetrics: TotalMetrics(
                    totalLeads: totalLeads,
                    smsSent: smsSent,
                    emailsSent: emailsSent,
                    callsMade: callsMade,
                    conversions: totalSales,
                    conversionRate: conversionRate
                )
            )
        }
        
        throw URLError(.badServerResponse)
    }
} 