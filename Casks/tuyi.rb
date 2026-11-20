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
    mkdir_p "Library/Application Support/Local Image Translator", base: :home
    mkdir_p "Library/Application Support/Google/Chrome/NativeMessagingHosts", base: :home
    copy "tuyi-v{{version}}-macos/bin/image-translator-host",
         "Library/Application Support/Local Image Translator/image-translator-host",
         source_base: :staged_path, target_base: :home, overwrite: true
    set_permissions "Library/Application Support/Local Image Translator/image-translator-host",
                    "700", base: :home
    remove "Library/Application Support/Local Image Translator/extension", base: :home, recursive: true
    copy "tuyi-v{{version}}-macos/extension",
         "Library/Application Support/Local Image Translator/extension",
         source_base: :staged_path, target_base: :home, recursive: true, overwrite: true
    write_file "Library/Application Support/Google/Chrome/NativeMessagingHosts/com.local_image_translator.host.json",
               "{\"path\":\"#{Dir.home}/Library/Application Support/Local Image Translator/image-translator-host\",\"type\":\"stdio\",\"name\":\"com.local_image_translator.host\",\"description\":\"Local Image Translator\",\"allowed_origins\":[\"chrome-extension://mdiekkelcfdcmidenpbbdaikibmakcif/\"]}\n",
               base: :home, overwrite: true
    run "/usr/bin/xattr",
        args: ["-dr", "com.apple.quarantine",
               "#{Dir.home}/Library/Application Support/Local Image Translator/image-translator-host",
               "#{Dir.home}/Library/Application Support/Local Image Translator/extension"],
        must_succeed: false,
        print_stderr: false,
        writable_paths: [
          "Library/Application Support/Local Image Translator/image-translator-host",
          "Library/Application Support/Local Image Translator/extension"
        ],
        writable_base: :home
  end

  uninstall_preflight_steps do
    remove "Library/Application Support/Google/Chrome/NativeMessagingHosts/com.local_image_translator.host.json",
           base: :home
    remove "Library/Application Support/Local Image Translator/image-translator-host",
           base: :home
    remove "Library/Application Support/Local Image Translator/extension",
           base: :home, recursive: true
  end

  caveats <<~EOS
    To finish setup in Google Chrome (first time only):
      1. Open chrome://extensions and enable Developer mode.
      2. Click "Load unpacked" and select:
         ~/Library/Application Support/Local Image Translator/extension

    After running `brew upgrade --cask tuyi`, click Reload on the Tuyi card in chrome://extensions.
  EOS
end
