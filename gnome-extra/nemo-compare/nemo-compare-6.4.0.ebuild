EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} pypy3 )

inherit distutils-r1

DESCRIPTION="Context menu comparison extension for Nemo file manager"
HOMEPAGE="https://projects.linuxmint.com/cinnamon/ https://github.com/linuxmint/nemo-extensions"
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/nemo-extensions-${PV}/${PN}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~riscv x86"
# REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="
	>=gnome-extra/nemo-2.0.0
	>=gnome-extra/nemo-python-3.8.0
"
DEPEND="
    ${COMMON_DEPS}
	>=dev-libs/glib-2.14.0:2
	dev-python/setuptools
"
RDEPEND="
    ${COMMON_DEPS}

"

src_install() {
    # Create target directory
    insinto /usr/share/nemo-compare
    #
    # # Install files
    # doins ${S}/src/nemo-compare.py
    # doins ${S}/src/utils.py
    # doins ${S}/src/nemo-compare-preferences.py
}
