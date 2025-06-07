import SwiftUI
import AVFoundation

struct NumbersView: View {
    @State private var selectedNumber: Int?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showingCountingExercise = false
    
    let numbers = Array(1...20)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80, maximum: 100))
                ], spacing: 20) {
                    ForEach(numbers, id: \.self) { number in
                        NumberCard(number: number)
                            .onTapGesture {
                                playNumberSound(number: number)
                            }
                    }
                }
                .padding()
                
                Button(action: {
                    showingCountingExercise = true
                }) {
                    Text("Practice Counting")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 280, height: 60)
                        .background(Color.green)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                }
            }
        }
        .navigationTitle("Numbers")
        .background(Color.blue.opacity(0.1))
        .sheet(isPresented: $showingCountingExercise) {
            CountingExerciseView()
        }
    }
    
    private func playNumberSound(number: Int) {
        guard let url = Bundle.main.url(forResource: "\(number)", withExtension: "mp3") else {
            print("Sound file not found for number: \(number)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}

struct NumberCard: View {
    let number: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 3)
            
            VStack {
                Text("\(number)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blue)
                
                Text(numberToWord(number))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 100)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue, lineWidth: 2)
        )
    }
    
    private func numberToWord(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}

struct CountingExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentNumber = Int.random(in: 1...10)
    @State private var showingAnswer = false
    
    private func getNextNumber() -> Int {
        var nextNumber: Int
        repeat {
            nextNumber = Int.random(in: 1...10)
        } while nextNumber == currentNumber
        return nextNumber
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("How many objects do you see?")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            
            // Show the correct number of ducks
            Text(String(repeating: "🦆 ", count: currentNumber))
                .font(.system(size: 50))
            
            if showingAnswer {
                Text("\(currentNumber)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.green)
            }
            
            Button(action: {
                withAnimation {
                    if showingAnswer {
                        // Generate a new random number that's different from the current one
                        currentNumber = getNextNumber()
                        showingAnswer = false
                    } else {
                        showingAnswer = true
                    }
                }
            }) {
                Text(showingAnswer ? "Next" : "Show Answer")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            
            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .padding()
    }
}

struct NumbersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NumbersView()
        }
    }
} 