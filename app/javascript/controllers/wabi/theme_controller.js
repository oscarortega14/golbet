import { Controller } from "@hotwired/stimulus"

// Wabi theme controller — toggles data-mode on <html>, persists to localStorage,
// respects prefers-color-scheme on first load.
export default class extends Controller {
  static values = {
    themeKey: { type: String, default: "wabi-theme" },
    modeKey:  { type: String, default: "wabi-mode" },
  }

  connect() {
    const html = document.documentElement
    // Respect the server-rendered theme as the fallback instead of forcing
    // "default" — a fresh Wabi install may only have one palette installed
    // (here: "green"), and clobbering the SSR theme leaves CSS vars undefined.
    const storedTheme = localStorage.getItem(this.themeKeyValue) || html.dataset.theme || "default"
    const storedMode  = localStorage.getItem(this.modeKeyValue) || html.dataset.mode || "dark"
    html.dataset.theme = storedTheme
    html.dataset.mode  = storedMode
  }

  toggleMode() {
    const html = document.documentElement
    const next = html.dataset.mode === "dark" ? "light" : "dark"
    html.dataset.mode = next
    localStorage.setItem(this.modeKeyValue, next)
    this.dispatch("change", { detail: { mode: next } })
  }

  setTheme(event) {
    const theme = event.params.theme
    document.documentElement.dataset.theme = theme
    localStorage.setItem(this.themeKeyValue, theme)
    this.dispatch("change", { detail: { theme } })
  }

  systemMode() {
    return window.matchMedia?.("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }
}
