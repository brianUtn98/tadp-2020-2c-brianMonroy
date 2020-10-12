package tadp

import org.scalatest.flatspec._
import org.scalatest.matchers._

class ExampleSpec extends AnyFlatSpec with should.Matchers {
  it should "sumar 1 + 1" in {
    1 + 1 shouldEqual 2
  }
}
