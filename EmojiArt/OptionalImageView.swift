//
//  OptionalImageView.swift
//  EmojiArt
//
//  Created by McKiba Williams on 8/13/20.
//  Copyright © 2020 McKiba Williams. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        
        Group{
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
            
        }
    }
}

