// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "overlay", "panel"]
  
  connect() {
    this.showModal()
  }
  
  showModal() {
    // Animate in
    requestAnimationFrame(() => {
      this.overlayTarget.classList.remove("opacity-0")
      this.panelTarget.classList.remove("scale-95", "opacity-0")
      this.panelTarget.classList.add("scale-100", "opacity-100")
    })
  }
  
  close(event) {
    if (event) event.preventDefault()
    
    // Animate out
    this.overlayTarget.classList.add("opacity-0")
    this.panelTarget.classList.remove("scale-100", "opacity-100")
    this.panelTarget.classList.add("scale-95", "opacity-0")
    
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}