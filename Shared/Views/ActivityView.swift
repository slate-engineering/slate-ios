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
            Color("foreground")
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geo in
                if viewIndex == 0 {
                    Group {
                        if activity.count > 0 {
                            MyScrollView(onRefresh: refresh, onReachBottom: loadNextPage) {
                                LazyVGrid(columns: doubleColumn, alignment: .center, spacing: 16) {
                                    ForEach(activity, id: \.id) { item in
                                        if item.data.type == .addToSlate {
                                            ActivityFileItemView(item: item, width: (geo.size.width - 48) / 2)
                                        } else {
                                            ActivitySlateItemView(item: item, width: (geo.size.width - 48) / 2)
                                        }
                                    }
                                }
                                .padding(.bottom, Constants.bottomMargin)
                                .padding(.top, 8)
                                .padding(.horizontal, Constants.sideMargin)
                                .frame(width: UIScreen.main.bounds.size.width)
                                .background(Color("foreground"))
                            }
                            .background(Color("foreground"))
                            .edgesIgnoringSafeArea(.top)
                        } else if !loading {
                            EmptyStateView(text: "Follow users to see their activity here", icon: Image("globe"))
                                .padding(.horizontal, 16)
                                .padding(.top, 52)
                        } else {
                            Spacer()
                        }
                    }
                    .onAppear {
                        if activity.isEmpty {
                            loading = true
                            fetchActivity() { loading = false }
                        }
                    }
                }
                if viewIndex == 1 {
                    Group {
                        if explore.count > 0 {
                            MyScrollView(onRefresh: refresh, onReachBottom: loadNextPage) {
                                LazyVGrid(columns: doubleColumn, alignment: .center, spacing: 16) {
                                    ForEach(explore, id: \.id) { item in
                                        if item.data.type == .addToSlate {
                                            ActivityFileItemView(item: item, width: (geo.size.width - 48) / 2)
                                        } else {
                                            ActivitySlateItemView(item: item, width: (geo.size.width - 48) / 2)
                                        }
                                    }
                                }
                                .padding(.bottom, Constants.bottomMargin)
                                .padding(.top, 8)
                                .padding(.horizontal, Constants.sideMargin)
                                .frame(width: UIScreen.main.bounds.size.width)
                                .background(Color("foreground"))
                            }
                            .background(Color("foreground"))
                            .edgesIgnoringSafeArea(.top)
                        } else if !loading {
                            EmptyStateView(text: "Activity from around Slate will show up here", icon: Image("globe"))
                                .padding(.horizontal, 16)
                                .padding(.top, 52)
                        } else {
                            Spacer()
                        }
                    }
                    .onAppear {
                        if explore.isEmpty {
                            loading = true
                            fetchExplore() { loading = false }
                        }
                    }
                }
            }
            PageOverlayView(pickerOptions: views, pickerIndex: $viewIndex, style: .hideButton) {}
                .padding(.bottom, 8)
            
            if loading {
                LoaderView("Loading")
            }
        }
    }
    
    func fetchActivity(earliestTimestamp: String? = nil, latestTimestamp: String? = nil, completion: @escaping () -> Void = {}) {
        Actions.getActivity(earliestTimestamp: earliestTimestamp, latestTimestamp: latestTimestamp) { activity in
            if activity.count > 0 {
                if earliestTimestamp != nil {
                    self.activity.append(contentsOf: reformatActivity(activity))
                } else if latestTimestamp != nil {
                    self.activity.insert(contentsOf: reformatActivity(activity), at: 0)
                } else {
                    self.activity = reformatActivity(activity)
                }
                print(self.activity.count)
            }
            completion()
        }
    }
    
    func fetchExplore(earliestTimestamp: String? = nil, latestTimestamp: String? = nil, completion: @escaping () -> Void = {}) {
        Actions.getExplore(earliestTimestamp: earliestTimestamp, latestTimestamp: latestTimestamp) { explore in
            if explore.count > 0 {
                if earliestTimestamp != nil {
                    self.explore.append(contentsOf: reformatActivity(explore))
                } else if latestTimestamp != nil {
                    self.explore.insert(contentsOf: reformatActivity(explore), at: 0)
                } else {
                    self.explore = reformatActivity(explore)
                }
            }
            completion()
        }
    }
    
    func loadNextPage() {
        if loading { return }
        if viewIndex == 0 && activity.count > 0 {
            fetchActivity(earliestTimestamp: activity.last!.createdAt)
        } else if viewIndex == 1 && explore.count > 0 {
            fetchExplore(earliestTimestamp: explore.last!.createdAt)
        }
    }
    
    func refresh(completion: @escaping () -> Void) {
        if loading { return }
        if viewIndex == 0 && activity.count > 0 {
            fetchActivity(latestTimestamp: activity.first!.createdAt, completion: completion)
        } else if viewIndex == 1 && explore.count > 0 {
            fetchExplore(latestTimestamp: explore.first!.createdAt, completion: completion)
        }
    }
    
    func reformatActivity(_ activity: [Activity]) -> [Activity] {
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
