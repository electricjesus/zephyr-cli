# typed: false
# frozen_string_literal: true

# Formula updated automatically by the release workflow.
# SHA256 values are patched in by the update-formula job after binaries are built.
class Zephyr < Formula
  desc "CLI tool for Zephyr Scale API"
  homepage "https://github.com/electricjesus/zephyr-cli"
  version "1.2.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/electricjesus/zephyr-cli/releases/download/v#{version}/zephyr-macos-arm64"
      sha256 "c9974795fe3815c84b63ce470afb7cc07062443f1a900b70e83ca559938a5a8d"
    end
    on_intel do
      url "https://github.com/electricjesus/zephyr-cli/releases/download/v#{version}/zephyr-macos-x64"
      sha256 "04414e2799da7c256672365f1ed7c3b0b096a4c228b77a6cae53916d62801f4b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/electricjesus/zephyr-cli/releases/download/v#{version}/zephyr-linux-x64"
      sha256 "f5473c927f0503fbec922a16dd834e7c13a4b25b51ef9b1f8fe4619a3320d069"
    end
  end

  def install
    if OS.mac?
      bin.install "zephyr-macos-arm64" => "zephyr" if Hardware::CPU.arm?
      bin.install "zephyr-macos-x64" => "zephyr" if Hardware::CPU.intel?
    elsif OS.linux?
      bin.install "zephyr-linux-x64" => "zephyr"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zephyr --version")
  end
end
