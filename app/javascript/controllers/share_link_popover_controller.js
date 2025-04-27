import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "textbox"]

  // open / close -------------------------------------------------------------
  toggle (event) {
    event.preventDefault()
    const hidden = this.panelTarget.classList.toggle("hidden")
    if (!hidden)  { document.addEventListener("click", this.closeWhenOutside) }
    else          { document.removeEventListener("click", this.closeWhenOutside) }
  }

  closeWhenOutside = (e) => {
    if (!this.element.contains(e.target)) {
      this.panelTarget.classList.add("hidden")
      document.removeEventListener("click", this.closeWhenOutside)
    }
  }

  // clipboard ----------------------------------------------------------------
  copy () {
    navigator.clipboard.writeText(this.textboxTarget.value)
    this.textboxTarget.select()
  }
}
