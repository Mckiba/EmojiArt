//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by McKiba Williams on 8/2/20.
//  Copyright © 2020 McKiba Williams. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    
    @State private var chosenPalette: String = ""
    
    var body: some View {
        VStack{
            HStack{
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                ScrollView(.horizontal){
                    HStack{
                        
                        ForEach(chosenPalette.map {String($0) }, id: \.self ){ emoji in
                            Text(emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag {return NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
                //.onAppear {self.chosenPalette = self.document.defaultPalette }
            }.padding(.horizontal)
            GeometryReader{ geometry in
                ZStack{
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
                    ).gesture(self.doubleTapZoom(in: geometry.size))
                        .gesture(self.panGesture())
                    if self.isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojis){emoji in
                            EmojiArtSelection( emoji : emoji, zoomScale: self.zoomScale, size : geometry.size)
                                .position(self.position(for: emoji, in: geometry.size))
                                .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                        }
                    }
                }.clipped()
                    .gesture(self.panGesture())
                    .gesture(self.zoomGesture())
                    .edgesIgnoringSafeArea([.horizontal , .bottom])
                    //Resizes Image to fit on drop
                    .onReceive(self.document.$backgroundImage){ image in
                        self.zoomToFit(image, in: geometry.size)
                        
                }
                .onDrop(of: ["public.image","public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url , url != self.document.backgroundURL{
                        self.confirmBackgroundPaste = true
                        // self.document.backgroundURL = url
                    }else{
                        self.explainBackgroundPaste = true
                    }
                },label: {
                    Image(systemName: "doc.on.clipboard").imageScale(.large)
                        .alert(isPresented: self.$explainBackgroundPaste) {
                            return Alert(
                                title: Text("Paste Background"),
                                message: Text("Copy the URL of an image to the clip board and touch this button to make it the background of your document."),
                                dismissButton: .default(Text("OK"))
                            )
                    }
                }))
            }
            //  .zIndex(-1)
        } .alert(isPresented: self.$confirmBackgroundPaste) {
            Alert(
                title: Text("Paste Background"),
                message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?."),
                primaryButton: .default(Text("OK")) {
                    self.document.backgroundURL = UIPasteboard.general.url
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    var isLoading: Bool {
        
        document.backgroundURL != nil && document.backgroundImage == nil
        
    }
    
    
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        
        document.steadyStateZoomScale * gestureZoomScale
        
    }
    
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 , size.height < 0 , size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            document.steadyStatePanOffset = .zero
            document.steadyStateZoomScale = min(hZoom , vZoom)
        }
    }
    
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                if self.hasSelection {
                    self.scaleAllSelectedEmojis(by : 1 + latestGestureScale - gestureZoomScale)
                }
                gestureZoomScale = latestGestureScale
        }
        .onEnded { finalGestureScale in
            self.document.steadyStateZoomScale *= finalGestureScale
        }
    }
    
    
    private func doubleTapZoom(in size: CGSize) -> some Gesture{
        TapGesture(count: 2)
            .onEnded{
                withAnimation{
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
        }
        .exclusively (before:
            // Single-tapping on the background of EmojiArt will remove the emoji from the selection
            TapGesture(count: 1)
                .onEnded {
                    self.document.selection.removeAll()
            }
        )
    }
    
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
        }
        .onEnded { finalDragGestureValue in
            self.document.steadyStatePanOffset = self.document.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
        }
    }
    
    private func font(for emoji: EmojiArtModel.Emoji) -> Font {
        Font.system(size: emoji.fontSize * zoomScale)
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    private let defaultEmojiSize: CGFloat = 40
    
    private func scaleAllSelectedEmojis(by scale : CGFloat){
        self.document.selection.forEach{ selectedEmoji in
            self.document.scaleEmoji(selectedEmoji, by : scale)
        }
    }
    
    private func isSelected(emoji: EmojiArtModel.Emoji) -> Bool {
        self.document.selection.contains(matching : emoji)
    }
    
    private var hasSelection: Bool {
        !self.document.selection.isEmpty
    }
    
}




