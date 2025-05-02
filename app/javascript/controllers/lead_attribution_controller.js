import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["channel", "detail", "campaign", "fallback", "select", "broker"]

  connect () {
    // 1. Try UTM params
    const params = new URLSearchParams(window.location.search)
    const src    = params.get("utm_source")
    const camp   = params.get("utm_campaign")
    const medium = params.get("utm_medium")

    let channel = this.mapMedium(medium) || this.mapSource(src)

    // 2. Fallback to referrer if channel still blank
    if (!channel && document.referrer) {
      const host = new URL(document.referrer).hostname
      channel    = this.mapReferrer(host)
      if (!src) this.detailTarget.value = host        // keep detail if not set
    }

    // 3. Populate hidden fields
    if (channel)            this.channelTarget.value  = channel
    if (src)                this.detailTarget.value   = src
    if (camp)               this.campaignTarget.value = camp

    // 4. Show dropdown only if channel still unknown
    if (!channel) {
      this.fallbackTarget.classList.remove("hidden")
      this.selectTarget.disabled = false
      this.brokerTarget.classList.remove("md:col-span-2")    
    }
  }

  /* allow user to override */
  syncSelect (e) { this.channelTarget.value = e.target.value }

  /* helpers ------------------------------------------------ */
  mapMedium (m) {
    switch((m || "").toLowerCase()) {
      case "cpc": case "ppc": return "publicidad"
      case "social":         return "redes"
      case "email":          return "email"
    }
  }
  mapSource (s) {
    if (!s) return null
    if (/instagram|tiktok|facebook|linkedin|youtube/.test(s)) return "redes"
    if (/google_ads/.test(s))                                 return "publicidad"
    return null
  }
  mapReferrer (h) {
    if (/google\./.test(h)) return "busqueda"
    if (/instagram\.com|facebook\.com|tiktok\.com|linkedin\.com|youtube\.com/.test(h))
                           return "redes"
    return null
  }
}
