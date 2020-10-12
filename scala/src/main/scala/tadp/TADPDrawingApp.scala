package tadp

import scalafx.scene.paint.Color
import tadp.internal.TADPDrawingAdapter

object TADPDrawingApp extends App {
// Ejemplo de uso del drawing adapter:
  TADPDrawingAdapter
    .forScreen { adapter =>
      adapter
        .beginColor(Color.rgb(100, 100, 100))
        .rectangle((200, 200), (400, 400))
        .end()
    }
}
