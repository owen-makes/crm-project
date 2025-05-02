import { Controller } from "@hotwired/stimulus"

// <div data-controller="share-link-popover">
export default class extends Controller {
  static targets = ["panel", "textbox", "platform", "campaign"]

  connect () {
    this.baseUrl = `${window.location.origin}/signup/${this.data.get("token")}`
    this.updateLink()  // set initial link
  }

  toggle () {
    this.panelTarget.classList.toggle("hidden")
  }

  copy () {     
    navigator.clipboard.writeText(this.textboxTarget.value)     
    this.textboxTarget.select()
     }

  // fire on change events from the selects/inputs
  updateLink () {
    const params = new URLSearchParams()

    const src  = this.platformTarget.value
    const camp = this.campaignTarget.value.trim()

    if (src)  params.set("utm_source",  src)
    if (src)  params.set("utm_medium",  src === "google_ads" ? "cpc" : "social")
    if (camp) params.set("utm_campaign", camp)

    const url = params.toString()
      ? `${this.baseUrl}?${params.toString()}`
      : this.baseUrl

    this.textboxTarget.value = url
  }
}
