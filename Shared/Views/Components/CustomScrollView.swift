//
//  CustomScrollView.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 2/23/21.
//

import SwiftUI

struct RefreshableScrollView<Content: View>: UIViewRepresentable {
    var width: CGFloat
    var height: CGFloat
    var refresh: () -> Void
    var refreshViewController: UIHostingController<Content>
    
    init(size: CGSize, refresh: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.width = size.width
        self.height = size.height
        self.refresh = refresh
        self.refreshViewController = UIHostingController(rootView: content())
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
//        scrollView.refreshControl = UIRefreshControl()
//        scrollView.refreshControl?.addTarget(
//            context.coordinator,
//            action: #selector(Coordinator.handleRefreshControl(sender:)),
//            for: .valueChanged
//        )
        refreshViewController.view.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        scrollView.addSubview(self.refreshViewController.view)
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var refreshScrollView: RefreshableScrollView
        
        init(_ refreshScrollView: RefreshableScrollView) {
            self.refreshScrollView = refreshScrollView
        }
        
//        @objc func handleRefreshControl(sender: UIRefreshControl) {
//            self.refreshScrollView.refresh()
//            sender.endRefreshing()
//        }
    }
}


struct MyScrollView<Content: View>: UIViewRepresentable {
    var refreshViewController: UIHostingController<Content>
    var onRefresh: (@escaping () -> Void) -> Void
    var onReachBottom: () -> Void
    
    init(onRefresh: @escaping ( @escaping () -> Void) -> Void, onReachBottom: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.onRefresh = onRefresh
        self.onReachBottom = onReachBottom
        self.refreshViewController = UIHostingController(rootView: content())
    }

    func makeUIView(context: UIViewRepresentableContext<MyScrollView>)
               -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(context.coordinator, action:
            #selector(Coordinator.handleRefresh),
                                          for: .valueChanged)
        
        
        scrollView.addSubview(self.refreshViewController.view)
        pinEdges(of: self.refreshViewController.view, to: scrollView)
        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView,
        context: UIViewRepresentableContext<MyScrollView>) {
        
        scrollView.addSubview(self.refreshViewController.view)
        pinEdges(of: self.refreshViewController.view, to: scrollView)
    }
    
    func makeCoordinator() -> Coordinator {
         Coordinator(self)
    }
    
    func pinEdges(of viewA: UIView, to viewB: UIView) {
        viewA.translatesAutoresizingMaskIntoConstraints = false
        viewB.addConstraints([
            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor),
        ])
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: MyScrollView
        var startPoint: CGFloat = .zero

        init(_ parent: MyScrollView) {
            self.parent = parent
        }

//        func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height - 200 {
//                parent.onReachBottom()
//            }
//        }
//
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            startPoint = scrollView.contentOffset.y
        }
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if startPoint < scrollView.contentOffset.y && scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height - 200 {
                parent.onReachBottom()
            }
        }

        @objc func handleRefresh(sender: UIRefreshControl) {
            parent.onRefresh() {
                DispatchQueue.main.async {
                    sender.endRefreshing()
                }
            }
        }
    }
}

struct CustomScrollView<Content: View>: UIViewRepresentable {
    var content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let view = UIScrollView()
        
//        let swiftUIView = content() // swiftUIView is View
//        let viewCtrl = UIHostingController(rootView: swiftUIView)
//        view.addSubview(viewCtrl)
        
        var child = UIHostingController(rootView: content())
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.frame = view.bounds
        view.addSubview(child.view)
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        print("update ui view")
    }
    
    func makeCoordinator() -> CustomScrollView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: CustomScrollView
        
        init(_ parent: CustomScrollView) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            print("scroll view did scroll")
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height {
                print("reached bottom of view")
            }
        }
    }
}




struct UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {
    var content: () -> Content
    var messageCount = 0

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    func makeUIViewController(context: Context) -> UIScrollViewController {
        let vc = UIScrollViewController()
        vc.hostingController.rootView = AnyView(self.content())
        return vc
    }

    func updateUIViewController(_ viewController: UIScrollViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let view = UIScrollView()
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        print("update ui view")
    }
    
    func makeCoordinator() -> UIScrollViewWrapper.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: UIScrollViewWrapper
        
        init(_ parent: UIScrollViewWrapper) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            print("scroll view did scroll")
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height {
                print("reached bottom of view")
            }
        }
    }
}

class UIScrollViewController: UIViewController {
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
//        v.isPagingEnabled = true
        return v
    }()

    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.scrollView)
        self.pinEdges(of: self.scrollView, to: self.view)

        self.hostingController.willMove(toParent: self)
        self.scrollView.addSubview(self.hostingController.view)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)
    }
    
    func pinEdges(of viewA: UIView, to viewB: UIView) {
        viewA.translatesAutoresizingMaskIntoConstraints = false
        viewB.addConstraints([
            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor),
        ])
    }
}
