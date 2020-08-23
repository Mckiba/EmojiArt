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
            self.document.moveEmoji(selectedEmoji, by : offset)
            
            if let index = document.emojis.firstIndex(matching: selectedEmoji){
                if emojiIsOutsideDocumentArea(index : index)  {
                    // remove from model
                    document.deleteEmoji(selectedEmoji)
                    document.selection.toggleMatching(toggle: selectedEmoji)
                    
                }
            }
        }
        
        
    }
    
    // Check if emoji has been moved outside of the document background
    private func emojiIsOutsideDocumentArea(index : Int) -> Bool {
        let maxWidth = Int(size.width / self.zoomScale / 2)
        let maxHeight = Int(size.height / self.zoomScale / 2)
        let margin = 6
        return  (abs( document.emojis[index].x) + margin) >= maxWidth ||
            (abs(document.emojis[index].y) + margin) >= maxHeight
        
    }
    
}

