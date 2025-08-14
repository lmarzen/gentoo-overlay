# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} pypy3 )

inherit distutils-r1

DESCRIPTION="Context menu comparison extension for Nemo file manager"
HOMEPAGE="https://projects.linuxmint.com/cinnamon/ https://github.com/linuxmint/nemo-extensions"
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/nemo-extensions-${PV}/${PN}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~riscv x86"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
    ${PYTHON_DEPS}
	>=dev-libs/glib-2.14.0:2
	>=gnome-extra/nemo-2.0.0
"
RDEPEND="
	dev-util/meld
"

python_compile_all() {
    distutils-r1_python_compile_all
}
