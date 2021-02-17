//
//  ActivityView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/29/21.
//

import SwiftUI

struct ActivityView: View {
    let doubleColumn: [GridItem] = [
        GridItem(.flexible(), spacing: Constants.sideMargin),
        GridItem(.flexible(), spacing: Constants.sideMargin)
    ]
    let views = ["Activity", "Explore"]
    @State private var viewIndex = 0
    @State private var activity = [Activity]()
    @State private var explore = [Activity]()
    @State private var loading = true
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                if viewIndex == 0 {
                    Group {
                        if activity.count > 0 {
                            ScrollView(.vertical) {
                                Spacer()
                                    .frame(height: 8)
                                LazyVGrid(columns: doubleColumn, alignment: .center, spacing: 16) {
                                    ForEach(activity) { item in
                                        if item.data.type == .addToSlate {
                                            ActivityFileItemView(item: item, width: (geo.size.width - 48) / 2)
                                        } else {
                                            ActivitySlateItemView(item: item, width: (geo.size.width - 48) / 2)
                                        }
                                    }
                                }
                                .padding(.horizontal, Constants.sideMargin)
                                Spacer()
                                    .frame(height: Constants.bottomMargin)
                            }
                        } else {
                            EmptyStateView(text: "Follow users to see their activity here", icon: Image("globe"))
                                .padding(.horizontal, 16)
                                .padding(.top, 52)
                        }
                    }
                    .onAppear { fetchActivity() }
                }
                if viewIndex == 1 {
                    Group {
                        if explore.count > 0 {
                            ScrollView(.vertical) {
                                Spacer()
                                    .frame(height: 8)
                                LazyVGrid(columns: doubleColumn, alignment: .center, spacing: 16) {
                                    ForEach(explore) { item in
                                        if item.data.type == .addToSlate {
                                            ActivityFileItemView(item: item, width: (geo.size.width - 48) / 2)
                                        } else {
                                            ActivitySlateItemView(item: item, width: (geo.size.width - 48) / 2)
                                        }
                                    }
                                }
                                .padding(.horizontal, Constants.sideMargin)
                                Spacer()
                                    .frame(height: Constants.bottomMargin)
                            }
                        } else {
                            EmptyStateView(text: "Activity from around Slate will show up here", icon: Image("globe"))
                                .padding(.horizontal, 16)
                                .padding(.top, 52)
                        }
                    }
                    .onAppear { fetchExplore() }
                }
            }
            PageOverlayView(pickerOptions: views, pickerIndex: $viewIndex, style: .hideButton) {}
                .padding(.bottom, 52)
            
            if loading {
                LoaderView("Loading")
            }
        }
    }
    
    func fetchActivity() {
        loading = true
        Actions.getActivity { activity in
            self.activity = reformatActivity(activity)
            loading = false
        }
    }
    
    func fetchExplore() {
        loading = true
        Actions.getExplore { activity in
            self.explore = reformatActivity(activity)
            loading = false
        }
    }
    
    func reformatActivity(_ activity: [Activity]) -> [Activity] {
        print(activity)
        var formattedActivity = [Activity]()
        for index in 0..<activity.count {
            var item = activity[index]
            if item.data.type == .addToSlate {
                formattedActivity.append(item)
            }
            let objects = item.data.context.slate.data.objects
            for fileIndex in (0..<objects.count).reversed() {
                let file = objects[fileIndex]
                if file.type.hasPrefix("image/") {
                    item.data.context.file = file
                    formattedActivity.append(item)
                    break
                }
            }
        }
        return formattedActivity
    }
}

struct ActivityFileItemView: View {
    let item: Activity
    var width: CGFloat
    var fontSize: CGFloat {
        let size = (10.0 + (width - 175.0) * 10.0 / 175.0).clamped(to: 10...16)
        return size
    }
    
    var body: some View {
        if item.data.context.file != nil {
            MediaPreviewView(item.data.context.file!, width: width)
                .background(Color.white)
                .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
        }
    }
}

struct ActivitySlateItemView: View {
    let item: Activity
    var width: CGFloat
    var fontSize: CGFloat {
        let size = (10.0 + (width - 175.0) * 10.0 / 175.0).clamped(to: 10...16)
        return size
    }
    
    var body: some View {
        let slate = item.data.context.slate
        ZStack(alignment: .leading) {
            MediaPreviewView(item.data.context.file!, width: width)
                .background(Color.white)
                .shadow(color: Color(red: 178/255, green: 178/255, blue: 178/255).opacity(0.15), radius: 10, x: 0, y: 5)
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                Text(slate.data.name)
                    .font(Font.custom("Inter", size: fontSize * 1.3))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("white"))
                    .lineLimit(2)
                Text("\(slate.data.objects.count) file\(slate.data.objects.count == 1 ? "" : "s")")
                    .font(Font.custom("Inter", size: fontSize))
                    .fontWeight(.medium)
                    .foregroundColor(Color("textGrayLight"))
            }
            .padding(fontSize)
            .frame(width: width, alignment: .bottomLeading)
            .background(LinearGradient(gradient: Gradient(colors: [.clear, Color.black.opacity(0.2), Color.black.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
        }
        .frame(width: width, height: width)
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
