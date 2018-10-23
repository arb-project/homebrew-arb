class Xfig < Formula
  desc "Interactive drawing tool"
  homepage "https://mcj.sourceforge.io"
  url "https://downloads.sourceforge.net/project/mcj/xfig-3.2.7a.tar.xz"
  sha256 "ca89986fc9ddb9f3c5a4f6f70e5423f98e2f33f5528a9d577fb05bbcc07ddf24"

  # The audit (brew audit --new-formula xfig) will complain that the option
  # of the depedency should not be used. But we want it to be build with X11
  # support. Ignore the audit error.
  depends_on "fig2dev" => ["with-x11"]
  depends_on :x11

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules"
    system "make"
    system "make", "install-strip"
  end

  test do
    # Calling xfig stops the build, all following formulas
    # will not be installed. Therefore, no tests.
    system "echo", "no test", "> /dev/null"
  end
end
