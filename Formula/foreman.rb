class Foreman < Formula
  desc "Run coding agents as one planner and many isolated executors on herdr"
  homepage "https://github.com/GenaroSalomone/foreman"
  url "https://github.com/GenaroSalomone/foreman/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "f4999ff0a71389ffe3430e9a624c369f2b5e4115be720fc8918f147f64e14f31"
  license "MIT"

  depends_on "fd"
  # go is a runtime dependency, not :build: foreman builds hw-core when it installs a brain, long after `brew install`
  depends_on "go"
  depends_on "herdr"
  depends_on "jq"
  depends_on "ripgrep"
  depends_on "sd"

  uses_from_macos "python"

  def install
    libexec.install Dir["*"]
    # `foreman-sh` is the 0.9.x name. A 0.9.x installer runs `brew upgrade foreman-sh`, then `foreman-sh upgrade`, and
    # stops if that command is gone: it stays so the handover to this release completes. It is not a `foreman` executable.
    %w[foreman-setup foreman-sh].each do |cmd|
      (bin/cmd).write_env_script libexec/"install.sh",
        FOREMAN_VERSION:     "v#{version}",
        FOREMAN_INSTALL_CMD: "foreman-setup"
    end
  end

  def caveats
    <<~EOS
      foreman is installed; your brain is not. Create it with a first lane:
        foreman-setup --brain ~/brain --lane myapp --repo ~/code/myapp

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
