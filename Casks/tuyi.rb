cask "tuyi" do
  version "1.2.0"
  sha256 "0fc915241cd310ef4a86960f98269519dee65b8fef702874b94e31ea251dae4e"

  url "https://github.com/leslieo2/tuyi/releases/download/v#{version}/tuyi-v#{version}-macos.zip"
  name "Tuyi"
  desc "Privacy-first macOS Chrome extension for on-device OCR and image translation"
  homepage "https://github.com/leslieo2/tuyi"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  postflight_steps do
    run "/bin/bash", args: ["{{staged_path}}/tuyi-v#{version}-macos/scripts/install.sh"]
  end

  uninstall_preflight_steps do
    run "/bin/bash", args: ["{{staged_path}}/tuyi-v#{version}-macos/scripts/uninstall.sh"]
  end

  caveats <<~EOS
    To finish setup in Google Chrome (first time only):
      1. Open chrome://extensions and enable Developer mode.
      2. Click "Load unpacked" and select:
         ~/Library/Application Support/Local Image Translator/extension

    After running `brew upgrade --cask tuyi`, click Reload on the Tuyi card in chrome://extensions.
  EOS
end
