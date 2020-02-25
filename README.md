# homebrew-arb

![ARB development / production version](https://github.com/arb-project/homebrew-arb/workflows/ARB%20devel/badge.svg)
![ARB head version](https://github.com/arb-project/homebrew-arb/workflows/ARB%20head/badge.svg)

Homebrew tap for formulae to build [ARB](http://www.arb-home.de) and related
software.

Open tasks

- [X] extend test for successful installation to make sure PERL integration
      works (fixed in HEAD version)
- [ ] add stable version when 6.1 is released
- [ ] configure Preview as viewer for PDF and PS files (removes GV dependency)
- [ ] bottles
- [ ] integration into the ARB release cycle, formula needs to be tagged, too
- [ ] add formula for SINA
- [ ] add SINA to ARB
- [ ] repair OpenGL build

## Prerequisites

[Homebrew](https://brew.sh) is required to install ARB via the formula provided
in this tap.

Add this tap to your Homebrew installation.

```bash
brew tap arb-project/arb
```

ARB requires a X11 server. It was bundled with MacOS from version 10.5 to 10.7.
For all modern MacOS versions, it must be installed separately. If you have
already installed [XQuartz](https://www.xquartz.org) on your Mac, you are fine.
Otherwise you must install it either by using the installer provided on the
XQuartz website or via Homebrew:

```bash
brew cask install xquartz
```

Homebrew has removed the `gv` formula from their repository. To install `arb`
on fresh system (which had `gv` not installed via Homebrew previously), another
tab must be added to Homebrew.

```bash
brew tap denismm/gv
```

If the installation of arb fails after adding the tab, you might need to
uninstall `ghostscript` before installing `arb`.

```bash
brew uninstall ghostscript
```

## Install ARB

The `arb` formula allows you to install three different versions of ARB on your
Mac. Homebrew and ARB using different naming conventions for the builds.

| ARB name   | Homebrew name | command                    |
| ---------- | --------------| -------------------------- |
| release    | stable        | `brew install arb`         |
| production | development   | `brew install --devel arb` |
| n/a        | head          | `brew install --HEAD arb`  |

**The stable version of ARB 6.0 does not work reliably when build with this
formula. If you really need ARB 6.0 please use macports. This formula would have
to apply too many changes to make ARB 6.0 work in the Homebew environment.
Therefore, the stable version is not supported until ARB 6.1 is released. You
can use the current ARB 6.1 beta version by using the production version (see
below).**

The production version of ARB is installed and used in-house at MPI for
Marine Microbiology in Bremen. It is frequently updated from development
changes, i.e. it contains recent bug fixes and newest features, but also may
break working things. It is updated at least every few months.

If you use the production version, please file bug reports (if you encounter any
bugs) via the [ARB bug tracker](http://bugs.arb-home.de/wiki/BugReport). It
helps the ARB team to make the next release version more stable.

The head version of ARB gives you the latest changes from development, including
the latest bug fixes and features. However, any of the changes might break
working things as the version might just be in the beginning of being tested. It
is not recommended to install this version for daily, productive usage but it
gives you the opportunity to test if the latest changes in development resolve
any issues you might have with the release and/or production version of ARB.

### Install arbitrary versions of ARB

You can install arbitrary versions of ARB by editing the Homebrew formula for
ARB and specifying a revision for the head build. This requires you to be a
brew expert user. If you don't know how to edit formulas you shouldn't do it.

Please keep in mind that the revision you are trying to install might contain
broken features or might not even compile (on a Mac) at all. Building older
revisions might even require to change the dependencies and/or build steps in
the formula. Please be aware that you build these revisions on you own risk and
that we cannot provide support for these builds.

### Install an old release / production version

You can install an old release / production version of ARB using Homebrew.
Normally this is not required as Homebrew does not delete old versions when you
install a new version (see switching between versions) unless you call
`brew cleanup`.

If you need to install an old release on a new Mac or after a cleanup you need
to activate the corresponding version of the formula. The oldest versions you
can install are

- Release: n/a
- Production 6.1-beta_r17491

Let's assume the ARB team has released version 6.2.0 and you installed it but
you also want to install version 6.1.0:

```bash
# unlink the current version of ARB
brew unlink arb

# change into the directory containing your local copy of this tab
cd "$(brew --repo arb-project/arb)"

# if you do not know the exact version you need to install, you can list
# the available ones
git tag

# activate the old version of the formula
git checkout tags/v6.1.0

# install and tell Homebrew that it must not activate the newest version of the
# formula
HOMEBREW_NO_AUTO_UPDATE=1 brew install arb
```

After this steps version 6.1.0 of ARB will be installed and your active ARB
version.

### Options

#### OpenGL

By default all versions are build without support for the OpenGL features of
ARB. To enable OpenGL support in ARB add `--with-open-gl` to the build command,
e.g.

```bash
brew install --with-open-gl arb
```

to build the stable version of ARB with OpenGL support.

**The OpenGL build is work in progress and currently not working due
to a missing dependency. We haven't yet figured out which changes to the
formula are required to fix the issue. Fixing this issue has a low priority as
the missing feature is not affecting our work. Pull requests to fix this issue
are welcome.**

#### Unit tests

By default all versions are build without executing the unit tests of ARB.
However, when preparing a new release for MacOS they should be executed to make
sure everything is working as expected. To include the unit tests into the build
run

```bash
brew install arb --with-test
```

**This options is intended for contributors and ARB developers only. It may or
may not work at any given time. No support is given for using this option.**

#### Debug

You can add debug symbols to the binary by using the debug option:

```bash
brew install arb --with-debug
```

This option is intended for contributors and not for end-users. ARB shouldn't be
used with debug symbols enabled for your daily work.

## Switching between versions

When you install different versions of ARB you can switch between them using
the `switch` command of Homebrew.

```bash
brew switch arb 6.1.0
```

will activate the release version 6.1.0 of ARB (if installed).

You can list the installed versions of ARB with

```bash
brew list --versions arb
```
