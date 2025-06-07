import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.blue.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Kids Learning") // Added back the text view
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.blue)
                    
                    NavigationLink(destination: AlphabetView()) {
                        LearningButton(title: "Learn Alphabet", systemImage: "textformat.abc")
                    }
                    
                    NavigationLink(destination: NumbersView()) {
                        LearningButton(title: "Learn Numbers", systemImage: "textformat.123")
                    }
                }
                .padding()
            }
            .navigationBarHidden(true) // Hid the navigation bar again
            .navigationBarItems(leading: EmptyView())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LearningButton: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 2)
                )
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .frame(width: 280, height: 80)
        .background(Color.blue)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 