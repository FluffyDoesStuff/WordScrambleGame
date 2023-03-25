//
//  ContentView.swift
//  ScrambledWordGuess
//
//  Created by Christian Izak on 3/18/23.
//

import SwiftUI

import Foundation

struct ContentView: View {
    
    @State var name: String = ""
    
    @State var word: String = ""
    
    @State var correct: Int = 0;
    
    @State var currentWord = "";
    
    @State var started = false;
    
    @State var answerOpacity: Double = 0;
    
    @State var letters: Double = 3
    
    @State var hint = true;
    
    @State var filteredWords = [String()]
    
    @State var hideGame = true
    
    @State var barHidden = false
    
    var body: some View {
        VStack {
            Text(currentWord)
                .opacity(answerOpacity)
            if !hideGame {
                Spacer()
                Text(word)
                Text(String(correct))
                    .padding()
                    .dynamicTypeSize(/*@START_MENU_TOKEN@*/.accessibility5/*@END_MENU_TOKEN@*/);
                TextField("Enter Guesses", text: $name)
                    .foregroundColor(/*@START_MENU_TOKEN@*/Color(red: 0.803921568627451, green: 0.8392156862745098, blue: 0.9568627450980393)/*@END_MENU_TOKEN@*/)
                    .padding(5)
                    .overlay(RoundedRectangle(cornerRadius: 50)
                        .stroke(Color(red: 0.4235294117647059, green: 0.4392156862745098, blue: 0.5254901960784314), lineWidth: 1)
                    )
                    .multilineTextAlignment(/*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .lineLimit(/*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    .autocorrectionDisabled(true)
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .onChange(of: name) { newValue in
                        print("Changed")
                        print(name + " " + currentWord)
                        checkIfRight()
                        if(hint == true) {
                            answerOpacity = answerOpacity + 0.001
                        } else {
                            answerOpacity = 0
                        }
                    }
                Spacer()
            } else {
                Spacer()
                Text("Word Size\n\(Int(letters))")
                    .multilineTextAlignment(.center)
                Slider(value: $letters, in: 3...14, step: 1)
                    .onChange(of: letters) { newValue in
                        if(started == true) {
                            name = ""
                            filterData()
                            word = genNewWord()
                        }
                    }
                Spacer()
            }
            
            
            if(started == false) {
                Button(action: {
                    started = true
                    filterData()
                    word = genNewWord()
                    hideGame.toggle()
                    print("Started")
                }) {
                    Text("Start Game")
                }
                .padding()
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color(red: 0.27058823529411763, green: 0.2784313725490196, blue: 0.35294117647058826)/*@END_MENU_TOKEN@*/)
                .foregroundColor(/*@START_MENU_TOKEN@*/Color(red: 0.803921568627451, green: 0.8392156862745098, blue: 0.9568627450980393)/*@END_MENU_TOKEN@*/)
                .cornerRadius(/*@START_MENU_TOKEN@*/20.0/*@END_MENU_TOKEN@*/)
            } else {
                Button(action: {
                    withAnimation{
                        barHidden.toggle()
                    }
                }) {
                    if barHidden == false {
                        Image(systemName: "eye.slash")
                            .frame(width: 10.0, height: 10.0)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "eye")
                            .frame(width: 10.0, height: 10.0)
                            .foregroundColor(.white)
                    }
                    
                }
                .opacity(0.5)
                if(barHidden == false) {
                    HStack {
                        Button(action: {
                        if(hint == true){
                            hint = false
                            } else {
                                hint = true
                            }
                        }) {
                            if(hint == true) {
                                Text("Hide Hint")
                            } else {
                                Text("Show Hint")
                            }
                            
                        }
                        .padding(.horizontal)
                        Button(action: {
                            correct = correct - 1
                            name = ""
                            filterData()
                            word = genNewWord()
                        }) {
                            Text("Skip")
                        }
                        .padding(.horizontal)
                        Button(action: {
                            started = false
                            correct = 0
                            hideGame = true
                        }) {
                            Text("End Game")
                        }
                        .padding(.horizontal)
                    }
                    
                    .padding()
                    .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color(red: 0.27058823529411763, green: 0.2784313725490196, blue: 0.35294117647058826)/*@END_MENU_TOKEN@*/)
                    .foregroundColor(/*@START_MENU_TOKEN@*/Color(red: 0.803921568627451, green: 0.8392156862745098, blue: 0.9568627450980393)/*@END_MENU_TOKEN@*/)
                    .cornerRadius(/*@START_MENU_TOKEN@*/20.0/*@END_MENU_TOKEN@*/)
                }
            }
        }
        .padding()
        .background(Color(red: 0.11764705882352941, green: 0.11764705882352941, blue: 0.1803921568627451))
    }
    
    func startCountdown () {
        answerOpacity = 0
        while answerOpacity < 0.2 {
            answerOpacity = answerOpacity + 0.01
            sleep(1)
        }
    }
    
    func checkIfRight () {
        if (name.lowercased() == currentWord.lowercased()) {
            print("Correct")
            correct = correct + 1
            name = ""
            filterData()
            word = genNewWord()
        };
    }
    
    func genNewWord () -> String {
        let str = filteredWords.randomElement();
        let word = str?.split(separator: "")
        let scrambledword = scrambleArray(word!)
        
        currentWord = str!;
        print(currentWord);
        
        answerOpacity = 0
        
        //startCountdown()
        
        return scrambledword.joined(separator: "");
    }
    
    func createWordList (fromCSVNamed name: String, ofType type: String) -> [String] {
        // Retrieve the path to the file in the app's bundle
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            print("Failed to find file named: \(name).\(type)")
            return []
        }

        // Read the contents of the file
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            print("Failed to read file at path: \(path)")
            return []
        }

        // Extract the second column of data from each row
        var columnData = [String]()
        let rows = content.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count > 1 {
                columnData.append(columns[1].capitalized)
            }
        }

        // Return the extracted column data
        return columnData
    }
    
    func countDownString(from date: Date, until nowDate: Date) -> String {
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar
                .dateComponents([.day, .hour, .minute, .second]
                    ,from: nowDate,
                     to: date)
            return String(format: "%02dd:%02dh:%02d:%02ds",
                          components.day ?? 00,
                          components.hour ?? 00,
                          components.minute ?? 00,
                          components.second ?? 00)
    }
    
    func filterData() {
        let words = createWordList(fromCSVNamed: "Words", ofType: "csv")
        print(words.count)
        filteredWords = [String()]
        for i in 0...words.count - 1 {
            if(words[i].count == Int(letters)) {
                filteredWords.append(words[i])
            }
        }
    }
    
    func scrambleArray<T>(_ array: [T]) -> [T] {
        var newArray = array
        for i in 0..<newArray.count {
            let randomIndex = Int(arc4random_uniform(UInt32(newArray.count)))
            if i != randomIndex {
                newArray.swapAt(i, randomIndex)
            }
        }
        return newArray
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .colorScheme(.dark)
    }
}
