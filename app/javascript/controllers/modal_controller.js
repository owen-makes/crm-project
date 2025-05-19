// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundEsc = (e) => { if (e.key === "Escape") this.close() }
    document.addEventListener("keydown", this.boundEsc)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundEsc)
  }

  close() {
    this.element.remove()
  }
}
