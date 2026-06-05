require "test_helper"

class PwaTest < ActionDispatch::IntegrationTest
  test "manifest is valid JSON describing an installable app" do
    get "/manifest.json"
    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "Golbet", data["name"]
    assert_equal "standalone", data["display"]
    icons = data["icons"]
    assert(icons.any? { |i| i["sizes"] == "512x512" && i["purpose"] == "any" })
    assert(icons.any? { |i| i["purpose"] == "maskable" })
  end

  test "service worker is served as javascript with an offline fallback" do
    get "/service-worker"
    assert_response :success
    assert_includes response.content_type, "javascript"
    assert_match "offline.html", response.body
    assert_match "addEventListener", response.body
  end

  test "the layout links the manifest, theme-color and apple-touch-icon" do
    get root_path
    assert_response :success
    assert_select "link[rel=manifest]"
    assert_select "meta[name=theme-color]"
    assert_select "link[rel='apple-touch-icon']"
  end

  test "the PWA assets exist in public/" do
    %w[icon-192.png icon-512.png icon-maskable-512.png offline.html].each do |f|
      assert File.exist?(Rails.root.join("public", f)), "missing public/#{f}"
    end
  end
end
