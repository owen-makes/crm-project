import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Show panel when connected
    this.show()
    
    // Add event listener for escape key
    document.addEventListener('keydown', this.handleKeydown.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown.bind(this))
  }
  
  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
  
  show() {
    this.element.classList.remove(this.data.get("inactiveClass"))
    this.element.classList.add(this.data.get("activeClass"))
  }
  
  close() {
    this.element.classList.remove(this.data.get("activeClass"))
    this.element.classList.add(this.data.get("inactiveClass"))
    
    // Navigate back after animation
    setTimeout(() => {
      window.history.back()
    }, 110)
  }
}