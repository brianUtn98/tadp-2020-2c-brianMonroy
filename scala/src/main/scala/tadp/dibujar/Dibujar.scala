package tadp.dibujar

import tadp.internal.TADPDrawingAdapter
import tadp.parsers.{Circulo, Color, Escala, Figura, FiguraInvalidaException, FiguraTransformada, Grupo, Rectangulo, Rotacion, Traslacion, Triangulo, parserFigura}

object dibujarFigura {
  def apply(unaFigura:Figura,adapter:TADPDrawingAdapter):TADPDrawingAdapter = unaFigura match {
    case Rectangulo(verticeSuperior,verticeInferior) => dibujarRectangulo(Rectangulo(verticeSuperior, verticeInferior),adapter)
    case Triangulo(verticePrimero,verticeSegundo,verticeTercero) => dibujarTriangulo(Triangulo(verticePrimero,verticeSegundo,verticeTercero),adapter)
    case Circulo(centro,radio) => dibujarCirculo(Circulo(centro,radio),adapter)
    case Grupo(elementos) => dibujarGrupo(Grupo(elementos),adapter)
    case FiguraTransformada(figura,Traslacion(x,y)) => dibujarFigura(figura,adapter.beginTranslate(x,y)).end()
    case FiguraTransformada(figura,Rotacion(grados)) => dibujarFigura(figura,adapter.beginRotate(grados)).end()
    case FiguraTransformada(figura,Escala(x,y)) => dibujarFigura(figura,adapter.beginScale(x,y)).end()
    case FiguraTransformada(figura,Color(r,g,b)) => dibujarFigura(figura,adapter.beginColor(scalafx.scene.paint.Color.rgb(r,g,b))).end()
    case _ => throw new FiguraInvalidaException
  }
}

object dibujarRectangulo {
  def apply(rectangulo:Rectangulo,adapter:TADPDrawingAdapter): TADPDrawingAdapter = {
    val verticeSuperior = rectangulo.verticeSuperior
    val verticeInferior = rectangulo.verticeInferior
    adapter.rectangle((verticeSuperior.x,verticeSuperior.y),(verticeInferior.x,verticeInferior.y))
  }
}

object dibujarTriangulo {
  def apply(triangulo: Triangulo,adapter:TADPDrawingAdapter): TADPDrawingAdapter = {
    val verticePrimero = triangulo.verticePrimero
    val verticeSegundo = triangulo.verticeSegundo
    val verticeTercero = triangulo.verticeTercero
    adapter.triangle((verticePrimero.x,verticePrimero.y),(verticeSegundo.x,verticeSegundo.y),(verticeTercero.x,verticeTercero.y))
  }
}

object dibujarCirculo{
  def apply(circulo: Circulo, adapter: TADPDrawingAdapter): TADPDrawingAdapter = {
    val centro = circulo.centro
    val radio = circulo.radio
    adapter.circle((centro.x,centro.y),radio)
  }
}

object dibujarGrupo{
  def apply(grupo:Grupo,adapter:TADPDrawingAdapter): TADPDrawingAdapter = {
    grupo.elementos.foldLeft(adapter) {(unAdapter,unaFigura) => dibujarFigura(unaFigura,unAdapter)}
  }
}

object dibujarEnPantalla{
  def apply(unString:String): Unit = {
    val figuraParseada = parserFigura(unString).get.elementoParseado
    TADPDrawingAdapter.forScreen({adapter => dibujarFigura(figuraParseada,adapter)})
  }
}

object dibujarImagen{
  def apply(unString:String,ruta:String): Unit ={
    val figuraParseada = parserFigura(unString).get.elementoParseado
    TADPDrawingAdapter.forImage(ruta)({adapter => dibujarFigura(figuraParseada,adapter)})
  }
}