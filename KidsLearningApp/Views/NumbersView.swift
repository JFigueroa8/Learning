import SwiftUI
import AVFoundation

struct NumbersView: View {
    @State private var selectedNumber: Int?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showingCountingExercise = false
    
    let numbers = Array(1...100)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 80, maximum: 100))
                ], spacing: 20) {
                    ForEach(numbers, id: \.self) { number in
                        NavigationLink(destination: NumberDetailView(number: number, numbers: numbers, navigationDirection: .forward)) {
                            NumberCard(number: number)
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
        .navigationBarItems(
            trailing:
                NavigationLink(destination: ContentView().navigationBarHidden(true)) {
                    HStack(spacing: 4) {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .foregroundColor(.blue)
                }
        )
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

struct NumberDetailView: View {
    let number: Int
    let numbers: [Int]
    let navigationDirection: NavigationDirection
    @State private var audioPlayer: AVAudioPlayer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @Environment(\.presentationMode) var presentationMode
    
    private var currentIndex: Int {
        numbers.firstIndex(of: number) ?? 0
    }
    
    private var previousNumber: Int? {
        currentIndex > 0 ? numbers[currentIndex - 1] : nil
    }
    
    private var nextNumber: Int? {
        currentIndex < numbers.count - 1 ? numbers[currentIndex + 1] : nil
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Number display
            VStack(spacing: 20) {
                Text("\(number)")
                    .font(.system(size: 120, weight: .bold))
                    .foregroundColor(.blue)
                    .transition(.scale.combined(with: .opacity))
                
                Text(numberToWord(number))
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.blue.opacity(0.8))
                    .transition(.scale.combined(with: .opacity))
            }
            .padding()
            .onTapGesture {
                speakNumber(number: number)
            }
            
            // Navigation buttons
            HStack(spacing: 40) {
                if currentIndex > 0 {
                    NavigationLink(destination: NumberDetailView(number: previousNumber!, numbers: numbers, navigationDirection: .backward)) {
                        NavigationButton(letter: "\(previousNumber!)", direction: "Previous")
                    }
                }
                
                if currentIndex < numbers.count - 1 {
                    NavigationLink(destination: NumberDetailView(number: nextNumber!, numbers: numbers, navigationDirection: .forward)) {
                        NavigationButton(letter: "\(nextNumber!)", direction: "Next")
                    }
                }
            }
            .padding()
        }
        .padding()
        .navigationTitle("Number \(number)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: 
                NavigationLink(destination: NumbersView().navigationBarHidden(true)) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                },
            trailing:
                NavigationLink(destination: ContentView().navigationBarHidden(true)) {
                    HStack(spacing: 4) {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .foregroundColor(.blue)
                }
        )
        .transition(navigationDirection == .forward ? 
            .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)) :
            .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
    }
    
    private func speakNumber(number: Int) {
        let utterance = AVSpeechUtterance(string: "\(number)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        speechSynthesizer.speak(utterance)
    }
    
    private func numberToWord(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}

struct NumbersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NumbersView()
        }
    }
} 