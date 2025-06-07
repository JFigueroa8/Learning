import SwiftUI
import AVFoundation

struct AlphabetView: View {
    let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 75, maximum: 90))
            ], spacing: 15) {
                ForEach(alphabet, id: \.self) { letter in
                    NavigationLink(destination: LetterDetailView(letter: String(letter), alphabet: alphabet, navigationDirection: .forward)) {
                        LetterCard(letter: String(letter))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Alphabet")
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
    }
}

struct LetterCard: View {
    let letter: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 3)
            
            VStack(spacing: 6) {
                Text(letter)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.blue)
                
                Text(letter.lowercased())
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.blue.opacity(0.8))
                
                Text(getExampleWord(for: letter))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
        }
        .frame(height: 105)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue, lineWidth: 2)
        )
    }
    
    private func getExampleWord(for letter: String) -> String {
        let words = [
            "A": "Alannah", "B": "Ball", "C": "Cat", "D": "Dog",
            "E": "Elephant", "F": "Fish", "G": "Giraffe", "H": "House",
            "I": "Ice cream", "J": "Jump", "K": "Kobe", "L": "Lion",
            "M": "Moon", "N": "Nest", "O": "Orange", "P": "Pizza",
            "Q": "Queen", "R": "Rainbow", "S": "Sun", "T": "Tree",
            "U": "Umbrella", "V": "Violin", "W": "Water", "X": "Xylophone",
            "Y": "Yellow", "Z": "Zebra"
        ]
        return words[letter] ?? ""
    }
}

enum NavigationDirection {
    case forward
    case backward
}

struct LetterDetailView: View {
    let letter: String
    let alphabet: [Character]
    let navigationDirection: NavigationDirection
    @State private var audioPlayer: AVAudioPlayer?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @Environment(\.presentationMode) var presentationMode
    
    private var currentIndex: Int {
        alphabet.firstIndex(of: Character(letter)) ?? 0
    }
    
    private var previousLetter: String? {
        currentIndex > 0 ? String(alphabet[currentIndex - 1]) : nil
    }
    
    private var nextLetter: String? {
        currentIndex < alphabet.count - 1 ? String(alphabet[currentIndex + 1]) : nil
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Letter display
            VStack(spacing: 20) {
                Text(letter)
                    .font(.system(size: 120, weight: .bold))
                    .foregroundColor(.blue)
                    .transition(.scale.combined(with: .opacity))
                
                Text(letter.lowercased())
                    .font(.system(size: 80, weight: .medium))
                    .foregroundColor(.blue.opacity(0.8))
                    .transition(.scale.combined(with: .opacity))
            }
            .padding()
            .onTapGesture {
                speakLetter(letter: letter)
            }
            
            // Example word
            VStack(spacing: 10) {
                Text("Example Word:")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text(getExampleWord(for: letter))
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.blue)
                    .transition(.scale.combined(with: .opacity))
                    .onTapGesture {
                        speakWord(word: getExampleWord(for: letter))
                    }
            }
            
            // Navigation buttons
            HStack(spacing: 40) {
                if currentIndex > 0 {
                    NavigationLink(destination: LetterDetailView(letter: previousLetter!, alphabet: alphabet, navigationDirection: .backward)) {
                        NavigationButton(letter: previousLetter!, direction: "Previous")
                    }
                }
                
                if currentIndex < alphabet.count - 1 {
                    NavigationLink(destination: LetterDetailView(letter: nextLetter!, alphabet: alphabet, navigationDirection: .forward)) {
                        NavigationButton(letter: nextLetter!, direction: "Next")
                    }
                }
            }
            .padding()
            .opacity(currentIndex == 0 || currentIndex == alphabet.count - 1 ? 0.5 : 1)
        }
        .padding()
        .navigationTitle("Letter \(letter)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: 
                NavigationLink(destination: AlphabetView().navigationBarHidden(true)) {
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
    
    private func speakLetter(letter: String) {
        let utterance = AVSpeechUtterance(string: letter.lowercased())
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        speechSynthesizer.speak(utterance)
    }
    
    private func speakWord(word: String) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        speechSynthesizer.speak(utterance)
    }
    
    private func getExampleWord(for letter: String) -> String {
        let words = [
            "A": "Alannah", "B": "Ball", "C": "Cat", "D": "Dog",
            "E": "Elephant", "F": "Fish", "G": "Giraffe", "H": "House",
            "I": "Ice cream", "J": "Jump", "K": "Kobe", "L": "Lion",
            "M": "Moon", "N": "Nest", "O": "Orange", "P": "Pizza",
            "Q": "Queen", "R": "Rainbow", "S": "Sun", "T": "Tree",
            "U": "Umbrella", "V": "Violin", "W": "Water", "X": "Xylophone",
            "Y": "Yellow", "Z": "Zebra"
        ]
        return words[letter] ?? ""
    }
}

struct NavigationButton: View {
    let letter: String
    let direction: String
    
    var body: some View {
        VStack {
            Text(direction)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(letter)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 3)
        }
    }
}

struct AlphabetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlphabetView()
        }
    }
} 