// app/javascript/controllers/filter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]
  
  connect() {
    console.log("Filter controller connected")  // Add this for debugging
    console.log("Form target found:", this.hasFormTarget)  // Check if target is found
  }
  
  toggle() {
    if (this.hasFormTarget) {
      this.formTarget.classList.toggle("hidden")
      
      // Toggle the button text if needed
      const iconWrapper = this.element.querySelector(".filter-icon-wrapper")
      if (this.formTarget.classList.contains("hidden")) {
        iconWrapper.innerHTML = this.getFilterIcon()
        this.element.querySelector(".button-text").textContent = "Filtros"
      } else {
        iconWrapper.innerHTML = this.getCloseIcon()
        this.element.querySelector(".button-text").textContent = "Cerrar filtros"
      }
    } else {
      console.error("Form target not found")
    }
  }
  
  getFilterIcon() {
    return `<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M3 3a1 1 0 011-1h12a1 1 0 011 1v3a1 1 0 01-.293.707L12 11.414V15a1 1 0 01-.293.707l-2 2A1 1 0 018 17v-5.586L3.293 6.707A1 1 0 013 6V3z" clip-rule="evenodd" />
    </svg>`
  }
  
  getCloseIcon() {
    return `<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
    </svg>`
  }
}