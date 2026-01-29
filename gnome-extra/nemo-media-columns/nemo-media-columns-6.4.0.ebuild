EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{10..15} )

inherit distutils-r1

DESCRIPTION="Column provider for nemo to show additional metadata for media and image files"
HOMEPAGE="https://projects.linuxmint.com/cinnamon/ https://github.com/linuxmint/nemo-extensions"
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/nemo-extensions-${PV}/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm64 x86"
# ~riscv lacks support for dev-python/pymediainfo
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
    media-libs/mutagen
    dev-python/pypdf
    dev-python/pillow
    dev-python/pymediainfo
"
    # dev-python/stopit

src_install() {
    insinto /usr/share/nemo-python/extensions
    doins ${S}/nemo-media-columns.py
    fperms +x /usr/share/nemo-python/extensions/nemo-media-columns.py
    insinto /usr/bin
    doins ${S}/nemo-media-columns-prefs
    fperms +x /usr/bin/nemo-media-columns-prefs
    insinto /usr/share/glib-2.0/schemas
    doins ${S}/org.nemo.extensions.nemo-media-columns.gschema.xml
}
