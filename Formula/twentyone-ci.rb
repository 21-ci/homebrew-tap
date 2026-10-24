# typed: false
# frozen_string_literal: true

# Generated from packaging/homebrew/twentyone-ci.rb.tmpl in github.com/21-ci/runtime by the release workflow. Do not
# edit in the tap: changes are overwritten on the next release.
#
# Homebrew derives the Ruby class from the formula name, and a name that starts with a digit is not a valid class, so
# the formula is `twentyone-ci` and the tap carries the alias `Aliases/21ci`: `brew install 21-ci/tap/21ci` works.
class TwentyoneCi < Formula
  desc "Command-line client for the 21 Cloud Functions Runtime control API"
  homepage "https://github.com/21-ci/runtime"
  version "0.1.1"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/21-ci/runtime/releases/download/v0.1.1/21ci-0.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "dcc5a20d89937e4c52beec2d1ed650b4fcd51911b342840659e3b76f926e5281"
    end
    on_intel do
      url "https://github.com/21-ci/runtime/releases/download/v0.1.1/21ci-0.1.1-x86_64-apple-darwin.tar.gz"
      sha256 "badb565598bb21a40ab30a7fd6319cda0d7ecc20b958498f498800f9d9cc4bf3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/21-ci/runtime/releases/download/v0.1.1/21ci-0.1.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d7bb07d4797e68e4b4a6432061f2246f67a62e1ab24e0c2b05fe7c5b25e434be"
    end
    on_intel do
      url "https://github.com/21-ci/runtime/releases/download/v0.1.1/21ci-0.1.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d1b3d10e817de08173ffc37928ed1b55fc8570a7c4de8b0f7dd15866027ff7e7"
    end
  end

  def install
    bin.install "21ci"
    generate_completions_from_executable(bin/"21ci", "completion")
    doc.install "README.md", "LICENSE", "NOTICE"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/21ci --version")
    # No node to talk to: a network error exits 3 (docs: CLI exit codes).
    shell_output("#{bin}/21ci --api http://127.0.0.1:9 tenant ls 2>&1", 3)
  end
end
