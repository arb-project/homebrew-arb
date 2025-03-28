class Arb < Formula
  desc "Graphical DNA, RNA and amino acid sequence analysis tool - production version"
  homepage "http://www.arb-home.de"

  # ARB production version
  stable do
    url "http://download.arb-home.de/production/2022_09_08/arb-r19270-source.tgz"
    sha256 "616bc04c9de1e4e9d8f633995b26e03e3ea5462308a9383de18b226f8de9fde8"
    version "7.1-beta_r19270"
  end

  # ARB development version
  head do
     url "http://vc.arb-home.de/readonly/trunk", :using => :svn
  end

  ##############################################################################
  ### OPTIONS                                                                ###
  ##############################################################################
  # for internal / ARB developer use only
  option "with-test", "Execute unit tests followed by normal build. Not intended for end-users."

  # for GitHub actions / internal / ARB developer use only
  option "with-test-only", "Execute unit tests during build, not followed by normal build. Not intended for end-users."

  # enable debug symbols in binaries
  option "with-debug", "Enable debug symbols in binaries. Not intended for end-users."

  ##############################################################################
  ### DEPENDENCIES - homebrew style is to sort blocks alphabetically         ###
  ##############################################################################

  depends_on "makedepend" => :build
  depends_on "pkg-config" => :build

  depends_on :arch => :x86_64
  depends_on "boost"
  depends_on "coreutils"
  depends_on "gettext"
  depends_on "glib"
  depends_on "gnu-sed"
  depends_on "gnu-time"
  depends_on "gnuplot"
  depends_on "libxaw"
  depends_on "lynx"
  depends_on "openmotif"
  depends_on "arb-project/arb/perl@5.36"
  depends_on "xerces-c"
  depends_on "xfig"

  # OpenGL dependencies
  depends_on "glfw"
  depends_on "mesalib-glw"
  depends_on "glew"
  depends_on "freeglut"

  conflicts_with "arb"

  # Patch the ARB shell script to make sure ARB uses the same perl version at
  # runtime as this formula at build time. This patch will not be submitted to
  # upstream (decision made with the ARB team). The brew audit (brew audit
  # --new-formula arb) will complain about the patch, the three corresponding
  # errors in the report can be ignored.
  # at the moment different patches are required for HEAD and production
  patch :DATA

  stable do
    patch "
diff --git a/Makefile b/Makefile
--- a/Makefile
+++ b/Makefile
@@ -700,6 +700,7 @@ dflags += -D$(MACH) # define machine

 ifeq ($(DARWIN),1)
  shared_cflags += -fno-common
+ cflags +=  -Wno-error=implicit-function-declaration
 else
  dflags +=  $(shell getconf LFS_CFLAGS)
 endif
diff --git a/GDE/SATIVA/Makefile b/GDE/SATIVA/Makefile
--- a/GDE/SATIVA/Makefile
+++ b/GDE/SATIVA/Makefile
@@ -58,7 +58,7 @@ build:  $(VERSIONS:%=$(RAXML_BIN)%)
 #  which are needed by RAxML)
 
 $(RAXML_BIN)%: unpack.%.stamp Makefile
-	( MAKEFLAGS= $(MAKE) -C $(<:unpack.%.stamp=builddir.%) -f Makefile.$(@:$(RAXML_BIN)%=%).$(MAKE_SUFFIX) ) 2>&1 | grep -vi ' warning: '
+	( MAKEFLAGS= $(MAKE) -C $(<:unpack.%.stamp=builddir.%) -f Makefile.$(@:$(RAXML_BIN)%=%).$(MAKE_SUFFIX) CFLAGS=\"-Wno-error=implicit-function-declaration\" ) 2>&1 | grep -vi ' warning: '
 	cp $(<:unpack.%.stamp=builddir.%)/raxmlHPC-* $@
 
 unpack.%.stamp: $(TARFILE)  
    "
  end

  ##############################################################################
  ### INSTALL                                                                ###
  ##############################################################################
  def install

    # set a fixed perl path in the arb script
    which_perl = which("perl").parent.to_path
    inreplace Dir["#{buildpath}/SH/arb"], /___PERL_PATH___/, which_perl

    # some perl scripts use /usr/bin/perl which does not work with ARB on MacOS
    # make all scripts use the perl version from the environment
    inreplace Dir["#{buildpath}/**/*.pl"] do |s|
      # The false in the gsub! call makes homebrew not throw an error if there
      # is no line naming the perl executable in the script files (which is they
      # case for some scripts).
      s.gsub!(/^#!.*perl/, "#!#{which_perl}/perl", audit_result: false)
    end

    # on some systems the permissions were incorrect after the patch
    # leading to the symlink in bin not be created -> make sure they are correct
    chmod 0555, "#{buildpath}/SH/arb"

    # make ARB makefile happy
    cp "config.makefile.template", "config.makefile"

    # create header file with revision information when building head
    if build.head?
      (buildpath/"TEMPLATES/svn_revision.h").write <<~EOS
        #define ARB_SVN_REVISION      "#{version}"
        #define ARB_SVN_BRANCH        "trunk"
        #define ARB_SVN_BRANCH_IS_TAG 0
      EOS
    end

    # build options
    args = %W[
      ARB_64=1
      OPENGL=1
      MACH=DARWIN
      DARWIN=1
      LINUX=0
      DEBIAN=0
      REDHAT=0
      DEBUG=#{build.with?("debug") ? 1 : 0}
      TRACESYM=1
    ]

    # environment variables required by the build
    ENV["ARBHOME"] = buildpath.to_s
    ENV.prepend_path "PATH", "#{buildpath}/bin"

    # build
    if build.with?("test") || build.with?("test-only")
      opoo "The option --with-test is intended for developer use only. It may fail your build. If it does, install ARB without the option."
      system "make", "REBUILD", "UNIT_TESTS=1", *args

      ln_sf "#{buildpath}/UNIT_TESTER/logs", "#{ENV["HOMEBREW_LOGS"]}/#{name}/unit-tests"
    end

    if build.without? "test-only"
      system "make", build.with?("test") ? "REBUILD" : "ALL", *args
    end

    # Install arb in sub-directory of the formula to prevent collision between
    # arb binaries / bundled 3rd-party binaries and other binaries
    arbInstallDir = prefix/"ArbHome"
    arbInstallDir.install "bin"
    arbInstallDir.install "lib"
    arbInstallDir.install "GDEHELP"
    arbInstallDir.install "PERL_SCRIPTS"
    arbInstallDir.install "SH"
    arbInstallDir.install "demo.arb"
    # Make Homebrew link only the arb script
    bin.install_symlink "#{arbInstallDir}/bin/arb"

    # delete .gitignore from all directories
    Dir["#{prefix}/**/.gitignore"].each do |file|
      File.delete(file)
    end
    # delete txt files from lib
    Dir["#{prefix}/**/*.txt"].each do |file|
      File.delete(file)
    end
    Dir["#{prefix}/**/*.readme"].each do |file|
      File.delete(file)
    end

    ohai "Verify ARB perl bindings"
    system "ARBHOME=\"#{arbInstallDir}\" perl #{arbInstallDir}/PERL_SCRIPTS/ARBTOOLS/TESTS/automatic.pl -client homebrew -db #{arbInstallDir}/demo.arb"
  end

  def post_install
    arbInstallDir = prefix/"ArbHome"
    # make directory for pt_server
    (arbInstallDir/"lib/pts").mkpath
    # pt_server expects that everyone can read and write
    chmod 0777, arbInstallDir/"lib/pts"
    # make PT server configuration writeable
    chmod 0666, arbInstallDir/"lib/arb_tcp.dat"
  end

  def caveats
    arbInstallDir = prefix/"ArbHome"
    <<~EOS
    - run ARB by typing arb
    - a demo database is installed in #{arbInstallDir}/demo.arb
    - for information how to install different versions of ARB via Homebrew see
      https://github.com/arb-project/homebrew-arb
    - more information about ARB can be found at http://www.arb-home.de
    - to get help you may join the ARB mailing list, see
      http://bugs.arb-home.de/wiki/ArbMailingList for details
    - to report bugs in ARB see http://bugs.arb-home.de/wiki/BugReport
    - you can set up keyboard short cuts manually by executing the following
      commands (caution this might interfere with keybord configurations you
      have set up for other X11 programs on your Mac):

      xmodmap -e "clear Mod1"
      xmodmap -e "clear Mod2"
      xmodmap -e "add Mod1 = Meta_L"
      xmodmap -e "add Mod1 = Meta_R"
      xmodmap -e "add Mod2 = Mode_switch"

      after executing these commands you can use the following short cuts in
      ARB:
        - use CONTROL COMMAND ARROW KEY to jump over bases
        - use OPTION ARROW KEY to pull in bases across alignment gaps
        - use right COMMAND plus a letter key to activate a menu item
    - the structure of the installation has changed on macOS. If you
      used/referenced to binaries without using the "arb shell" you need to
      adopt your scripts. The ARB binaries version can be found in
      #{arbInstallDir}/bin, the PERL scripts in
      #{arbInstallDir}/PERL_SCRIPTS.

    Please cite

    Ludwig, W. et al. ARB: a software environment for sequence data.
    Nucleic Acids Research 32, 1363–1371 (2004).

  EOS
  end

  test do
    system bin/"arb", "help"
  end
end

# make ARB use the bundled PERL version
__END__
diff --git a/SH/arb b/SH/arb
--- a/SH/arb
+++ b/SH/arb
@@ -1,5 +1,7 @@
 #!/bin/bash -u

+export PATH="___PERL_PATH___:$PATH"
+
 # set -x

 # error message function
diff --git a/Makefile b/Makefile
--- a/Makefile
+++ b/Makefile
@@ -939,7 +939,7 @@
 #---------------------- warn about duplicate variable definitions

 ifeq ($(DARWIN),1)
-clflags += -Wl,-warn_commons
+# clflags += -Wl,-warn_commons
 else
 clflags += -Wl,--warn-common
 endif
