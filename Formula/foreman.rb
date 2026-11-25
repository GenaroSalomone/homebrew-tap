class Foreman < Formula
  desc "Run coding agents as one planner and many isolated executors on herdr"
  homepage "https://github.com/GenaroSalomone/foreman"
  url "https://github.com/GenaroSalomone/foreman/archive/refs/tags/v1.3.0-rc.1.tar.gz"
  sha256 "e1675781cdb67a6841874d5618af15baff72ae3d5929ebdb9683b6228e8ccc2a"
  license "MIT"

  depends_on "herdr"

  uses_from_macos "python"

  # hw-core and the invokers, built by setup/build-core --pack and attached to the release: no Go to install
  on_macos do
    on_arm do
      resource "hw-core" do
        url "https://github.com/GenaroSalomone/foreman/releases/download/v1.3.0-rc.1/hw-core-darwin-arm64.tar.gz"
        sha256 "54305c43422d16ed4ee3668efb8a16fdbb7045ee609af7bc85bbc6825b03b3f2"
      end
    end
    on_intel do
      resource "hw-core" do
        url "https://github.com/GenaroSalomone/foreman/releases/download/v1.3.0-rc.1/hw-core-darwin-amd64.tar.gz"
        sha256 "2d03329317aea6d6b2cde918a35a82f37e9f551b23f8be82404203afc374dd4f"
      end
    end
  end
  on_linux do
    on_arm do
      resource "hw-core" do
        url "https://github.com/GenaroSalomone/foreman/releases/download/v1.3.0-rc.1/hw-core-linux-arm64.tar.gz"
        sha256 "cb3a4d7577d1a786847769fe691864fd18ef7bf042ab200fe956814b38118406"
      end
    end
    on_intel do
      resource "hw-core" do
        url "https://github.com/GenaroSalomone/foreman/releases/download/v1.3.0-rc.1/hw-core-linux-amd64.tar.gz"
        sha256 "d1db127e909d66e5f8668b271cd4f5a850e8a320280a52b6bb569023df4fef47"
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
