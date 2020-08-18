//
//  EmojiArtSelection.swift
//  EmojiArt
//
//  Created by McKiba Williams on 8/18/20.
//  Copyright © 2020 McKiba Williams. All rights reserved.
//

import SwiftUI

struct EmojiArtSelection: View {
    
    @EnvironmentObject var document: EmojiArtDocument
    var emoji : EmojiArtModel.Emoji
    var zoomScale: CGFloat
    var size : CGSize
    var body: some View {
        
        Text(emoji.text)
            .gesture(self.panGesture())
            .onTapGesture {
                // Tapping on an unselected emoji selects it.
                self.document.selection.toggleMatching(toggle : self.emoji)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(style: StrokeStyle(lineWidth:  self.document.selection.contains (matching : emoji) ? 4 : 0, dash: [15.0]))
        )
    }
    
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                self.moveAllSelectedEmojis(by :  ((latestDragGestureValue.translation ) / self.zoomScale ))
        }
    }
    
    private func moveAllSelectedEmojis(by offset : CGSize){
        // all emojis that are selected
        self.document.selection.forEach{ selectedEmoji in
            // move to new position
            self.document.moveEmoji(selectedEmoji, by : offset)
            
            if document.emojis.firstIndex(matching: selectedEmoji) != nil{
                
            }
        }
    }
    
    
}

