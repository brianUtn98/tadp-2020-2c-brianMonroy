package tadp
import tadp.parsers
import scalafx.scene.paint.Color
import tadp.internal.TADPDrawingAdapter
import tadp.parsers.{Grupo, parserEscala, parserFigura, parserGrupo, parserRectangulo, parserTraslacion, parserTriangulo}
import tadp.dibujar.{dibujarEnPantalla, dibujarFigura, dibujarImagen}


object TADPDrawingApp extends App {

  val unString ="color[100.0, 100.0, 100.0](\n  grupo(\n    color[0.0, 0.0, 0.0](\n      grupo(\n        color[201.0, 176.0, 55.0](\n          triangulo[0 @ 0, 650 @ 0, 0 @ 750]\n        ),\n        color[215.0, 215.0, 215.0](\n          triangulo[650 @ 750, 650 @ 0, 0 @ 750]\n        ),\n        color[255.0, 255.0, 255.0](\n          grupo(\n            rectangulo[230 @ 150, 350 @ 180],\n            rectangulo[110 @ 150, 470 @ 390]\n          )\n        ),\n        color[255.0, 0.0, 0.0](\n          grupo(\n            rectangulo[170 @ 60, 410 @ 150],\n            rectangulo[350 @ 60, 380 @ 180],\n            rectangulo[200 @ 60, 230 @ 180],\n            rectangulo[260 @ 300, 320 @ 330],\n            rectangulo[170 @ 390, 410 @ 480]\n          )\n        ),\n        rectangulo[200 @ 180, 380 @ 210],\n        rectangulo[230 @ 240, 260 @ 300],\n        rectangulo[320 @ 240, 350 @ 300],\n        rectangulo[200 @ 30, 380 @ 60],\n        rectangulo[170 @ 60, 200 @ 90],\n        rectangulo[380 @ 60, 410 @ 90],\n        rectangulo[140 @ 90, 170 @ 150],\n        rectangulo[410 @ 90, 440 @ 150],\n        rectangulo[110 @ 150, 200 @ 180],\n        rectangulo[110 @ 180, 170 @ 210],\n        rectangulo[140 @ 210, 170 @ 240],\n        rectangulo[80 @ 210, 110 @ 270],\n        rectangulo[110 @ 270, 170 @ 330],\n        rectangulo[110 @ 300, 200 @ 330],\n        rectangulo[80 @ 330, 110 @ 390],\n        rectangulo[110 @ 390, 200 @ 420],\n        rectangulo[140 @ 420, 170 @ 480],\n        rectangulo[200 @ 420, 260 @ 450],\n        rectangulo[320 @ 420, 380 @ 450],\n        rectangulo[260 @ 390, 320 @ 420],\n        rectangulo[170 @ 330, 410 @ 390],\n        rectangulo[170 @ 480, 260 @ 510],\n        rectangulo[260 @ 450, 320 @ 480],\n        rectangulo[320 @ 480, 410 @ 510],\n        rectangulo[410 @ 420, 440 @ 480],\n        rectangulo[380 @ 390, 470 @ 420],\n        rectangulo[470 @ 330, 500 @ 390],\n        rectangulo[380 @ 300, 470 @ 330],\n        rectangulo[410 @ 270, 470 @ 330],\n        rectangulo[470 @ 210, 500 @ 270],\n        rectangulo[410 @ 210, 440 @ 240],\n        rectangulo[410 @ 180, 470 @ 210],\n        rectangulo[380 @ 150, 470 @ 180],\n        rectangulo[380 @ 150, 470 @ 180]\n      )\n    )\n  )\n)"

  dibujarImagen(unString,"rojo.png")

}

object composicionC extends App{


  val unString = "escala[1.45, 1.45](\n grupo(\n   color[0.0, 0.0, 0.0](\n \trectangulo[0 @ 0, 400 @ 400]\n   ),\n   color[200.0, 70.0, 0.0](\n \trectangulo[0 @ 0, 180 @ 150]\n   ),\n   color[250.0, 250.0, 250.0](\n \tgrupo(\n   \trectangulo[186 @ 0, 400 @ 150],\n   \trectangulo[186 @ 159, 400 @ 240],\n   \trectangulo[0 @ 159, 180 @ 240],\n   \trectangulo[45 @ 248, 180 @ 400],\n   \trectangulo[310 @ 248, 400 @ 400],\n   \trectangulo[186 @ 385, 305 @ 400]\n\t)\n   ),\n   color[30.0, 50.0, 130.0](\n   \trectangulo[186 @ 248, 305 @ 380]\n   ),\n   color[250.0, 230.0, 0.0](\n   \trectangulo[0 @ 248, 40 @ 400]\n   )\n )\n)"

  dibujarEnPantalla(unString)

}

object corazon extends App{

  val unString = "color[200.0, 0.0, 0.0](\n\tgrupo(\n\t\tescala[1.0, 0.8](\n\t\t\tgrupo(\n\t\t\t\tcirculo[210 @ 250, 100],\n\t\t\t\tcirculo[390 @ 250, 100]\n\t\t\t)\n\t\t),\n\t\trectangulo[200 @ 170, 400 @ 300],\n\t\ttriangulo[113 @ 225, 487 @ 225, 300 @ 450]\n\t)\n)"

  dibujarEnPantalla(unString)

}

object murcielago extends App{

  val unString = "grupo(\n\tescala[1.2, 1.2](\n\t\tgrupo(\n\t\t\tcolor[0.0, 0.0, 80.0](rectangulo[0 @ 0, 600 @ 700]),\n\t\t\tcolor[255.0, 255.0, 120.0](circulo[80 @ 80, 50]),\n\t\t\tcolor[0.0, 0.0, 80.0](circulo[95 @ 80, 40])\n\t\t)\n\t),\n\tcolor[50.0, 50.0, 50.0](triangulo[80 @ 270, 520 @ 270, 300 @ 690]),\n\tcolor[80.0, 80.0, 80.0](triangulo[80 @ 270, 170 @ 270, 300 @ 690]),\n\tcolor[100.0, 100.0, 100.0](triangulo[200 @ 200, 400 @ 200, 300 @ 150]),\n\tcolor[100.0, 100.0, 100.0](triangulo[200 @ 200, 400 @ 200, 300 @ 400]),\n\tcolor[150.0, 150.0, 150.0](triangulo[400 @ 200, 300 @ 400, 420 @ 320]),\n\tcolor[150.0, 150.0, 150.0](triangulo[300 @ 400, 200 @ 200, 180 @ 320]),\n\tcolor[100.0, 100.0, 100.0](triangulo[150 @ 280, 200 @ 200, 180 @ 320]),\n\tcolor[100.0, 100.0, 100.0](triangulo[150 @ 280, 200 @ 200, 150 @ 120]),\n\tcolor[100.0, 100.0, 100.0](triangulo[400 @ 200, 450 @ 300, 420 @ 320]),\n\tcolor[100.0, 100.0, 100.0](triangulo[400 @ 200, 450 @ 300, 450 @ 120]),\n\tgrupo(\n\t\tescala[0.4, 1.0](\n\t\t\tcolor[0.0, 0.0,0.0](\n\t\t\t\tgrupo(\n\t\t\t\t\tcirculo[970 @ 270, 25],\n\t\t\t\t\tcirculo[530 @ 270, 25]\n\t\t\t\t)\n\t\t\t)\n\t\t)\n\t)\n)"

  dibujarEnPantalla(unString)

}

object pepita extends App{

  val unString ="grupo(\n\tcolor[0.0, 0.0, 80.0](\n\t\tgrupo(\n\t\t\ttriangulo[50 @ 400, 250 @ 400, 200 @ 420],\n\t\t\ttriangulo[50 @ 440, 250 @ 440, 200 @ 420]\n\t\t)\n\t),\n\tcolor[150.0, 150.0, 150.0](\n\t\ttriangulo[200 @ 420, 250 @ 400, 250 @ 440]\n\t),\n\tcolor[180.0, 180.0, 160.0](\n\t\ttriangulo[330 @ 460, 250 @ 400, 250 @ 440]\n\t),\n\tcolor[200.0, 200.0, 180.0](\n\t\tgrupo(\n\t\t\ttriangulo[330 @ 460, 400 @ 400, 330 @ 370],\n\t\t\ttriangulo[330 @ 460, 400 @ 400, 370 @ 450],\n\t\t\ttriangulo[400 @ 430, 400 @ 400, 370 @ 450],\n\t\t\ttriangulo[330 @ 460, 250 @ 400, 330 @ 370]\n\t\t)\n\t),\n\tgrupo(\n\t\tcolor[150.0, 0.0, 0.0](\n\t\t\tgrupo(\n\t\t\t\ttriangulo[430 @ 420, 400 @ 400, 450 @ 400],\n\t\t\t\ttriangulo[430 @ 420, 400 @ 400, 400 @ 430]\n\t\t\t)\n\t\t),\n\t\tcolor[100.0, 0.0, 0.0](triangulo[420 @ 420, 420 @ 400, 400 @ 430]),\n\t\tcolor[0.0, 0.0, 60.0](\n\t\t\tgrupo(\n\t\t\t\ttriangulo[420 @ 400, 400 @ 400, 400 @ 430],\n\t\t\t\ttriangulo[420 @ 380, 400 @ 400, 450 @ 400],\n\t\t\t\ttriangulo[420 @ 380, 400 @ 400, 300 @ 350]\n\t\t\t)\n\t\t),\n\t\tcolor[150.0, 150.0, 0.0](triangulo[440 @ 410, 440 @ 400, 460 @ 400])\n\t),\n\tcolor[0.0, 0.0, 60.0](\n\t\tgrupo(\n\t\t\ttriangulo[330 @ 300, 250 @ 400, 330 @ 370],\n\t\t\ttriangulo[330 @ 300, 400 @ 400, 330 @ 370],\n\t\t\ttriangulo[360 @ 280, 400 @ 400, 330 @ 370],\n\t\t\ttriangulo[270 @ 240, 100 @ 220, 330 @ 370],\n\t\t\ttriangulo[270 @ 240, 360 @ 280, 330 @ 370]\n\t\t)\n\t)\n)"

  dibujarEnPantalla(unString)

}

object red extends App{

  val unString ="color[100.0, 100.0, 100.0](\n  grupo(\n    color[0.0, 0.0, 0.0](\n      grupo(\n        color[201.0, 176.0, 55.0](\n          triangulo[0 @ 0, 650 @ 0, 0 @ 750]\n        ),\n        color[215.0, 215.0, 215.0](\n          triangulo[650 @ 750, 650 @ 0, 0 @ 750]\n        ),\n        color[255.0, 255.0, 255.0](\n          grupo(\n            rectangulo[230 @ 150, 350 @ 180],\n            rectangulo[110 @ 150, 470 @ 390]\n          )\n        ),\n        color[255.0, 0.0, 0.0](\n          grupo(\n            rectangulo[170 @ 60, 410 @ 150],\n            rectangulo[350 @ 60, 380 @ 180],\n            rectangulo[200 @ 60, 230 @ 180],\n            rectangulo[260 @ 300, 320 @ 330],\n            rectangulo[170 @ 390, 410 @ 480]\n          )\n        ),\n        rectangulo[200 @ 180, 380 @ 210],\n        rectangulo[230 @ 240, 260 @ 300],\n        rectangulo[320 @ 240, 350 @ 300],\n        rectangulo[200 @ 30, 380 @ 60],\n        rectangulo[170 @ 60, 200 @ 90],\n        rectangulo[380 @ 60, 410 @ 90],\n        rectangulo[140 @ 90, 170 @ 150],\n        rectangulo[410 @ 90, 440 @ 150],\n        rectangulo[110 @ 150, 200 @ 180],\n        rectangulo[110 @ 180, 170 @ 210],\n        rectangulo[140 @ 210, 170 @ 240],\n        rectangulo[80 @ 210, 110 @ 270],\n        rectangulo[110 @ 270, 170 @ 330],\n        rectangulo[110 @ 300, 200 @ 330],\n        rectangulo[80 @ 330, 110 @ 390],\n        rectangulo[110 @ 390, 200 @ 420],\n        rectangulo[140 @ 420, 170 @ 480],\n        rectangulo[200 @ 420, 260 @ 450],\n        rectangulo[320 @ 420, 380 @ 450],\n        rectangulo[260 @ 390, 320 @ 420],\n        rectangulo[170 @ 330, 410 @ 390],\n        rectangulo[170 @ 480, 260 @ 510],\n        rectangulo[260 @ 450, 320 @ 480],\n        rectangulo[320 @ 480, 410 @ 510],\n        rectangulo[410 @ 420, 440 @ 480],\n        rectangulo[380 @ 390, 470 @ 420],\n        rectangulo[470 @ 330, 500 @ 390],\n        rectangulo[380 @ 300, 470 @ 330],\n        rectangulo[410 @ 270, 470 @ 330],\n        rectangulo[470 @ 210, 500 @ 270],\n        rectangulo[410 @ 210, 440 @ 240],\n        rectangulo[410 @ 180, 470 @ 210],\n        rectangulo[380 @ 150, 470 @ 180],\n        rectangulo[380 @ 150, 470 @ 180]\n      )\n    )\n  )\n)"

  dibujarEnPantalla(unString)

}