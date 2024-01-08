//
//  ScrollableLineChart.swift
//  CubeTime
//
//  Created by Tim Xie on 2/03/23.
//
import UIKit
import SwiftUI

class HighlightedPoint: UIView {
    override func draw(_ rect: CGRect) {
        var path = UIBezierPath()
        path = UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: 8, height: 8))
        UIColor(Color("accent")).setStroke()
        UIColor(Color("overlay0")).setFill()
        path.lineWidth = 4
        path.stroke()
        path.fill()
    }
}


private let dotDiameter: CGFloat = 6

struct LineChartPoint {
    var point: CGPoint
    var solve: Solve
    
    init(solve: Solve, position: Double, min: Double, max: Double, boundsHeight: CGFloat) {
        self.solve = solve
        self.point = CGPoint()
        self.point.y = getStandardisedYLocation(value: solve.timeIncPen, min: min, max: max, boundsHeight: boundsHeight)
        self.point.x = position
    }
    
    func pointIn(_ other: CGPoint) -> Bool {
        let rect = CGRect(x: point.x - dotDiameter / 2, y: point.y - dotDiameter / 2, width: dotDiameter, height: dotDiameter)
        return rect.contains(other)
    }
}

func getStandardisedYLocation(value: Double, min: Double, max: Double, boundsHeight: CGFloat) -> CGFloat {
    return boundsHeight - (((value - min) / (max - min)) * boundsHeight)
}

extension CGPoint {
    static func midPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x:(p1.x + p2.x) / 2,y: (p1.y + p2.y) / 2)
    }
    
    static func controlPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
        var controlPoint = CGPoint.midPointForPoints(p1: p1, p2: p2)
        
        let diffY = abs(p2.y - controlPoint.y)
        
        if (p1.y < p2.y){
            controlPoint.y += diffY
        } else if (p1.y > p2.y) {
            controlPoint.y -= diffY
        }
        
        return controlPoint
    }
}

class TimeDistributionPointView: UIStackView {
    let size = CGSize(width: 144, height: 44)
    let solve: Solve
    
    var iconView: UIImageView!
    var infoStack: UIStackView!
    var chevron: UIImageView!
    
    init(origin: CGPoint, solve: Solve) {
        self.solve = solve
        
        super.init(frame: CGRect(origin: origin, size: size))
        
        self.setupCard()
        self.setupIconView()
        self.setupLabelView()
        self.setupChevron()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.iconView.translatesAutoresizingMaskIntoConstraints = false
        self.infoStack.translatesAutoresizingMaskIntoConstraints = false
        self.chevron.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.addArrangedSubview(self.iconView)
        self.addArrangedSubview(self.infoStack)
        self.addArrangedSubview(self.chevron)
        
        self.distribution = .fill
        self.alignment = .center
        self.spacing = 10
        
        self.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.isLayoutMarginsRelativeArrangement = true
        
        self.setCustomSpacing(16, after: self.infoStack)


        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 44),
            
            self.iconView.widthAnchor.constraint(equalToConstant: 24),
            self.iconView.heightAnchor.constraint(equalTo: self.iconView.widthAnchor),
        ])
    }
    
    required init(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    private func setupCard() {
        self.layer.cornerRadius = 6
        self.layer.cornerCurve = .continuous
        self.backgroundColor = UIColor(Color("overlay0"))
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.04
        self.layer.shadowRadius = 6
        self.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
    }
    
    private func setupIconView() {
        self.iconView = UIImageView(image: UIImage(named: puzzleTypes[Int(solve.scrambleType)].name))
        self.iconView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        self.iconView.tintColor = .black
    }
    
    private func setupLabelView() {
        self.infoStack = UIStackView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        self.infoStack.axis = .vertical
        self.infoStack.alignment = .leading
        self.infoStack.distribution = .fill
        self.infoStack.spacing = -2
        
        var timeLabel = UILabel()
        var dateLabel = UILabel()
        
        timeLabel.text = self.solve.timeText
        timeLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        timeLabel.adjustsFontForContentSizeCategory = true
        
        if let date = self.solve.date {
            dateLabel.text = getSolveDateFormatter(date).string(from: date)
        } else {
            dateLabel.text = "Unknown Date"
        }
        
        dateLabel.font = .preferredFont(forTextStyle: .footnote)
        dateLabel.textColor = UIColor(Color("grey"))
        dateLabel.adjustsFontForContentSizeCategory = true
        
        self.infoStack.addArrangedSubview(timeLabel)
        self.infoStack.addArrangedSubview(dateLabel)
    }
    
    private func setupChevron() {
        self.chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        self.chevron.tintColor = UIColor.black
        
        self.chevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .preferredFont(for: .footnote, weight: .medium))

    }
}



class TimeDistViewController: UIViewController {
    let points: [LineChartPoint]
    let gapDelta: Int
    let averageValue: Double
    
    let limits: (min: Double, max: Double)
    
    var interval: Int
    
    var hightlightedPoint: HighlightedPoint!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    let imageHeight: CGFloat = 300
    
    // let crossView: CGPath!  // TODO: the crosses for DNFs that is drawn (copy)
    
    private let dotSize: CGFloat = 6
    
    init(points: [LineChartPoint], gapDelta: Int, averageValue: Double, limits: (min: Double, max: Double), interval: Int) {
        self.points = points
        self.gapDelta = gapDelta
        self.averageValue = averageValue
        self.limits = limits
        self.interval = interval
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.scrollView = UIScrollView()
        self.scrollView.showsHorizontalScrollIndicator = true
        
        
        let imageSize = CGSize(width: CGFloat(points.count * gapDelta),
                               height: imageHeight)
        
        /// draw line
        let trendLine = UIBezierPath()
        let bottomLine = UIBezierPath()
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        
        /// bottom line
        bottomLine.move(to: CGPoint(x: 0, y: imageHeight))
        bottomLine.lineWidth = 2
        bottomLine.addLine(to: CGPoint(x: CGFloat((points.count - 1) * self.interval), y: imageHeight))
        context.setStrokeColor(UIColor(Color("indent0")).cgColor)
        bottomLine.stroke()
        
        /// graph line
        context.setStrokeColor(UIColor(Color("accent")).cgColor)
        
        for i in 0 ..< points.count {
            let prev = points[i - 1 >= 0 ? i - 1 : 0]
            let cur = points[i]
            
            if (trendLine.isEmpty) {
                trendLine.move(to: CGPointMake(dotSize/2, cur.point.y))
                continue
            }
                
            let mid = CGPoint.midPointForPoints(p1: prev.point, p2: cur.point)
            
            trendLine.addQuadCurve(to: mid,
                                   controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: prev.point))
            
            trendLine.addQuadCurve(to: cur.point,
                                   controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: cur.point))
        }
        
        trendLine.lineWidth = 2
        trendLine.lineCapStyle = .round
        trendLine.lineJoinStyle = .round
        
        let beforeLine = trendLine.copy() as! UIBezierPath
        
        trendLine.addLine(to: CGPoint(x: points.last!.point.x, y: imageHeight))
        trendLine.addLine(to: CGPoint(x: 0, y: imageHeight))
        trendLine.addLine(to: CGPoint(x: 0, y: points.first!.point.y))
        
        trendLine.close()
        
        trendLine.addClip()
        
        context.drawLinearGradient(CGGradient(colorsSpace: .none,
                                              colors: [
                                                UIColor(staticGradient[0].opacity(0.6)).cgColor,
                                                UIColor(staticGradient[1].opacity(0.2)).cgColor,
                                                UIColor.clear.cgColor
                                              ] as CFArray,
                                              locations: [0.0, 0.4, 1.0])!,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: 0, y: imageHeight),
                                   options: [] )
        
        context.resetClip()
        
        beforeLine.stroke()
        
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        self.view.clipsToBounds = true
        
        imageView = UIImageView(image: newImage)
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(imageView)
        scrollView.frame = view.frame
        scrollView.contentSize = newImage.size
        
        scrollView.isUserInteractionEnabled = true
        
        scrollView.layer.borderWidth = 2
        scrollView.layer.borderColor = UIColor.blue.cgColor
        
        self.imageView.layer.borderWidth = 2
        self.imageView.layer.borderColor = UIColor.black.cgColor
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(panning))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        
        scrollView.addGestureRecognizer(longPressGestureRecognizer)
        
        self.hightlightedPoint = HighlightedPoint(frame: CGRect(x: 10, y: 10, width: 12, height: 12))
        
        self.hightlightedPoint.backgroundColor = .clear
        self.hightlightedPoint.frame = CGRect(x: self.points[1].point.x - 6,
                                              y: self.points[1].point.y - 6,
                                              width: 12, height: 12)
        scrollView.addSubview(self.hightlightedPoint)
        
        
        self.scrollView.addSubview(TimeDistributionPointView(origin: CGPoint(x: 0, y: 0), solve: self.points.first!.solve))
    }
    
    @objc func panning(_ pgr: UILongPressGestureRecognizer) {
        if (pgr.state == .ended) {
            self.hightlightedPoint.isHidden = true
            return
        }
        
        self.hightlightedPoint.isHidden = false
        let closestIndex = Int((pgr.location(in: self.scrollView).x + 6) / CGFloat(interval))
        let closestPoint = self.points[closestIndex]
        
        self.hightlightedPoint.frame = CGRect(x: closestPoint.point.x - 6,
                                              y: closestPoint.point.y - 6,
                                              width: 12, height: 12)
    }
}


struct DetailTimeTrendBase: UIViewControllerRepresentable {
    typealias UIViewControllerType = TimeDistViewController
    
    @Binding var interval: Int
    
    let points: [LineChartPoint]
    let gapDelta: Int
    let averageValue: Double
    let proxy: GeometryProxy
    
    let limits: (min: Double, max: Double)
    
    init(rawDataPoints: [Solve], limits: (min: Double, max: Double), averageValue: Double, gapDelta: Int = 30, proxy: GeometryProxy, interval: Binding<Int>) {
        self.points = rawDataPoints.enumerated().map({ (i, e) in
            return LineChartPoint(solve: e, position: Double(i * interval.wrappedValue), min: limits.min, max: limits.max, boundsHeight: 300)
        })
        self.averageValue = averageValue
        self.limits = limits
        self.gapDelta = gapDelta
        self.proxy = proxy
        self._interval = interval
        
        print("detail time trend reinit with \(interval)")
    }
    
    func makeUIViewController(context: Context) -> TimeDistViewController {
        let timeDistViewController = TimeDistViewController(points: points, gapDelta: gapDelta, averageValue: averageValue, limits: limits, interval: interval)
        print(proxy.size.width, proxy.size.height)
        timeDistViewController.view.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
        timeDistViewController.scrollView.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
        
        return timeDistViewController
    }
    
    func updateUIViewController(_ uiViewController: TimeDistViewController, context: Context) {
        uiViewController.view?.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
        
        print("vc updated")
    }
}
