import tadp.internal.TADPDrawingAdapter
import tadp.parsers.{Circulo, Figura, FiguraInvalidaException, Rectangulo, Triangulo, punto2D}

/*DIBUJAR FIGURA
-----------------------------------------------------------------------
 */
object dibujarFigura{
  def apply(unaFigura:Figura): TADPDrawingAdapter => TADPDrawingAdapter = unaFigura match {
    case Rectangulo(verticeSuperior,verticeInferior) =>  dibujarRectangulo (verticeInferior,verticeSuperior)
    case Triangulo(verticePrimero,verticeSegundo,verticeTercero) => dibujarTriangulo (verticePrimero,verticeSegundo,verticeTercero)
    case Circulo(centro,radio) => dibujarCirculo (centro,radio)
    case _ => throw new FiguraInvalidaException
  } //TODO: ver de agregar el adapter en la firma del apply
} // parece estar bien

object dibujarRectangulo {
  def apply(verticeSuperior: punto2D,verticeInferior: punto2D): TADPDrawingAdapter => TADPDrawingAdapter = {
    adapter => adapter.rectangle((verticeInferior.x,verticeSuperior.y),(verticeInferior.x,verticeInferior.y))
  }
}

object dibujarTriangulo {
  def apply(verticePrimero: punto2D,verticeSegundo: punto2D,verticeTercero: punto2D): TADPDrawingAdapter => TADPDrawingAdapter ={
    // val triangulo: TADPDrawingAdapter = new TADPDrawingAdapter().triangle()

    adapter => adapter.triangle((verticePrimero.x,verticePrimero.y),(verticeSegundo.x,verticeSegundo.y),(verticeTercero.x,verticeTercero.y))
  }
}

object dibujarCirculo {
  def apply(centro: punto2D,radio: Double): TADPDrawingAdapter => TADPDrawingAdapter ={
    adapter => adapter.circle((centro.x, centro.y), radio)
  }
}