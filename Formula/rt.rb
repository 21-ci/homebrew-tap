# typed: false
# frozen_string_literal: true

# Generated from packaging/homebrew/rt.rb.tmpl in github.com/21-ci/runtime by the release workflow. Do not edit
# in the tap: changes are overwritten on the next release.
class Rt < Formula
  desc "Self-hosted multi-tenant functions runtime: Deno isolates and WASM components"
  homepage "https://github.com/21-ci/runtime"
  version "0.1.1"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/21-ci/runtime/releases/download/v0.1.1/rt-0.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "4fe4730274885765eca23faa50d1285b447d23465239dc94f7bb1719c94e2261"
    end
    on_intel do
      url "https://github.com/21-ci/runtime/releases/download/v0.1.1/rt-0.1.1-x86_64-apple-darwin.tar.gz"
      sha256 "7fbdc705ce323232a3cfde05f32ed030c75fd85de46d3101c9b7574bff329d84"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/21-ci/runtime/releases/download/v0.1.1/rt-0.1.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "a37008c25605286b952e2a5c0e7d4430b2a499f2c2000b715edbb367f95a4375"
    end
    on_intel do
      url "https://github.com/21-ci/runtime/releases/download/v0.1.1/rt-0.1.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "d688db474959907e80ab3d63575c5a2f8be9882cc99f2f38f34271abfcc65531"
    end
  end

  def install
    bin.install "rt"
    pkgshare.install "defconfigs" if File.directory?("defconfigs")
    doc.install "README.md", "LICENSE", "NOTICE"
  end

  # A sane local node: everything on loopback, data under $(brew --prefix)/var/rt, secrets in files next to the
  # config. Existing files are never overwritten (an upgrade keeps your config and keys).
  def post_install
    require "securerandom"

    (var/"rt").mkpath
    (var/"log").mkpath
    (etc/"rt").mkpath

    config = etc/"rt/rt.toml"
    unless config.exist?
      config.write <<~TOML
        # rt node started by `brew services start rt`. Every key: #{opt_pkgshare}/defconfigs/balanced.toml
        [node]
        data_dir = "#{var}/rt"
        default_profile = "balanced"

        [listeners]
        public = "127.0.0.1:8080"
        internal = "unix:#{var}/rt/rt.sock"
        control = "127.0.0.1:8081"
        metrics = "127.0.0.1:9090"

        [security]
        # Release builds ship the prebuilt V8 without its sandbox.
        require_v8_sandbox = false
      TOML
    end

    %w[root-token master.key].each do |name|
      secret = etc/"rt"/name
      next if secret.exist?

      secret.write(SecureRandom.hex(32))
      secret.chmod 0600
    end
  end

  service do
    run [opt_bin/"rt", "--config", etc/"rt/rt.toml", "serve"]
    environment_variables RT_ROOT_TOKEN_FILE: etc/"rt/root-token",
                          RT_MASTER_KEY_FILE: etc/"rt/master.key",
                          RT_LOG:             "info"
    keep_alive crashed: true
    working_dir var/"rt"
    log_path var/"log/rt.log"
    error_log_path var/"log/rt.log"
  end

  def caveats
    <<~EOS
      Start a local node (launchd on macOS, systemd --user on Linux):
        brew services start rt

      Config:      #{etc}/rt/rt.toml
      Data:        #{var}/rt
      Logs:        #{var}/log/rt.log
      Root token:  #{etc}/rt/root-token   (control API on http://127.0.0.1:8081, docs at /docs)
      Master key:  #{etc}/rt/master.key   (back it up: sealed tenant secrets need it)

      Deploy with the CLI:  brew install 21-ci/tap/21ci
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rt --version")
    (testpath/"rt.toml").write <<~TOML
      [node]
      data_dir = "#{testpath}/data"
    TOML
    assert_match "data_dir", shell_output("#{bin}/rt --print-config --config #{testpath}/rt.toml")
  end
end
