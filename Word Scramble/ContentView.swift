//
//  ContentView.swift
//  Word Scramble
//
//  Created by Umair on 14/03/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var useWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var playerScore = 0
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section{
                    ForEach(useWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                Text("Score : \(playerScore)")
                    .font(.title.bold())
                    .foregroundStyle(.green)
                    .frame(width: 350,height: 10)
                    
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform:startGame)
            .alert(errorTitle,isPresented: $showingError) {
                Button("Ok"){}
            }message: {
                Text(errorMessage)
            }
            .toolbar{
                Button("New Game", action: startGame)
            }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count >= 3 else {
            wordError(title: "Word too short.",
                      message: "Please enter words that are at least 3 characters long!")
            return
        }
        
        guard answer != rootWord else {
                    wordError(title: "That's our starting word.",
                              message: "That would be too easy, don't you think?")
                    return
                }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more Original")
            return
        }
        
        guard isPossible(word: answer) else{
            wordError(title: "Word not possible", message: "You cant spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else{
            wordError(title: "Word not recognize", message: "You can't just make them up you know!")
            return
        }
        
        withAnimation{
            useWords.insert(answer, at: 0)
        }
        newWord = ""
        calculateScore()
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                useWords = [String]()
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool{
        !useWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspellRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspellRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func calculateScore() {
        playerScore+=(newWord.count + 1)
        }
}

#Preview {
    ContentView()
}
