EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{10..13} pypy3 )

inherit distutils-r1

DESCRIPTION="Context menu comparison extension for Nemo file manager"
HOMEPAGE="https://projects.linuxmint.com/cinnamon/ https://github.com/linuxmint/nemo-extensions"
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/nemo-extensions-${PV}/${PN}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~riscv x86"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND="
    ${PYTHON_DEPS}
"
DEPEND="
    ${COMMON_DEPS}
    dev-python/setuptools
"
RDEPEND="
    ${COMMON_DEPS}
    $(python_gen_cond_dep '
        dev-python/pygobject:3[${PYTHON_USEDEP}]
    ')
    >=gnome-extra/nemo-2.0.0
    >=gnome-extra/nemo-python-3.8.0
"

# src_compile() {
#     distutils-r1_src_compile
# }
# src_install() {
#     distutils-r1_src_install --root="${D} --prefix=/usr"
# }

