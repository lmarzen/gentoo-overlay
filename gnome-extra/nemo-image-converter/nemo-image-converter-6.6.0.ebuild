EAPI=8

inherit meson

DESCRIPTION="The Nemo-Image-Converter extension allows you to resize/rotate images from Nemo"
HOMEPAGE="https://projects.linuxmint.com/cinnamon/ https://github.com/linuxmint/nemo-extensions"
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/nemo-extensions-${PV}/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~riscv x86"

DEPEND="
	>=dev-libs/glib-2.14.0:2
	>=gnome-extra/nemo-2.0.0
"
RDEPEND="
	${DEPEND}
"
