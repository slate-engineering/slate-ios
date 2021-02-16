//
//  TooltipView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/10/21.
//

import SwiftUI

struct TooltipView: View {
    let text: String
    @State private var showTooltip = false
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("info-circle")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color("grayBlack"))
                    .onTapGesture {
                        calculateFrame(geo: geo)
                        showTooltip.toggle()
                    }
            }
            .frame(width: 16, height: 16)
            if showTooltip {
                Text(text)
                    .font(Font.custom("Inter", size: 14))
//                    .foregroundColor(Color("textGray"))
                    .padding(8)
                    .background(Blur())
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .frame(width: 200, height: 200)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .frame(width: 16, height: 16)
    }
    
    func calculateFrame(geo: GeometryProxy) {
        if geo.frame(in: .global).minX < UIScreen.main.bounds.size.width - geo.frame(in: .global).maxX {
            //go right
            if geo.frame(in: .global).minY < UIScreen.main.bounds.size.height - geo.frame(in: .global).maxY {
                //go down
            } else {
                //go up
            }
        } else {
            //go left
            if geo.frame(in: .global).minY < UIScreen.main.bounds.size.height - geo.frame(in: .global).maxY {
                //go down
            } else {
                //go up
            }
        }
        if geo.frame(in: .global).minY < UIScreen.main.bounds.size.height - geo.frame(in: .global).maxY {
            //go down
        } else {
            //go up
        }
    }
}

struct TooltipView_Previews: PreviewProvider {
    static var previews: some View {
        TooltipView(text: "All slates are public by default. This means they can be discovered and seen by anyone on the internet. If you make it private, only you will be able to see it")
    }
}
