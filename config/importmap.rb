# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Wabi component JS dependencies (dialog, tabs)
pin "@zag-js/dialog", to: "https://cdn.jsdelivr.net/npm/@zag-js/dialog@1.41/+esm"
pin "@zag-js/vanilla", to: "https://cdn.jsdelivr.net/npm/@zag-js/vanilla@1.41/+esm"
pin "@zag-js/tabs", to: "https://cdn.jsdelivr.net/npm/@zag-js/tabs@1.41/+esm"
