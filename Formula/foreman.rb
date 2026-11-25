class Foreman < Formula
  desc "Run coding agents as one planner and many isolated executors on herdr"
  homepage "https://github.com/GenaroSalomone/foreman"
  url "https://github.com/GenaroSalomone/foreman/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "fd8ec838843bd2fcddf4d57a87fba0b4a5e84db9e54ce7c3ed5ea5b6c690a1a1"
  license "MIT"

  depends_on "herdr"

  uses_from_macos "python"

  # hw-core and the invokers, built by setup/build-core --pack and attached to the release: no Go to install
  on_macos do
    on_arm do
      resource "hw-core" do
        url "https://github.com/GenaroSalomone/foreman/releases/download/v1.3.0/hw-core-darwin-arm64.tar.gz"
        sha256 "e8b81d7c1d8e922326f772a6f9f153dde909f8a25b18c711905d9d9614fc5c7c"
      end
    end
    on_intel do
      resource "hw-core" do
        url "https://github.com/GenaroSalomone/foreman/releases/download/v1.3.0/hw-core-darwin-amd64.tar.gz"
        sha256 "7fb4a4c2d44cc27aae396e9208b0e8563a71ea93db22fb11e536b054761df8a2"
      end
    end
  end
  on_linux do
    on_arm do
      resource "hw-core" do
        url "https://github.com/GenaroSalomone/foreman/releases/download/v1.3.0/hw-core-linux-arm64.tar.gz"
        sha256 "1fce1152ab683c1974012040f888f118a1b585e2778f048881ac24c6415b66b3"
      end
    end
    on_intel do
      resource "hw-core" do
        url "https://github.com/GenaroSalomone/foreman/releases/download/v1.3.0/hw-core-linux-amd64.tar.gz"
        sha256 "4899db5d11e200ec5b779a67dd7eb7c0f58d84c50951e2676cbf74cb9633bc8e"
      end
    end
  end

  def install
    libexec.install Dir["*"]
    # install.sh finds it in core/dist/<os>-<arch>/ beside itself and checks it against the SHA256SUMS there
    os = OS.mac? ? "darwin" : "linux"
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    dist = libexec/"core/dist/#{os}-#{arch}"
    resource("hw-core").stage { dist.install Dir["*"] }
    # `foreman-sh` is the 0.9.x name. A 0.9.x installer runs `brew upgrade foreman-sh`, then
    # `foreman-sh upgrade`, and stops if that command is gone: it stays so the handover to this
    # release completes. It is not a `foreman` executable.
    %w[foreman-setup foreman-sh].each do |cmd|
      (bin/cmd).write_env_script libexec/"install.sh",
        FOREMAN_VERSION:     "v#{version}",
        FOREMAN_INSTALL_CMD: "foreman-setup"
    end
  end

  def caveats
    <<~EOS
      foreman is installed; your brain is not. Create it, with a demo lane and a first dry run:
        foreman-setup init

      Claude Code is required and is a cask, so this formula cannot depend on it.
      Install it, and the recommended engram and fzf, with:
        foreman-setup --with-recommended

      To upgrade, run `foreman-setup upgrade --brain ~/brain`: the brain keeps its own
      copy of the mechanism, and this refreshes it with the flags you installed with.
    EOS
  end

  test do
    assert_match "install.sh v#{version}", shell_output("#{bin}/foreman-setup --version")
    assert_match "--with-recommended", shell_output("#{bin}/foreman-setup --help")
  end
end
