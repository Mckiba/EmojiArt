//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by McKiba Williams on 8/2/20.
//  Copyright © 2020 McKiba Williams. All rights reserved.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject {
    
    
    static let palette: String = "☹️😒😖🤗😶😨"
    
    @Published private var emojiArt: EmojiArtModel /* {
     willSet{
     objectWillChange.send()
     }
     didSet{
     UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)
     //print("json = \(emojiArt.json?.utf8 ?? "nill")")
     }
     }*/
    
    private var autosaveCancellable: AnyCancellable?
    
    
    @Published var selection  = Set<EmojiArtModel.Emoji>()
    
    private static let untitled = "EmojiArtDocument.Untitled"
    
    
    
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis : [EmojiArtModel.Emoji] {emojiArt.emojis}
    
    init() {
        
        emojiArt = EmojiArtModel(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArtModel()
        autosaveCancellable = $emojiArt.sink {  emojiArt in
            print("json = \(emojiArt.json?.utf8 ?? "nill")")
            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
        fetchBackgroundImageData()
        
    }
    
    
    //Mark:  - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func deleteEmoji(_ emoji: EmojiArtModel.Emoji) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.deleteEmoji(index)
        }
    }
    
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji){
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    var backgroundURL: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }
    
    private var fetchImageCancellable : AnyCancellable?
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            //Gets the new image data when the previous one is cancelled
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, urlResponse in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \.backgroundImage, on: self)
        }
    }
}
extension EmojiArtModel.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}

extension Set where Element : Identifiable {
    mutating func toggleMatching(toggle element: Element){
        if let index = firstIndex(matching : element) {
            self.remove(at : index)
        } else {
            self.update(with : element)
        }
    }
}
