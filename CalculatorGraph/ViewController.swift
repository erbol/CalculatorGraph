//
//  ViewController.swift
//  CalculatorGraph
//
//  Created by erbol on 24.04.15.
//  Copyright (c) 2015 erbol. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    

    

    let graph = CalculatorGraphic()
    var contentScaleFactor: CGFloat = 1
    let scale: CGFloat = 1.1
    let str = "200*cos(M*0.03)"
    var origin: CGPoint = CGPoint.zeroPoint
    //let rect = CGRectMake(0, 0, view.frame.maxX , view.frame.maxY)
    
    @IBAction func moveGraph(sender: UIButton) {
        //imageView.image = nil
        origin = CGPoint(x: origin.x - 150   , y: origin.y - 150  )

        draw(origin)
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("recognizePanGesture:"))
        view.addGestureRecognizer(panGesture)
        origin = CGPoint(x: view.frame.midX   , y: view.frame.midY  )
    
        draw(origin)
    }
    
    func draw(origin:CGPoint){
        
        //imageView.image = nil
        
        // Вычисляем функцию по точкам на оси Х внутри rect и рисуем график
        
        let rect = CGRectMake(0, 0, view.frame.maxX , view.frame.maxY)

        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()

        
        // Рисуем график
        drawGraphicFunction(rect,origin: origin,scale: scale, str: str,context: context)
        //drawGraphic1(rect,origin: origin,scale: scale, str: str,context: context)
        // Рисуем оси координат внутри rect
        drawAxes(rect, origin: origin, scale: scale, context : context)
        
        drawText(str)
        // Do any additional setup after loading the view, typically from a nib.
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    
    
    func drawGraphicFunction(rect: CGRect,origin : CGPoint, scale : CGFloat, str: String, context : CGContext){
        
        // Строим стек для расчета функции
        graph.parseString(str)
        // Для создания графика функции надо определить диапазоны отрицательных и положительных значений
        // Известны положения двух точек
        // original - точка отсчета рисуемых на view осей системы координат
        // rect.original - точка отсчета системы координат прямоугольника области построения графика
    
        
        
        CGContextSetLineWidth(context, 1.0)
        CGContextSetStrokeColorWithColor(context,
            UIColor.blueColor().CGColor)
        
        
        // расстояние по оси х от левой границы rect до точки начала координат рисуемых осей
        // В нашем случае rect.origin.x всегда равно нулю
        // Положение точки origin задается относительно rect.origin
        // Поэтому если origin находится левее rect.origin left будет положительным
        // и наоборот если origin находится правее rect.origin то left будет отрицательным
        let left:Int = Int((rect.minX - origin.x)/scale)
        //println(left)
        
        // расстояние по оси х от точки начала координат рисуемых осей до правой границы прямоугольника построения
        
        let right:Int = Int((rect.maxX - origin.x)/scale)
        
        // Рассчитываем функцию
        var data = graph.graphData(left,right: right)
        
        CGContextBeginPath(context)
        
        // Рисуем функцию
        while !data.isEmpty {
            let point = data.removeAtIndex(0)
            //println(point.x)
            //println(point.y)
            if (point.x == CGFloat(left)) {
                //----------------------------------------------
                CGContextMoveToPoint(context, point.x*scale+origin.x, -point.y*scale+origin.y)
            }
            else {
                CGContextAddLineToPoint(context, point.x*scale+origin.x, -point.y*scale+origin.y)
            }
        }
        
        CGContextStrokePath(context)
        //CGContextClosePath(context)
        
    }

    
    func drawText(str: String){
        let numberOne = "Y = " + str
        let numberOneRect = CGRectMake(imageView.bounds.minX + 30, imageView.bounds.minY + 700, 350, 50)
        let font = UIFont(name: "Academy Engraved LET", size: 24)
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle()
        let numberOneAttributes = [
            NSFontAttributeName: font!]
        numberOne.drawInRect(numberOneRect,
            withAttributes:numberOneAttributes)
    }
    
    func drawAxes(rect : CGRect, origin : CGPoint, scale: CGFloat, context : CGContext){
        let bounds = rect
        
        AxesDrawer(contentScaleFactor: contentScaleFactor)
            .drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale, context : context)
    }
    
    func recognizePanGesture(sender: UIPanGestureRecognizer)
    {
        var translate = sender.translationInView(self.view)
        if sender.state == UIGestureRecognizerState.Ended {
            // 1
            let velocity = sender.velocityInView(self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            //println("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            // 2
            let slideFactor = 0.1 * slideMultiplier     //Увеличьте для большего скольжения
            // 3
            var finalPoint = CGPoint(x:sender.view!.center.x + (velocity.x * slideFactor),
                y:sender.view!.center.y + (velocity.y * slideFactor))
            // 4
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
            
            self.origin.x  += translate.x
            self.origin.y += translate.y
            self.imageView.image = nil
            
            // 5
            UIView.animateWithDuration(Double(slideFactor * 2),
                delay: 0,
                
                // 6
                options: UIViewAnimationOptions.CurveEaseOut,
                
                animations: { self.draw(self.origin)},
                
                completion: nil)
        }
    }




}

