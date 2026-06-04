// Registers the PWA service worker (served at /service-worker, scope "/").
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker").catch((e) => {
      console.warn("Service worker registration failed:", e)
    })
  })
}
