import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"

export default class extends Controller {
  connect() {
    const data = JSON.parse(this.element.dataset.holdings)
    this.drawPieChart(data)
  }

  drawPieChart(data) {
    const width = 400
    const height = 400
    const radius = Math.min(width, height) / 2

    const color = d3.scaleOrdinal(d3.schemeCategory10)

    const svg = d3.select("#holdings-chart")
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", `translate(${width / 2},${height / 2})`)

    const pie = d3.pie()
      .value(d => d.percentage)

    const arc = d3.arc()
      .innerRadius(0)
      .outerRadius(radius)

    const arcs = svg.selectAll("arc")
      .data(pie(data))
      .enter()
      .append("g")

    arcs.append("path")
      .attr("d", arc)
      .attr("fill", d => color(d.data.holding.ticker))

    arcs.append("text")
      .attr("transform", d => `translate(${arc.centroid(d)})`)
      .attr("text-anchor", "middle")
      .text(d => `${d.data.holding.ticker} (${d.data.percentage}%)`)
  }
}

