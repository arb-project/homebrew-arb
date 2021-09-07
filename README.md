# homebrew-arb

![ARB 7](https://github.com/arb-project/homebrew-arb/workflows/ARB%207/badge.svg)
![ARB Production version](https://github.com/arb-project/homebrew-arb/workflows/ARB%20Production/badge.svg)
![ARB head version](https://github.com/arb-project/homebrew-arb/workflows/ARB%20head/badge.svg)

Homebrew tap for formulae to build [ARB](http://www.arb-home.de) and related
software.

Open tasks

- [ ] bottles
- [ ] integration into the ARB release cycle, formula needs to be tagged, too
- [ ] add formula for SINA
- [ ] add SINA to ARB

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
brew install --cask xquartz
```

## Install ARB

The `arb` formula allows you to install three different versions of ARB on your
Mac via two formulas. Homebrew and ARB are using different naming conventions
for the builds.

| ARB name   | Homebrew name | Formula | command                                     |
| ---------- | ------------- | ------- | ------------------------------------------- |
| release    | stable        | arb@7   | `brew install arb-project/arb/arb@7`        |
| production | stable        | arb     | `brew install arb-project/arb/arb`          |
| stable     | head          | arb@7   | `brew install --HEAD arb-project/arb/arb@7` |
| trunk      | head          | arb     | `brew install --HEAD arb-project/arb/arb`   |

The production version of ARB is installed and used in-house at MPI for Marine
Microbiology in Bremen, Germany, and is also the recommended version under
Linux. It is frequently updated from development changes, i.e. it contains
recent bug fixes and the newest features, but also may break working things. It
is updated at least every few months.

If you use the production version, please file bug reports (if you encounter any
bugs) via the [ARB bug tracker](http://bugs.arb-home.de/wiki/BugReport). It
helps the ARB team to make the next release version more stable.

The trunk version of ARB gives you the latest changes from development,
including the latest bug fixes and features. However, any of the changes might
break working things as the version might just be in the beginning of being
tested. It is not recommended to install this version for daily, productive
usage but it gives you the opportunity to test if the latest changes in
development resolve any issues you might have with the release and/or production
version of ARB.

The stable version is not intended for end-users as it will - most of the time -
be the same as the release version. Only shortly before a release, it will
contain the next release version (a.k.a release candidate). We require this
version for the final tests to make sure a release will also work on macOS. You
should never need to install this version unless the ARB team asks you to.

### Install multiple versions of ARB at the same time

The four versions listed above, can be installed at the same time but only one
can be linked by Homebrew (meaning you can execute it by typing `arb`). Before
installing an additional version, you should unlink the existing one (see
[Switching between versions](#switching-between-versions)). Otherwise, Homebrew
will complain that it cannot link the new version:

```bash
Error: The `brew link` step did not complete successfully
The formula built, but is not symlinked into /usr/local
[... rest of the error message is omitted for the sake brevity]
```

### Install an old release / production version

If you need to install an old version you need to activate the corresponding
version of the formula. The oldest versions you can install are

- `arb@7`: 7.0
- `arb`: 6.1-beta_r18660

Let's assume you have installed the latest production version but you also want
to install version 6.1-beta_r18660:

```bash
# unlink the current production version of ARB
brew unlink arb

# change into the directory containing your local copy of this tap
cd "$(brew --repo arb-project/arb)"

# if you do not know the exact version you need to install, you can list
# the available ones
git tag

# activate the old version of the formula
git checkout tags/v6.1.0

# install and tell Homebrew that it must not activate the newest version of the
# formula
HOMEBREW_NO_AUTO_UPDATE=1 brew install arb-project/arb/arb
```

After this steps version 6.1-beta_r18660 of ARB will be installed and your
active ARB version.

### Install arbitrary versions of ARB

You can install arbitrary versions of ARB by editing the Homebrew formula for
ARB and specifying a revision for the head build. This requires you to be a
brew expert user. If you don't know how to edit formulas you shouldn't do it.

Please keep in mind that the revision you are trying to install might contain
broken features or might not even compile (on a Mac) at all. Building older
revisions might even require to change the dependencies and/or build steps in
the formula. Please be aware that you build these revisions on you own risk and
that we cannot provide support for these builds.

## Switching between versions

When you install different versions of ARB you can switch between them using
the Homebrew's `unlink` and `link` command. You first need to unlink the version
your are currently using and then link the version you would like to use.

| ARB version | Unlink command      | Link command             |
| ----------- | ------------------- | ------------------------ |
| release     | `brew unlink arb@7` | `brew link arb@7`        |
| production  | `brew unlink arb`   | `brew link arb`          |
| stable      | `brew unlink arb@7` | `brew link --HEAD arb@7` |
| trunk       | `brew unlink arb`   | `brew link --HEAD arb`   |

## Configuration

`arb` supports several environment variables to customise parts of the
application as described in the [help](http://help.arb-home.de/arb_envar.html).
The following sections describe macOS specific values to be used for variables
which customise the external applications `arb` calls to view / edit files.

### `ARB_TEXTEDIT`

This variable defines the application `arb` starts for editing text files. On
macOS, this defaults to `TextEdit`. If you have set a different default text
editor for macOS and want to use it with `arb`, too, set the environment
variable to the following value:

```bash
export ARB_TEXTEDIT="open -t"
```

To use a different macOS application than your default text editor with `arb`,
you need to pass its name to the `open` command, e.g. for using the `BBEdit`
editor you would use the following value:

```bash
export ARB_TEXTEDIT="open -a BBEdit"
```

### `ARB_GS`

This variable defines the application that `arb` calls to show Postscript files.
If you do not set this variable, the default application registered for
Postscript files on your macOS will be used, the macOS default is `Apple
Preview`.

If you want to use a different application, e.g. Affinity Designer to open the
Postscript files from within ARB, you can use the following value:

```bash
export ARB_GS="open -W -a 'Affinity Designer'"
```

Please make sure that you add the `-W` option to the `open` command. Otherwise,
`arb` might delete the file before the other program reads it.

### `ARB_PDFVIEW`

This variable defines the application that `arb` calls to show PDF files. If you
do not set this variable, the default application registered for PDF files on
your macOS will be used, the macOS default is `Apple Preview`.

If you want to use a different application, e.g. Affinity Designer to open the
PDF files from within ARB, you can use the following value:

```bash
export ARB_PDFVIEW="open -W -a 'Affinity Designer'"
```

Please make sure that you add the `-W` option to the `open` command. Otherwise,
`arb` might delete the file before the other program reads it.
