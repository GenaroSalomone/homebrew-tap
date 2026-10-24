class ForemanSh < Formula
  desc "Run coding agents as one planner and many isolated executors on herdr"
  homepage "https://github.com/GenaroSalomone/foreman-sh"
  url "https://github.com/GenaroSalomone/foreman-sh/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "bcaac296edbd924d4e4ed195c1903c80aa34f20e2e4820f8d263b221e121271f"
  license "MIT"

  depends_on "fd"
  # go is a runtime dependency, not :build: foreman-sh builds hw-core when it installs a brain, long after `brew install`
  depends_on "go"
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
