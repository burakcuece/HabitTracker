//
//  ContentView.swift
//  HabitTracker
//
//  Created by Burak Cüce on 15.08.22.
//

import SwiftUI

struct Habit: Identifiable, Codable {
    var id = UUID()
    let name: String
    let description: String
    var trackingAmount: Int = 0
    
    
    public mutating func incrementAmount() {
        self.trackingAmount += 1
    }
}

class HabitStore: ObservableObject {
    @Published var habits = [Habit]() {
        didSet {
            let encoder = JSONEncoder()
            
            if let encoded = try? encoder.encode(habits) {
                UserDefaults.standard.set(encoded, forKey: "Habits")
            }
        }
    }
    
    init() {
        if let habits = UserDefaults.standard.data(forKey: "Habits") {
            let decoder = JSONDecoder()
            
            if let decoded = try? decoder.decode([Habit].self, from: habits) {
                self.habits = decoded
                return
            }
        }
        
        self.habits = []
    }
}

struct ActivityView: View {
    var activity: Habit
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(activity.name)
                    .font(.headline)
                Text(activity.description)
                    .font(.caption)
            }
            
            Spacer()
            
            Text("\(activity.trackingAmount)")
                .font(.largeTitle)
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(activity: Habit(name: "Workout", description: "Getting fitter every day"))
    }
}

struct ActivityDetail: View {
    @Binding var habit: Habit
    
    var body: some View {
        VStack(alignment: .center) {
            Text(habit.name)
                .font(.largeTitle)
            Text(habit.description)
                .font(.caption)
            
            Divider()
                .frame(width: 44)
                .padding(.vertical)
            
            VStack(alignment: .center) {
                Text("Congratulations")
                Text("\(habit.trackingAmount)")
                    .font(.largeTitle)
            }
            
            Button(action: {
                self.habit.incrementAmount()
            }) {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                    Text("Track Habit".uppercased())
                        .font(.title)
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            Spacer()
        }
    }
}

struct ActivityDetail_Previews: PreviewProvider {
    static var previews: some View {
        ActivityDetail(habit: .constant(Habit(name: "Workout", description: "Getting bigger")))
    }
}

struct AddView: View {
    @State private var name = ""
    @State private var description = ""
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var habits: HabitStore
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
            }
            .navigationBarTitle("Add new habit")
            .navigationBarItems(trailing:
                Button("Save") {
                    let habit = Habit(name: self.name, description: self.description)
                    self.habits.habits.append(habit)
                    self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(habits: HabitStore())
    }
}


struct ContentView: View {
    @ObservedObject var habits = HabitStore()
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(habits.habits.indexed(), id: \.1.id) { index, activity in
                    NavigationLink(destination: ActivityDetail(habit: self.$habits.habits[index])) {
                        ActivityView(activity: activity)
                    }
                }
                .onDelete(perform: removeActivities)
            }
            .sheet(isPresented: $showingAddHabit) {
                AddView(habits: self.habits)
            }
            .navigationBarItems(trailing:
                Button(action: {
                    self.showingAddHabit = true
                }) {
                    Image(systemName: "plus")
                }
            )
        }
    }
    
    func removeActivities(at offsets: IndexSet) {
        habits.habits.remove(atOffsets: offsets)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Sequence {
    func indexed() -> Array<(offset: Int, element: Element)> {
        return Array(enumerated())
    }
}
