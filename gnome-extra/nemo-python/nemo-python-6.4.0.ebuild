EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit meson

DESCRIPTION="libnemo-extension Python bindings"
HOMEPAGE="https://projects.linuxmint.com/cinnamon/ https://github.com/linuxmint/nemo-extensions"
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/nemo-extensions-${PV}/${PN}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~riscv x86"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
    ${PYTHON_DEPS}
	>=gnome-extra/nemo-2.0.0
	>=dev-libs/glib-2.14.0:2
	dev-python/setuptools
	x11-libs/gtk+:3
    $(python_gen_cond_dep '
        dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
"
RDEPEND="
    ${DEPEND}
"

