# typed: false
# frozen_string_literal: true

# Formula updated automatically by the release workflow.
# SHA256 values are patched in by the update-formula job after binaries are built.
class Zephyr < Formula
  desc "CLI tool for Zephyr Scale API"
  homepage "https://github.com/electricjesus/zephyr-cli"
  version "1.2.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/electricjesus/zephyr-cli/releases/download/v#{version}/zephyr-macos-arm64"
      sha256 "SHA256_MACOS_ARM64"
    end
    on_intel do
      url "https://github.com/electricjesus/zephyr-cli/releases/download/v#{version}/zephyr-macos-x64"
      sha256 "SHA256_MACOS_X64"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/electricjesus/zephyr-cli/releases/download/v#{version}/zephyr-linux-x64"
      sha256 "SHA256_LINUX_X64"
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
