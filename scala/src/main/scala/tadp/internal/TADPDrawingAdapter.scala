package tadp.internal

import Operations._
import scalafx.scene.canvas._
import scalafx.scene.paint._

case class TADPDrawingAdapter(canvas: Canvas, appliedOperations: List[RevertOperation] = List()) {

  type Point2D = (Double, Double)

  private def context = canvas.graphicsContext2D

  private def pushOperation(operation: StackableOperation) =
    copy(appliedOperations = operation.apply(context) :: this.appliedOperations)


  private def popOperation() = {
    if (appliedOperations.isEmpty) throw new RuntimeException("Error! No hay operaciones para finalizar. ¿Has llamado a un end sin haber llamado un begin?")
    val head :: rest = appliedOperations

    head.apply()
    copy(appliedOperations = rest)
  }


  private def draw(drawOperation: => Any) = {
    drawOperation
    this
  }

  def circle(center: Point2D, radius: Double) = draw {
    val diameter = radius * 2
    context.fillOval(center._1 - radius, center._2 - radius, diameter, diameter)
  }

  def rectangle(topLeft: Point2D, bottomRight: (Double, Double)) = draw {
    context.fillRect(topLeft._1, topLeft._2, bottomRight._1 - topLeft._1, bottomRight._2 - topLeft._2)
  }

  def triangle(p1: Point2D, p2: Point2D, p3: Point2D) = draw {
    canvas.graphicsContext2D.fillPolygon(Seq(p1, p2, p3))
  }

  def beginTranslate(x: Double, y: Double) = pushOperation(translate(x, y))

  def beginScale(x: Double, y: Double) = pushOperation(scale(x, y))

  def beginScale(ratio: Double) = pushOperation(scale(ratio, ratio))

  def beginRotate(degrees: Double) = pushOperation(rotate(degrees))

  def beginColor(color: Color) = pushOperation(paint(color))

  def end() = popOperation()
}


object Operations {

  type RevertOperation = () => ()

  // Una operación es una función que se aplica sobre un contexto,
  // y me devuelve la función que tengo que llamar para revertirla
  type StackableOperation = GraphicsContext => RevertOperation

  def transformOperation(transformation: GraphicsContext => Unit): StackableOperation = context => {
    val previousTransform = context.getTransform
    transformation.apply(context)
    () => context.setTransform(previousTransform)
  }

  def translate(x: Double, y: Double): StackableOperation = transformOperation(_.translate(x, y))

  def rotate(degrees: Double): StackableOperation = transformOperation(_.rotate(degrees))

  def scale(x: Double, y: Double): StackableOperation = transformOperation(_.scale(x, y))

  def paint(paint: Paint): StackableOperation = context => {
    val previousPaint = context.getFill
    context.setFill(paint)
    () => context.setFill(previousPaint)
  }
}

object TADPDrawingAdapter {
  def forScreen(instructions: TADPDrawingAdapter => Any): Unit = {
    val screenApp = new TADPDrawingScreen(instructions)
    screenApp.main(Array())
  }

  def forImage(name: String)(instructions: TADPDrawingAdapter => Any): Unit = {
    val screenApp = new TADPDrawingScreen(instructions, Some(name))
    screenApp.main(Array())
  }

  def forInteractiveScreen(interpreter: (String, TADPDrawingAdapter) => Any): Unit = {
    val screenApp = new TADPInteractiveDrawingScreen(interpreter)
    screenApp.main(Array())
  }
}