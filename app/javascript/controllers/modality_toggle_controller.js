import { Controller } from "@hotwired/stimulus"

// Muestra/oculta las secciones de "fases" y "un partido" según el radio de modalidad.
export default class extends Controller {
  static targets = ["stages", "match"]

  connect() { this.switch() }

  switch() {
    const checked = this.element.querySelector("input[name='modality']:checked")
    const mode = checked ? checked.value : "stages"
    this.stagesTarget.hidden = mode !== "stages"
    this.matchTarget.hidden = mode !== "match"
  }
}
