#
# Copyright (c) 2015 CoreOS, Inc.. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header:$
#

EAPI=5
CROS_WORKON_PROJECT="coreos/etcd"
CROS_WORKON_LOCALNAME="etcd"
CROS_WORKON_REPO="git://github.com"
COREOS_GO_PACKAGE="github.com/coreos/etcd"
inherit coreos-go toolchain-funcs cros-workon systemd

if [[ "${PV}" == 9999 ]]; then
    CROS_WORKON_COMMIT=${CROS_WORKON_COMMIT:="HEAD"}
    KEYWORDS="~amd64 ~arm64"
else
    CROS_WORKON_COMMIT="fd17c9101d94703f6f4c3d8d6cfb72b62b894cd7" # v2.3.7
    KEYWORDS="amd64 arm64"
fi

DESCRIPTION="etcd"
HOMEPAGE="https://github.com/coreos/etcd"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="2"
IUSE="+etcdctl"

RDEPEND="!dev-db/etcd:0
	etcdctl? ( !dev-db/etcdctl )"

src_compile() {
	GO_LDFLAGS="-X ${COREOS_GO_PACKAGE}/version.GitSHA=${CROS_WORKON_COMMIT:0:7}"
	go_build "${COREOS_GO_PACKAGE}"
	use etcdctl && go_build "${COREOS_GO_PACKAGE}/etcdctl"
}

src_install() {
	use etcdctl && dobin ${WORKDIR}/gopath/bin/etcdctl
	newbin "${WORKDIR}/gopath/bin/${PN}" "${PN}${SLOT}"

	systemd_dounit "${FILESDIR}/${PN}${SLOT}.service"
	systemd_dotmpfilesd "${FILESDIR}/${PN}${SLOT}.conf"
}
