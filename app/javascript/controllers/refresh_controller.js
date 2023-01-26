import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: Number,
    frame: String,
  }

  connect() {
    setTimeout( ()=> {
      Turbo.visit(location, { frame: this.frameValue })
    }, this.delayValue * 1000);
  }
}
