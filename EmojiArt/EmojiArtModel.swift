//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Mckiba Williams on 8/2/20.
//  Copyright © 2020 McKiba Williams. All rights reserved.
//

import Foundation


struct EmojiArtModel: Codable {
    
    var backgroundURL : URL?
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable , Codable , Hashable{
        let text: String
        var y : Int
        var x : Int
        var size : Int
        var id : Int
        
        fileprivate init(text: String ,x : Int ,y : Int ,size : Int ,id : Int){
            
            self.text = text
            self.y = y
            self.x = x
            self.size = size
            self.id = id
        }
    }
    
     var json: Data? {
         return try? JSONEncoder().encode(self)
     }
     
     init?(json: Data?) {
         if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArtModel.self, from: json!) {
             self = newEmojiArt
         } else {
             return nil
         }
     }
     
     init() { }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String , x : Int , y : Int , size: Int){
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
    
    mutating func deleteEmoji(_ index: Int) {
          emojis.remove(at : index)
      }
}
