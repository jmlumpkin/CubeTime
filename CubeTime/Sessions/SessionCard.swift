import SwiftUI
import Foundation

struct SessionCard: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize

    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @State private var isShowingDeleteDialog = false
    @State private var isShowingCustomizeDialog = false
    
    @ScaledMetric private var pinnedSessionHeight: CGFloat = 110
    @ScaledMetric private var regularSessionHeight: CGFloat = 65
    
    
    var item: Session
    var allSessions: FetchedResults<Session>
    
    let pinned: Bool
    let sessionType: SessionType
    let name: String
    let scrambleType: Int
    let solveCount: Int
    let parentGeo: GeometryProxy
    
    @Namespace var namespace
    
    init (item: Session, allSessions: FetchedResults<Session>, parentGeo: GeometryProxy) {
        self.item = item
        self.allSessions = allSessions
        
        // Copy out the things so that it won't change to null coalesced defaults on deletion
        self.pinned = item.pinned
        self.sessionType = SessionType(rawValue: item.sessionType)!
        self.name = item.name ?? "Unknown session name"
        self.scrambleType = Int(item.scrambleType)
        self.solveCount = item.solves?.count ?? -1
        
        self.parentGeo = parentGeo
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("indent1"))
                .frame(height: pinned ? pinnedSessionHeight : regularSessionHeight)
                .zIndex(0)
            
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("overlay0"))
                .frame(width: stopwatchManager.currentSession == item ? 16 : nil,
                       height: item.pinned ? pinnedSessionHeight : regularSessionHeight)
                .offset(x: stopwatchManager.currentSession == item
                        ? -((parentGeo.size.width - 16)/2) + 16
                        : 0)
            
                .zIndex(1)
            
            
        
            
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center, spacing: 0) {
                            ZStack {
                                if sessionType != .standard {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color("accent").opacity(0.33))
                                        .frame(width: 40, height: 40)
                                        .padding(.trailing, 12)
                                }
                                
                                Group {
                                    switch sessionType {
                                    case .algtrainer:
                                        Image(systemName: "command.square")
                                            .font(.system(size: 26, weight: .semibold))
                                        
                                    case .playground:
                                        Image(systemName: "square.on.square")
                                            .font(.system(size: 22, weight: .semibold))
                                        
                                    case .multiphase:
                                        Image(systemName: "square.stack")
                                            .font(.system(size: 22, weight: .semibold))
                                        
                                    case .compsim:
                                        Image(systemName: "globe.asia.australia")
                                            .font(.system(size: 26, weight: .bold))
                                        
                                    default:
                                        EmptyView()
                                    }
                                }
                                .foregroundColor(Color("accent"))
                                .padding(.trailing, 12)
                            }
                            
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(name)
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(Color("dark"))
                                
                                Group {
                                    switch sessionType {
                                    case .standard:
                                        Text(puzzle_types[scrambleType].name)
                                    case .playground:
                                        Text("Playground")
                                    case .multiphase:
                                        Text("Multiphase - \(puzzle_types[scrambleType].name)")
                                    case .compsim:
                                        Text("Comp Sim - \(puzzle_types[scrambleType].name)")
                                    default:
                                        EmptyView()
                                    }
                                }
                                .font(.subheadline.weight(.medium))
                                    .foregroundColor(Color("dark"))
                                .if(!pinned) { view in
                                    view.offset(y: -2)
                                }
                            }
                        }
                        
                        if pinned {
                            Spacer()
                            Text("\(solveCount) Solves")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Color("grey"))
                                .padding(.bottom, 4)
                        }
                    }
                    .offset(x: stopwatchManager.currentSession == item ? 10 : 0)
                    
                    Spacer()
                    
                    if sessionType != .playground {
                        if item.pinned {
                            Image(puzzle_types[scrambleType].name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color("dark"))
                                .padding(.vertical, 4)
                                .padding(.trailing, 12)
                        } else {
                            Image(puzzle_types[scrambleType].name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color("dark"))
                                .padding(.trailing, 6)
                        }
                    }
                    
                    
                }
                .padding(.leading)
                .padding(.trailing, pinned ? 6 : 4)
                .padding(.vertical,  pinned ? 12 : 8)
            }
            
            .frame(height: pinned ? pinnedSessionHeight : regularSessionHeight)
            
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .zIndex(2)
        }
        .onTapGesture {
            withAnimation(Animation.customDampedSpring) {
                if stopwatchManager.currentSession != item {
                    stopwatchManager.currentSession = item
                }
            }
        }
        
        
        
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 12, style: .continuous))
        
        .contextMenu(menuItems: {
            ContextMenuButton(delay: false,
                              action: { isShowingCustomizeDialog = true },
                              title: "Customise",
                              systemImage: "pencil", disableButton: false);
            
            ContextMenuButton(delay: true,
                              action: {
                withAnimation(Animation.customDampedSpring) {
                    item.pinned.toggle()
                    try! managedObjectContext.save()
                }
            },
                              title: item.pinned ? "Unpin" : "Pin",
                              systemImage: item.pinned ? "pin.slash" : "pin", disableButton: false);
            Divider()
            
            ContextMenuButton(delay: false,
                              action: { isShowingDeleteDialog = true },
                              title: "Delete Session",
                              systemImage: "trash",
                              disableButton: allSessions.count <= 1)
                .foregroundColor(Color.red)
        })
        .padding(.horizontal)
        
        .sheet(isPresented: $isShowingCustomizeDialog) {
            CustomiseSessionView(sessionItem: item)
                .tint(Color("accent"))
        }
        
        .confirmationDialog(String("Are you sure you want to delete \"\(name)\"? All solves will be deleted and this cannot be undone."), isPresented: $isShowingDeleteDialog, titleVisibility: .visible) {
            Button("Confirm", role: .destructive) {
                if item == stopwatchManager.currentSession {
                    var next: Session? = nil
                    for item in allSessions {
                        if item != stopwatchManager.currentSession {
                            next = item
                            break
                        }
                        /// **this should theoretically never happen, as the deletion option will be disabled if solves <= 1**
                        NSLog("ERROR: cannot find next session to replace current session")
                    }
                    
                    if let next = next {
                        withAnimation(Animation.customDampedSpring) {
                            stopwatchManager.currentSession = next
                        }
                        
                    }
                }
                
                withAnimation(Animation.customDampedSpring) {
                    managedObjectContext.delete(item)
                    try! managedObjectContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

