//
//  ContentView.swift
//  timer
//
//  Created by Tim Xie on 21/11/21.
//

import CoreData
import SwiftUI
import CoreGraphics

import UIKit



var userHoldTime: Double = 0.5 /// todo make so user can set in setting

let timerColourDefault = Color.black
let timerColourHeld = Color.red
let timerColourHeldCanStart = Color.green


enum stopWatchMode {
    case running
    case stopped
}


class StopWatchManager: ObservableObject {
    @Published var mode: stopWatchMode = .stopped
    
    @Published var secondsElapsed = 0.0
    
    var timer = Timer()
    
    /// todo set custom fps for battery purpose, promotion can set as low as 10 / 24hz ,others 60 fixed, no option for them >:C
    var frameTime: Double = 1/60
    
    func start() {
        mode = .running
        
        secondsElapsed = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: frameTime, repeats: true) { [self] timer in
            self.secondsElapsed += self.frameTime
        }
    }
    
    func stop() {
        timer.invalidate()
        mode = .stopped

    }
    
    @Published var timerColour: Color = timerColourDefault
    
    private var canStartTimer = false
    
    private var taskAfterHold: DispatchWorkItem?
    
    private let feedbackStyle = UIImpactFeedbackGenerator(style: .medium) /// TODO: add option to change heaviness/turn on off in settings
    
    func touchDown() {
        NSLog("Touch down recieved!")
        if mode == .running {
            NSLog("Stopping timer...")
            stop()
        } else {
            NSLog("setting touchDownTime")
            let newTaskAfterHold = DispatchWorkItem {
                self.canStartTimer = true
                self.timerColour = timerColourHeldCanStart
                self.feedbackStyle.impactOccurred()
                
                
            }
            taskAfterHold = newTaskAfterHold
            DispatchQueue.main.asyncAfter(deadline: .now() + userHoldTime, execute: newTaskAfterHold)
            
        }
        timerColour = timerColourHeld
    }
    
    func touchUp() {
        /// This is wayyyy more robust than using async task to set a var to true, but using async task is fine for the color
        if canStartTimer {
            NSLog("minimumTapDurationMet, starting timer.")
            start()
            canStartTimer = false
        }
        taskAfterHold?.cancel()
        
        timerColour = timerColourDefault
    }
}

public enum ButtonState {
    case pressed
    case notPressed
}

public struct Touch: ViewModifier {
    @GestureState private var isPressed = false
    let changeState: (ButtonState) -> Void
    public func body(content: Content) -> some View {
        let drag = DragGesture(minimumDistance: 0)
            .updating($isPressed) { (value, gestureState, transaction) in
                gestureState = true
            }
        
        return content
            .gesture(drag)
            .onChange(of: isPressed, perform: { (pressed) in
                        if pressed {
                            self.changeState(.pressed)
                        } else {
                            self.changeState(.notPressed)
                        }
                    })
    }
}



extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}





struct MainTimerView: View {
    @ObservedObject var stopWatchManager = StopWatchManager()

    
    //let bgColourGrey = Color(red: 242 / 255, green: 241 / 255, blue: 246 / 255)
    
    var values = SetValues()
    
    
    //let safeAreaBottomHeight = 34
    
    
    
    var body: some View {
        
        
        

        
        
        ZStack {
            Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                .ignoresSafeArea()
            
            
            
            VStack {
                Text("(0,2)/ (0,-3)/ (3,0)/ (-5,-5)/ (6,-3)/ (-1,-4)/ (1,0)/ (-3,0)/ (-1,0)/ (0,-2)/ (2,-3)/ (-4,0)/ (1,0)")
                    //.background(Color.red)
                    .padding(22)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .position(x: UIScreen.screenWidth / 2, y: 108)
                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                
                               
            }
            
            
            Text(String(format: "%.3f", stopWatchManager.secondsElapsed))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(stopWatchManager.timerColour)
            
            tabBar
                       
            GeometryReader { geometry in
                VStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.0000000001)) /// TODO: fix this don't just use this workaround: https://stackoverflow.com/questions/56819847/tap-action-not-working-when-color-is-clear-swiftui
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height - CGFloat(values.tabBarHeight) /* - CGFloat(safeAreaBottomHeight) */,
                            alignment: .center
                            //height: geometry.safeAreaInsets.top,
                            //height:  - safeAreaInset(edge: .bottom) - CGFloat(tabBarHeight),
                        )
                        .modifier(Touch(changeState: { (buttonState) in
                            
                            
                            if buttonState == .pressed { /// ON TOUCH DOWN EVENT
                                self.stopWatchManager.touchDown()
                            } else { /// ON TOUCH UP (FINGER RELEASE) EVENT
                                self.stopWatchManager.touchUp()
                            }
                        }))
                        //.safeAreaInset(edge: .bottom)
                        //.aspectRatio(contentMode: ContentMode.fit)
                }
            }
        }
    }
    
    var tabBar: some View {
        GeometryReader { geometry in
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red)
                
                    .frame(
                        width: geometry.size.width - CGFloat(values.marginLeftRight * 2),
                        height: CGFloat(values.tabBarHeight),
                        alignment: .center
                        //height: geometry.safeAreaInsets.top,
                        //height:  - safeAreaInset(edge: .bottom) - CGFloat(tabBarHeight),
                    )
                
                    .position(
                        x: geometry.size.width / 2 - CGFloat(values.marginLeftRight),
                        y: geometry.size.height - 0.5 * CGFloat(values.tabBarHeight)
                    )
                
                    /*
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 50)
                     */
                    .padding(.leading, CGFloat(values.marginLeftRight))
                    .padding(.trailing, CGFloat(values.marginLeftRight))
            }
        }
        .frame(alignment: .bottom)
    }
    
    
}


struct MainTimerView_Previews: PreviewProvider {
    static var previews: some View {
        MainTimerView()
    }
}

