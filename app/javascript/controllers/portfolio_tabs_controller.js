import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values  = { clientId: Number }

  connect() {
    // keep track of the initially selected tab (first one shown on the page)
    this.activeId = this.buttonTargets[0].dataset.portfolioId
    this.#highlight()
  }

  switch(event) {
    const id = event.currentTarget.dataset.portfolioId
    if (id === this.activeId) return     // already active – nothing to do

    this.activeId = id
    this.#highlight()

    // Ask Turbo to update only the frame, NOT the whole page
    const url = `/clients/${this.clientIdValue}/portfolios/${id}/summary`
    Turbo.visit(url, { frame: "portfolios-summary" })
  }

  #highlight() {
    this.buttonTargets.forEach(btn => {
      const active = btn.dataset.portfolioId === this.activeId
      btn.classList.toggle("border-b-2", active)
      btn.classList.toggle("border-green-600", active)
      btn.classList.toggle("text-green-600", active)
      btn.classList.toggle("text-gray-600", !active)
    })
  }
}
