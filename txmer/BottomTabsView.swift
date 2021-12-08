//
//  BottomTabsView.swift
//  txmer
//
//  Created by macos sucks balls on 12/8/21.
//

import SwiftUI


@available(iOS 15.0, *)
struct BottomTabsView: View {
    @Binding var hide: Bool
    @Binding var currentTab: Tab
    
    var namespace: Namespace.ID
    
    var body: some View {
        if !hide {
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemGray5))
                        
                            .frame(
                                width: geometry.size.width - CGFloat(SetValues.marginLeftRight * 2),
                                height: CGFloat(SetValues.tabBarHeight),
                                alignment: .center
                            )
                            .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 3)
                            .padding(.leading, CGFloat(SetValues.marginLeftRight))
                            .padding(.trailing, CGFloat(SetValues.marginLeftRight))
                    }
                    .zIndex(0)
                    
                                        
                    VStack {
                        Spacer()
                        
                        HStack {
                            HStack {
                                ZStack {
                                    if currentTab == .timer {
                                        VStack {
                                            Spacer()
                                            
//                                            CustomGradientColours.gradientColour
                                            Color.black
                                                .frame(width: 32, height: 2)
                                                .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                                                .offset(x: 7, y: -48)
//                                                .padding(.leading, 14)
                                        }
                                    } else {
                                        VStack {
                                            Spacer()
                                            
                                            Color.clear
                                                .frame(width: 32, height: 2)
                                                .offset(x: 7, y: -48)
                                        }
                                    }
                                    
                                    
                                    
                                    TabIcon(
                                        assignedTab: .timer,
                                        currentTab: $currentTab,
                                        systemIconName: "stopwatch",
                                        systemIconNameSelected: "stopwatch.fill"
                                    )
                                        .padding(.leading, 14)
                                        
                                }
                                
                                
                                
                                Spacer()
                                
                                ZStack {
                                    if currentTab == .solves {
                                        VStack {
                                            Spacer()
                                            
                                            Color.black
                                                .frame(width: 32, height: 2)
                                                .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                                                .offset(y: -48)
                                        }
                                    } else {
                                        VStack {
                                            Spacer()
                                            
                                            Color.clear
                                                .frame(width: 32, height: 2)
                                                .offset(y: -48)
                                        }
                                    }
                                    
                                    TabIcon(
                                        assignedTab: .solves,
                                        currentTab: $currentTab,
                                        systemIconName: "hourglass.bottomhalf.filled",
                                        systemIconNameSelected: "hourglass.tophalf.filled"
                                    )
                                    
                                }
                                
                                
                                
                                Spacer()
                                
                                ZStack {
                                    if currentTab == .stats {
                                        VStack {
                                            Spacer()
                                            
                                            Color.black
                                                .frame(width: 32, height: 2)
                                                .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                                                .offset(y: -48)
                                        }
                                    } else {
                                        VStack {
                                            Spacer()
                                            
                                            Color.clear
                                                .frame(width: 32, height: 2)
                                                .offset(y: -48)
                                        }
                                    }
                                    
                                    TabIcon(
                                        assignedTab: .stats,
                                        currentTab: $currentTab,
                                        systemIconName: "chart.pie",
                                        systemIconNameSelected: "chart.pie.fill"
                                    )
                                    
                                }
                                
                                
                                Spacer()
                                
                                ZStack {
                                    if currentTab == .sessions {
                                        VStack {
                                            Spacer()
                                            
                                            Color.black
                                                .frame(width: 32, height: 2)
                                                .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                                                .offset(x: -7, y: -48)
                                        }
                                    } else {
                                        VStack {
                                            Spacer()
                                            
                                            Color.clear
                                                .frame(width: 32, height: 2)
                                                .offset(x: -7, y: -48)
                                        }
                                    }
                                    
                                    
                                    
                                    TabIcon(
                                        assignedTab: .sessions,
                                        currentTab: $currentTab,
                                        systemIconName: "line.3.horizontal.circle",
                                        systemIconNameSelected: "line.3.horizontal.circle.fill"
                                    )
                                        .padding(.trailing, 14)
                                    
                                }
                                
                                
                            }
                            .frame(
                                width: 220,
                                height: CGFloat(SetValues.tabBarHeight),
                                alignment: .leading
                            )
                            .background(Color(UIColor.systemGray4).clipShape(RoundedRectangle(cornerRadius:12)))
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 3.5)
                            .padding(.leading, CGFloat(SetValues.marginLeftRight))
                            .animation(.spring(), value: self.currentTab)
                            
                            Spacer()
                            
                            
                            
                            TabIcon(
                                assignedTab: .settings,
                                currentTab: $currentTab,
                                systemIconName: "gearshape",
                                systemIconNameSelected: "gearshape.fill"
                            )
                                .padding(.trailing, CGFloat(SetValues.marginLeftRight + 12))
                        }
                    }
                    .zIndex(1)
                }
                
//                VStack {
//                    Spacer()
//
//
//
//
//
//                    }
//                }
//                .zIndex(2)
                
                
                .ignoresSafeArea(.keyboard)
                
            }
            .padding(.bottom, SetValues.hasBottomBar ? CGFloat(0) : CGFloat(SetValues.marginBottom))
            .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.25)), removal: .opacity.animation(.easeIn(duration: 0.1))))
//            .transition(AnyTransition.scale.animation(.easeIn(duration: 1)))
            //
            
        }
    }
        
}

//struct BottomTabsView_Previews: PreviewProvider {
//    static var previews: some View {
//        BottomTabsView()
//    }
//}