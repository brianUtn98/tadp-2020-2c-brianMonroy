package tadp.parsers
import scala.util.{Failure, Success, Try}
import tadp.internal.TADPDrawingAdapter

abstract class Parser[T] {
  def apply(entrada:String): Try[ResultadoParser[T]]

  def <|> (otroParser:Parser[T]):Parser[T]={
    (new <|>).combinar(this,otroParser)
  }

  def <>[K] (otroParser:Parser[K]):Parser[(T,K)]= {
    (new <>).combinar(this,otroParser)
  }

  def ~>[K] (otroParser:Parser[K]):Parser[K] = {
    (new ~>).combinar(this,otroParser)
  }

  def <~[K] (otroParser:Parser[K]):Parser[T] = {
    (new <~).combinar(this,otroParser)
  }

  def sepByn[K] (otroParser:Parser[K],cantidad:Int):Parser[List[T]] = {
    (new sepByn).combinar(this,otroParser,cantidad)
  }

  def sepBy[K] (otroParser:Parser[K]):Parser[List[T]] = {
    (new sepBy).combinar(this,otroParser)
  }



  def * ():Parser[List[T]] = {
    val yo = this
    new Parser[List[T]] {
      override def apply(entrada: String): Try[ResultadoParser[List[T]]] = {
        Try {
          armameLaLista(yo,entrada)
        }

      }
      def armameLaLista[K](parser:Parser[T],entrada:String): ResultadoParser[List[T]] ={
        val resultado = parser.apply(entrada) match {
          case Success(ResultadoParser(parseado,sobranteAParsear)) =>
            val ResultadoParser(parseadoNuevo,sobranteNuevo) = armameLaLista(parser, sobranteAParsear)
            (parseado:: parseadoNuevo,sobranteNuevo)
          case Failure(_) => (List(),entrada)
        }
        ResultadoParser(resultado._1,resultado._2)
      }
    }
  }

  def +(): Parser[List[T]] = {
    val yo= this
    new Parser[List[T]] {
      override def apply(entrada: String): Try[ResultadoParser[List[T]]] = {
        yo.*().satisfies(this.noEstaVacio).apply(entrada)


      }
      def noEstaVacio(entrada: List[T]): Boolean ={
        entrada.nonEmpty
      }
    }

  }


  def map[S](funcion: T=>S):Parser[S] ={
    val yo= this
    new Parser[S] {
      override def apply(entrada: String): Try[ResultadoParser[S]] = {
        Try {
          yo.apply(entrada) match {
            case Success(ResultadoParser(elementoParseado,loQueSobra)) => ResultadoParser(funcion(elementoParseado),loQueSobra)
            case Failure(fail) => throw fail
          }
        }
      }
    }
  }

  def satisfies(funcion: T=>Boolean):Parser[T] ={
    val yo=this
    new Parser[T] {
      override def apply(entrada: String): Try[ResultadoParser[T]] = {
        yo.apply(entrada) match {
          case Success(ResultadoParser(elementoParseado,loQueSobra)) if funcion(elementoParseado) => Success(ResultadoParser(elementoParseado,loQueSobra))
          case Success(_) => Failure(new SatisfiesException)
          case Failure(fallo) => Failure(fallo)
        }
      }
    }
  }

  def opt():Parser[Option[T]] = {
    val yo=this
    new Parser[Option[T]] {
      override def apply(entrada: String): Try[ResultadoParser[Option[T]]] = {
        yo.apply(entrada) match {
          case Success(ResultadoParser(parseado,loQueSobra)) => Success(ResultadoParser(Some(parseado),loQueSobra))
          case Failure(_) => Success(ResultadoParser(None,entrada))
        }
      }
    }
  }
}

object limpiadorDeString {
  def apply (unString:String):String = {
    unString.filter(_ > ' ')
  }
}


case object AnyChar extends Parser[Char] {
  def apply(unString: String): Try[ResultadoParser[Char]] = unString.toList match {
    case List() => Failure (new StringVacioException)
    case head :: tail => Success (ResultadoParser(head,tail.mkString("")))
  }
}

case object IsDigit extends Parser[Char] {
  def apply(entrada:String): Try[ResultadoParser[Char]] =
      AnyChar.satisfies(x => x.isDigit)(entrada)

}

case class char(inicio: Char) extends Parser[Char]{
  def apply(unString: String): Try[ResultadoParser[Char]] = AnyChar.apply(unString) match {
    case Failure(_) =>  Failure(new StringVacioException)
    case Success(ResultadoParser(unChar,_)) if unChar!= inicio => Failure(new CharException)
    case Success(ResultadoParser(unChar,resto)) if unChar == inicio => Success(ResultadoParser(inicio,resto))
  }
}

case class string(inicio: String) extends Parser[String]{
  def apply(stringOriginal: String): Try[ResultadoParser[String]] =
    if(stringOriginal.startsWith(inicio)) Success(ResultadoParser[String](inicio,stringOriginal.slice(inicio.length(),stringOriginal.length()))) else Failure(new StringException)
}

case class parserStringNoObligatorio(elSigno: String) extends Parser[String]{
  def apply(inicio: String): Try[ResultadoParser[String]] = {
    string(elSigno)(inicio) match {
      case Success(elem) => Success(elem)
      case Failure(_) => string("")(inicio)
    }
  }
}

case object parserNumero extends Parser[String]{
  def apply(numero: String): Try[ResultadoParser[String]] = {
    IsDigit.+().map(lista => lista.mkString("")).apply(numero)

  }
}

case object integer extends Parser[Int]{
  def apply(entero:String): Try[ResultadoParser[Int]]={
       (parserStringNoObligatorio("-") <> parserNumero).map(tupla => (tupla._1 + tupla._2).toInt).apply(entero)

  }

}
case object double extends Parser[Double]{
  def apply(unDouble:String): Try[ResultadoParser[Double]]= {
    (((parserStringNoObligatorio("-") <> parserNumero) <> parserStringNoObligatorio(".")) <> parserNumero).map({case (((menos,parteEntera),punto),parteFrac) =>
      (menos+parteEntera + punto + parteFrac).toDouble})(unDouble)
  }

} //TODO el ultimo parser numero deberia ser opcional.



class <|>[T] {
  def combinar(unParser:Parser[T],otroParser:Parser[T]): Parser[T] ={
    new Parser[T]{
      def apply(input:String):Try[ResultadoParser[T]]={
        unParser.apply(input) match {
          case Success(ResultadoParser(head,tail)) => Success(ResultadoParser(head,tail))
          case Failure(_) => otroParser.apply(input)
        }
      }
    }
  }

}



class <>[T,S]{
  def combinar(unParser:Parser[T],otroParser:Parser[S]): Parser[(T,S)] ={
    new Parser[(T,S)] {
      override def apply(entrada: String): Try[ResultadoParser[(T,S)]] = {
        unParser.apply(entrada) match {
          case Success(ResultadoParser(resultado1,loQueSobra)) => otroParser.apply(loQueSobra) match {
            case Success(ResultadoParser(resultado2,loQueSobra)) =>
              Success(ResultadoParser((resultado1,resultado2),loQueSobra))
            case Failure(_) => Failure(new ConcatException)
          }
          case Failure(_) => Failure(new ConcatException)
        }
      }
    }
  }
}

class ~>[T,S]{
  def combinar(unParser:Parser[T],otroParser:Parser[S]):Parser[S] ={
    new Parser[S] {
      override def apply(entrada:String): Try[ResultadoParser[S]] = {
        (unParser <> otroParser).map(elem => elem._2) (entrada)
      }
    }
  }
}

class <~[T,S]{
  def combinar(unParser:Parser[T],otroParser:Parser[S]):Parser[T] = {
    new Parser[T] {
      override def apply(entrada: String): Try[ResultadoParser[T]] = {
        (unParser <> otroParser).map(elem => elem._1) (entrada)
      }
    }
  }
}



class sepBy[T,S]{
  def combinar(parserDeContenido:Parser[T],parserSeparador:Parser[S]): Parser[List[T]] ={
    new Parser[List[T]] {
      override def apply(entrada:String): Try[ResultadoParser[List[T]]] = {
        (parserDeContenido <> (parserSeparador ~> parserDeContenido).*()).map(tuplaConListaALista)(entrada)

      }
      def tuplaConListaALista (tupla:(T,List[T])):List[T] ={
        tupla._1 :: tupla._2
      }

      }
  }
}

class sepByn[T,S] {
  def combinar (parserDeContenido:Parser[T],parserSeparador:Parser[S], cantidadDeVeces: Int): Parser[List[T]] ={
    new Parser[List[T]] {
      override def apply(entrada: String): Try[ResultadoParser[List[T]]] = {
        (new sepBy).combinar(parserDeContenido,parserSeparador).satisfies(x => x.length == cantidadDeVeces)(entrada)
      }
    }
  }
}




case class parserPuntos(cantidad:Int) extends Parser[List[punto2D]] {
  def apply(unString:String): Try[ResultadoParser[List[punto2D]]] = {
    (char('[') ~> parsearPuntos <~ char(']')).map(x => listaDeListaDeIntAListaDeTupla(x))(unString)
  }

  def parsearPuntos: Parser[List[List[Int]]] = {
    integer.sepBy(string("@")).sepByn(string(","), cantidad)
  }

  def listaDeListaDeIntAListaDeTupla(dobleLista : List[List[Int]]): List[punto2D] = {
    dobleLista.map({case List(puntoA,puntoB) => punto2D(puntoA,puntoB)})
  }

}

case object parserRectangulo extends Parser[Figura] {
  def apply(unString:String): Try[ResultadoParser[Figura]] ={
    val funcion: List[punto2D] => Figura = {case List(supIzq,infDer) =>Rectangulo(supIzq,infDer) }
      (string("rectangulo")  ~> parserPuntos(2)).map(funcion) (unString)
  }
}

case object parserTriangulo extends Parser[Figura] {
    def apply(unString:String): Try[ResultadoParser[Figura]] ={
      val funcion: List[punto2D] => Figura = {case List(a,b,c) =>Triangulo(a,b,c) }
      (string("triangulo") ~> parserPuntos(3)).map(funcion) (unString)
    }
}


case object parserCirculo extends Parser[Figura]{
  def apply (unString:String):Try[ResultadoParser[Figura]] ={
      val dobleListaACirculo: List[List[Int]] => Figura ={ case List(List(x,y),List(r)) => Circulo(punto2D(x,y),r)}
      ((string("circulo[") ~> parserPuntos(2).parsearPuntos) <~ char(']')).map(dobleListaACirculo)(unString)
  }
}




case object parserGrupo extends Parser[Figura] {
  def apply(unString:String):Try[ResultadoParser[Figura]] = {
    val funcion: List[Figura] => Figura = {laLista => Grupo(laLista)}
    ((string("grupo(") ~> parserFigura.sepBy(char(','))) <~ char(')')).map(funcion) (unString)

  }
}

case object parserFigura extends Parser[Figura] {
  def apply(unString:String):Try[ResultadoParser[Figura]] = {
    (parsearFiguras <|> parserGrupo <|> parsearTransformaciones) (limpiadorDeString(unString))
  }
  private def parsearFiguras = {
    parserCirculo <|> parserRectangulo <|> parserTriangulo
  }
  private def parsearTransformaciones = {
    parserColor <|> parserEscala <|> parserRotacion <|> parserTraslacion
  }
}

case class parserTransformacion(cantidad:Int, nombre:String, funcion:((List[Double], Figura)) => Figura) extends Parser[Figura] {
  def apply(unString :String): Try[ResultadoParser[Figura]] = {
    (((string(nombre) ~> char('[')) ~> double.sepByn(char(','),cantidad)  <~ string("](")) <> (parserFigura <~ char(')'))).map(funcion) (unString)
  }
}

case object parserColor extends Parser[Figura] {
  def apply(unString:String): Try[ResultadoParser[Figura]] = {
    val funcion: ((List[Double], Figura)) => Figura = {case (List(r,g,b),figura) => FiguraTransformada(figura,Color(check.checkColor(r.toInt),check.checkColor(g.toInt),check.checkColor(b.toInt)))}
    parserTransformacion(3,"color",funcion) (unString)
  }
}

case object parserEscala extends Parser[Figura] {
  def apply(unString:String): Try[ResultadoParser[Figura]] = {
    val funcion: ((List[Double], Figura)) => Figura = {case (List(x,y),figura) => FiguraTransformada(figura,Escala(x,y))}
    parserTransformacion(2,"escala",funcion) (unString)
  }
}

case object parserRotacion extends Parser[Figura] {
  def apply(unString:String): Try[ResultadoParser[Figura]] = {
    val funcion: ((List[Double], Figura)) => Figura = {case (List(angulo),figura) => FiguraTransformada(figura,Rotacion(check.setGrados(angulo.toInt)))}
    parserTransformacion(1,"rotacion",funcion) (unString)
  }
}

case object parserTraslacion extends Parser[Figura] {
  def apply(unString:String): Try[ResultadoParser[Figura]] = {
    val funcion: ((List[Double], Figura)) => Figura = {case (List(x,y),figura) => FiguraTransformada(figura,Traslacion(x,y))}
    parserTransformacion(2,"traslacion",funcion) (unString)
  }
}
case object simplificador {
  def apply(unaFigura: Figura): Figura = {
    var simplificacionAnterior = simplificacion(unaFigura)
    var simplificacionNueva = simplificacion(simplificacionAnterior)
    while(simplificacionNueva != simplificacionAnterior){
      simplificacionAnterior = simplificacionNueva
      simplificacionNueva = simplificacion(simplificacionAnterior)
    }
    simplificacionNueva


    //simplificacion(simplificacion(unaFigura))<
  } //TODO tratar de hacerlo sin while


  def simplificacion(unaFigura: Figura): Figura = {
    val funcion: Figura => Figura = {case FiguraTransformada(elemento,_) => elemento}
    val funcionParcial: PartialFunction[Figura,FiguraTransformada] = {case FiguraTransformada(figura,transformacion) => FiguraTransformada(figura,transformacion)}
    unaFigura match {
      case FiguraTransformada(FiguraTransformada(figura,Color(r1,g1,b1)),Color(_,_,_)) => simplificador(FiguraTransformada(figura,Color(r1,g1,b1)))
      case Grupo(lista) if lista.forall(elem => elem match {
        case FiguraTransformada(_, transformacion) if transformacion == lista.collect(funcionParcial).head.transformacion  => true
        case _ => false
      }) => FiguraTransformada(Grupo(lista.map(funcion)),lista.collect(funcionParcial).head.transformacion)
      case FiguraTransformada(FiguraTransformada(figura,Rotacion(grados1)),Rotacion(grados2)) => simplificador(FiguraTransformada(figura,Rotacion(check.setGrados(grados1+grados2))))
      case FiguraTransformada(FiguraTransformada(figura, Escala(x1,y1)),Escala(x2,y2)) => simplificador(FiguraTransformada(figura,Escala(x1*x2,y1*y2)))
      case FiguraTransformada(FiguraTransformada(figura,Traslacion(x1,y1)),Traslacion(x2,y2)) => simplificador(FiguraTransformada(figura,Traslacion(x1+x2,y1+y2)))
      case FiguraTransformada(figura,Rotacion(0) |Escala(1.0, 1.0) | Traslacion(0,0)) => simplificador(figura)
      case FiguraTransformada(figura, transformacion) => FiguraTransformada(simplificador(figura),transformacion)
      case Grupo(elementos) => Grupo(elementos.map(unaFigura => simplificador(unaFigura)))
      case figura => figura
    }
  }
}

trait Figura
trait Transformacion
case class Triangulo(verticePrimero: punto2D, verticeSegundo: punto2D, verticeTercero: punto2D) extends Figura
case class Rectangulo(verticeSuperior: punto2D,verticeInferior: punto2D) extends Figura
case class Circulo(centro: punto2D,radio : Double) extends Figura
case class Grupo(elementos: List[Figura]) extends Figura
case class FiguraTransformada(elemento: Figura,transformacion: Transformacion ) extends Figura

case class ResultadoParser[T](elementoParseado: T, loQueSobra: String)
case class punto2D (x:Double, y:Double)

case class Color(R:Int,G:Int,B:Int) extends Transformacion
case class Escala(x:Double,y:Double) extends Transformacion
case class Traslacion(x:Double,y:Double) extends Transformacion
case class Rotacion(grados:Int) extends Transformacion

case object check{
  def setGrados(unosGrados:Int): Int = {
    unosGrados % 360
  }

  def checkColor(unColor:Int): Int ={
    if(unColor <=255 && unColor>=0) {
      unColor
    } else {
      throw new ColorInvalidoException
    }
  }
}
//TODO hacer que los parser puedanusar for comprehension (ya implementamos map), tenemos que convertir Parser en una mónada
//TODO implementar flatMap

//[[1,2,3],[2,3,5]].flatMap({a => a+1})
//[1,2,3,2,3,5].map({a => a+1})

