class ForemanSh < Formula
  desc "Run coding agents as one planner and many isolated executors on herdr"
  homepage "https://github.com/GenaroSalomone/foreman-sh"
  url "https://github.com/GenaroSalomone/foreman-sh/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "2ce172d7ca89a3d317271f3b641225788139b5aabd424a34ff910571c0310eb0"
  license "MIT"

  depends_on "fd"
  depends_on "herdr"
  depends_on "jq"
  depends_on "ripgrep"
  depends_on "sd"

  uses_from_macos "python"

  def install
    libexec.install Dir["*"]
    (bin/"foreman-sh").write_env_script libexec/"install.sh",
      FOREMAN_SH_VERSION:     "v#{version}",
      FOREMAN_SH_INSTALL_CMD: "foreman-sh"
  end

  def caveats
    <<~EOS
      foreman-sh is installed; your brain is not. Create it with a first lane:
        foreman-sh --brain ~/brain --lane myapp --repo ~/code/myapp

      Claude Code is required and is a cask, so this formula cannot depend on it.
      Install it, and the recommended engram and fzf, with:
        foreman-sh --with-recommended

      To upgrade, run `foreman-sh upgrade --brain ~/brain`: the brain keeps its own
      copy of the mechanism, and this refreshes it with the flags you installed with.
    EOS
  end

  test do
    assert_match "install.sh v#{version}", shell_output("#{bin}/foreman-sh --version")
    assert_match "--with-recommended", shell_output("#{bin}/foreman-sh --help")
  end
end
