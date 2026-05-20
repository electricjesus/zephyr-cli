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
      sha256 "96eef35f025744dec663a9dd4d695ba298cabf81c1d6e1dc6325b34c5a9a4201"
    end
    on_intel do
      url "https://github.com/electricjesus/zephyr-cli/releases/download/v#{version}/zephyr-macos-x64"
      sha256 "040809dc3c97d1b614361e5bf99b841a7df077309844e3fe235cfd4b9eddbde7"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/electricjesus/zephyr-cli/releases/download/v#{version}/zephyr-linux-x64"
      sha256 "0ad6edbf7784b6f2d97b421140fedc593a9e5b88119ca0339db47d5d1ca2fc00"
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
