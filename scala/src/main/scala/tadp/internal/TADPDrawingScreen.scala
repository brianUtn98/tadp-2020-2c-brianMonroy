package tadp.internal

import java.io.FileOutputStream

import javafx.application.Platform
import javafx.embed.swing.SwingFXUtils
import javax.imageio.ImageIO
import scalafx.application.JFXApp
import scalafx.application.JFXApp.PrimaryStage
import scalafx.scene.canvas.Canvas
import scalafx.scene.image.WritableImage
import scalafx.scene.{Group, Scene}

class TADPDrawingScreen(adapterInstructions: TADPDrawingAdapter => Any, toImage: Option[String] = None) extends JFXApp {
  val appWidth = 1024
  val appHeight = 640

  val canvas = new Canvas(appWidth, appHeight)

  val adapter = TADPDrawingAdapter(canvas)
  stage = new PrimaryStage {
    title = "TADP Draw"
    scene = new Scene(appWidth, appHeight) {
      content = new Group {
        children = Seq(canvas)
      }
    }
  }

  adapterInstructions.apply(adapter)
  toImage.foreach(imageName => {
    val image = new WritableImage(canvas.width.intValue(), canvas.height.intValue())
    canvas.snapshot(null, image)
    ImageIO.write(SwingFXUtils.fromFXImage(image, null), "png", new FileOutputStream("out/" + imageName))
    Platform.exit()
  })
}
