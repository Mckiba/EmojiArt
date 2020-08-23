//
//  DocumentChooser.swift
//  EmojiArt
//
//  Created by Pamela Williams on 8/22/20.
//  Copyright © 2020 McKiba Williams. All rights reserved.
//

import SwiftUI

struct DocumentChooser: View {
    
    @EnvironmentObject var store: EmojiArtDocumentStore
    @EnvironmentObject var document: EmojiArtDocument
    
    @State private var editMode: EditMode = .inactive

    
    var body: some View {
        NavigationView{
            List{
                ForEach(store.documents) {document in
                    NavigationLink(destination: EmojiArtDocumentView(document: document)
                        .navigationBarTitle(self.store.name(for: document)))
                    {
                        EditableText(self.store.name(for: document),isEditing: self.editMode.isEditing){ text in
                            self.store.setName(text, for: document)
                        }
                    }
                }.onDelete { indexSet in
                    indexSet.map { self.store.documents[$0]} .forEach {document in
                        self.store.removeDocument(document)
                    }
                }
            }.navigationBarTitle(self.store.name)
                .navigationBarItems(leading: Button(action: {
                    self.store.addDocument()
                }, label: {
                    Image(systemName: "plus").imageScale(.large)
                }),
                    trailing: EditButton()
            )
            .environment(\.editMode, $editMode)

        }
    }
}

struct DocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        DocumentChooser()
    }
}
