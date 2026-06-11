# Pin npm packages by running ./bin/importmap

pin "application"
pin "pwa", to: "pwa.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Wabi component JS dependencies (dialog, tabs)
pin "@zag-js/number-input", to: "@zag-js/number-input.js" # vendored by wabi
pin "@zag-js/vanilla", to: "@zag-js/vanilla.js" # vendored by wabi
pin "@zag-js/anatomy", to: "@zag-js/anatomy.js" # vendored by wabi
pin "@zag-js/dom-query", to: "@zag-js/dom-query.js" # vendored by wabi
pin "@zag-js/utils", to: "@zag-js/utils.js" # vendored by wabi
pin "@zag-js/core", to: "@zag-js/core.js" # vendored by wabi
pin "@internationalized/number", to: "@internationalized/number.js" # vendored by wabi
pin "@zag-js/types", to: "@zag-js/types.js" # vendored by wabi
pin "@zag-js/store", to: "@zag-js/store.js" # vendored by wabi
pin "proxy-compare", to: "proxy-compare.js" # vendored by wabi
pin "@zag-js/tooltip", to: "@zag-js/tooltip.js" # vendored by wabi
pin "@zag-js/menu", to: "@zag-js/menu.js" # vendored by wabi
pin "@zag-js/focus-visible", to: "@zag-js/focus-visible.js" # vendored by wabi
pin "@zag-js/popper", to: "@zag-js/popper.js" # vendored by wabi
pin "@zag-js/rect-utils", to: "@zag-js/rect-utils.js" # vendored by wabi
pin "@zag-js/dismissable", to: "@zag-js/dismissable.js" # vendored by wabi
pin "@floating-ui/dom", to: "@floating-ui/dom.js" # vendored by wabi
pin "@zag-js/interact-outside", to: "@zag-js/interact-outside.js" # vendored by wabi
pin "@floating-ui/core", to: "@floating-ui/core.js" # vendored by wabi
pin "@floating-ui/utils", to: "@floating-ui/utils.js" # vendored by wabi
pin "@floating-ui/utils/dom", to: "@floating-ui/utils/dom.js" # vendored by wabi
pin "@zag-js/file-upload", to: "@zag-js/file-upload.js" # vendored by wabi
pin "@zag-js/file-utils", to: "@zag-js/file-utils.js" # vendored by wabi
pin "@zag-js/i18n-utils", to: "@zag-js/i18n-utils.js" # vendored by wabi
