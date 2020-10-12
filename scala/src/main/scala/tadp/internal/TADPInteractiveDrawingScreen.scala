package tadp.internal

import java.io.FileOutputStream
import java.time.LocalDateTime

import javafx.embed.swing.SwingFXUtils
import javax.imageio.ImageIO
import scalafx.application.JFXApp
import scalafx.application.JFXApp.PrimaryStage
import scalafx.geometry.Insets
import scalafx.scene.canvas.Canvas
import scalafx.scene.control.{Button, Label, TextArea}
import scalafx.scene.image.WritableImage
import scalafx.scene.input.{KeyCode, KeyCodeCombination, KeyCombination}
import scalafx.scene.layout._
import scalafx.scene.paint.Color
import scalafx.scene.{Group, Scene}

class TADPInteractiveDrawingScreen(dibujador: (String, TADPDrawingAdapter) => Any) extends JFXApp {
  val appWidth = 1200
  val appHeight = 800
  val paneSeparation = 20
  val contentWidth = appWidth - paneSeparation * 2
  val contentHeight = appHeight - paneSeparation * 2

  var canvas = new Canvas(contentWidth / 2, contentHeight - 60)
  var adapter = TADPDrawingAdapter(canvas)
  val canvasPane = new HBox()

  def setupCanvas() = {
    canvas = new Canvas(contentWidth / 2, contentHeight - 60)
    adapter = TADPDrawingAdapter(canvas)
    canvasPane.children = canvas
    canvasPane.margin = Insets(0, 0, 0, paneSeparation)
    canvasPane.maxHeight = canvas.height.value
    canvasPane.border = new Border(new BorderStroke(Color.Gray,
      BorderStrokeStyle.Solid,
      new CornerRadii(0),
      new BorderWidths(1)))
  }

  setupCanvas()

  val textField = new TextArea() {
    prefWidth = contentWidth / 2 - paneSeparation
    maxHeight = canvas.height.value
  }

  val drawButton = new Button("Dibujar") {
    layoutX = 0
    onAction = { _ => dibujar() }
  }
  val saveButton = new Button("Guardar") {
    layoutX = 70
    onAction = { _ => guardar() }
  }
  val ctrlEnter = new KeyCodeCombination(KeyCode.Enter, KeyCombination.ControlDown)
  val parseResultLabel = new Label("") {
    layoutX = 150
    layoutY = 5
  }

  stage = new PrimaryStage {
    title = "TADP Draw"
    scene = new Scene(appWidth, appHeight) {

      val border = new BorderPane
      border.padding = Insets(paneSeparation, paneSeparation, paneSeparation, paneSeparation)
      border.left = textField
      border.right = canvasPane
      border.bottom = new Group {
        children = Seq(drawButton, saveButton, parseResultLabel)
        margin = Insets(paneSeparation, 0, 0, 0)
      }

      onKeyPressed = { keyEvent => if (ctrlEnter.`match`(keyEvent)) dibujar() }

      root = border
    }
  }

  def info(mensaje: String): Unit = {
    parseResultLabel.text = mensaje
    parseResultLabel.textFill = Color.Black
  }

  def error(mensaje: String): Unit = {
    parseResultLabel.text = mensaje
    parseResultLabel.textFill = Color.Red
  }

  def limpiarMensaje(): Unit = {
    parseResultLabel.text = ""
  }

  def dibujar(callback: () => Unit = () => ()): Unit = {
    setupCanvas()
    limpiarMensaje()
    val descripcionDeImagen = textField.text.getValue

    try {
      dibujador(descripcionDeImagen, adapter)
      callback()
    } catch {
      case e => error(e.getMessage)
    }
  }

  def guardar(): Unit = {
    dibujar { () =>
      val image = new WritableImage(canvas.width.intValue(), canvas.height.intValue())
      canvas.snapshot(null, image)

      val nombreDeImagen = s"dibujo-${LocalDateTime.now()}.png"
      val nombreDeCarpeta = "out/"

      ImageIO.write(SwingFXUtils.fromFXImage(image, null), "png", new FileOutputStream(nombreDeCarpeta + nombreDeImagen))
      info(s"Imagen ${nombreDeImagen} guardada en ${nombreDeCarpeta}")
    }
  }
}
