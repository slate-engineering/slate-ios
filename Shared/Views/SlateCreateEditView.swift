//
//  NewSlateView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/10/21.
//

import SwiftUI

struct CreateSlateView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        SlateSheetView(parentPresentationMode: presentationMode, name: "", description: "", selectedIndex: 0, viewType: .create)
    }
}

struct EditSlateView: View {
    var slate: Slate
    @Binding var parentPresentationMode: PresentationMode
    var body: some View {
        SlateSheetView(parentPresentationMode: $parentPresentationMode, slate: slate, name: slate.data.name, description: slate.data.body ?? "", selectedIndex: slate.data.isPublic ? 0 : 1, viewType: .edit)
    }
}


struct SlateSheetView: View {
    enum ViewTypes {
        case edit, create
    }
    
    @Binding var parentPresentationMode: PresentationMode
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewer: User
    var slate: Slate? = nil
    @State var name: String
    @State var description: String
    @State var selectedIndex: Int
    var viewType: ViewTypes
    
    private var isPublic: Bool {
        selectedIndex == 0
    }
    @State private var showPrivacyTooltip = false
    @State private var loadingMessage: String? = nil
    @State private var alert: AlertMessage? = nil
    
    var body: some View {
        ZStack {
            VStack {
                NavigationBarView(title: viewType == .create ? "Create slate" : "Edit slate",
                                  left: {
                                    Image("dismiss")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(Color("grayBlack"))
                                        .onTapGesture { presentationMode.wrappedValue.dismiss() }
                                  },
                                  right: {
                                    Image("check")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(Color("grayBlack"))
                                        .onTapGesture {
                                            if viewType == .create {
                                                loadingMessage = "Creating slate"
                                                createSlate()
                                            } else {
                                                loadingMessage = "Saving"
                                                editSlate()
                                            }
                                        }
                                  })
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading) {
                        Text("SLATE DETAILS")
                            .sectionHeaderStyle()
                            .padding(.bottom, 4)
                        
                        InputView("Name", text: $name)
                        
                        TextBoxView("Description", text: $description)
                            .frame(height: 120)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("PRIVACY")
                            .sectionHeaderStyle()
                            .padding(.bottom, 4)
                            
                        RadioButtonView(options: ["Public", "Private"], selectedIndex: $selectedIndex)
                            .padding(.horizontal, 16)
    //                      .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color("bgGray"), lineWidth: 1))
                    }
                    
                    ButtonView(.warning, action: deleteSlateMessage) {
                        Text("Delete slate")
                            .font(Font.custom("Inter", size: 14))
                            .fontWeight(.semibold)
                    }
                    .alert(item: $alert) {
                        Alert(title: Text($0.title), message: Text($0.message), primaryButton: .destructive(Text("Delete")) {
                            loadingMessage = "Deleting slate"
                            self.deleteSlate()
                        }, secondaryButton: .cancel())
                    }
                }
                .padding(.horizontal, Constants.sideMargin)
                .padding(.top, 12)
                Spacer()
            }
            
            if loadingMessage != nil {
                LoaderView(loadingMessage!)
            }
        }
    }
    
    func createSlate() {
        Actions.createSlate(name: name, description: description, isPublic: isPublic) {
            DispatchQueue.main.async {
                loadingMessage = nil
                presentationMode.wrappedValue.dismiss()
                Actions.rehydrateViewer(viewer: viewer)
            }
        }
    }
    
    func editSlate() {
        guard let currentSlate = slate else {
            return
        }
        Actions.editSlate(id: currentSlate.id, name: name, description: description, isPublic: isPublic) {
            DispatchQueue.main.async {
                loadingMessage = nil
                presentationMode.wrappedValue.dismiss()
                Actions.rehydrateViewer(viewer: viewer)
            }
        }
    }
    
    func deleteSlateMessage() {
        alert = AlertMessage(title: "Are you sure you want to delete this slate?", message: "This action is irreversible")
    }
    
    func deleteSlate() {
        guard let currentSlate = slate else {
            return
        }
        Actions.deleteSlate(id: currentSlate.id) {
            DispatchQueue.main.async {
                loadingMessage = nil
                $parentPresentationMode.wrappedValue.dismiss()
                presentationMode.wrappedValue.dismiss()
                Actions.rehydrateViewer(viewer: viewer)
            }
        }
    }
}

struct SlateCreateEditView_Previews: PreviewProvider {
    static var previews: some View {
        CreateSlateView()
    }
}
