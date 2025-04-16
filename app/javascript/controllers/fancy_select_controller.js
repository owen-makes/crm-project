import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "option", "field"]

  filter() {
    const query = this.inputTarget.value.toLowerCase()

    if (query.length === 0) {
      this.listTarget.classList.add("hidden")
      return
    }

    this.optionTargets.forEach((el) => {
      const label = el.dataset.label.toLowerCase()
      const match = label.includes(query)
      el.classList.toggle("hidden", !match)
    })

    this.listTarget.classList.remove("hidden")
  }

  select(event) {
    const selectedId = event.currentTarget.dataset.id
    const selectedLabel = event.currentTarget.dataset.label

    this.inputTarget.value = selectedLabel
    this.fieldTarget.value = selectedId
    this.listTarget.classList.add("hidden")

    console.log("Selected:", selectedId, selectedLabel)
    console.log("Hidden field value now:", this.fieldTarget.value)


    this.element.dispatchEvent(
      new CustomEvent("fancy-select:change", {
        detail: { id: selectedId, label: selectedLabel },
        bubbles: true
      })
    )

  }
}
