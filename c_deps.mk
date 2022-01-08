# This Makefile deals with building libipt. It is symlinked into OUT_DIR at
# build time by build.rs.

DIR != pwd
INST_DIR = ${DIR}/inst

XDC_REPO = https://github.com/nyx-fuzz/libxdc
XDC_V = 407d8ef2a5f9001b90bba0b9f5135cc71aa1f57b
XDC_SOURCE = libxdc

CAPSTONE_REPO = https://github.com/capstone-engine/capstone
CAPSTONE_V = 0efa3cc530ea188c0e03c945ab884ee19dd16342 # v4 branch
CAPSTONE_SOURCE = capstone

all: ${INST_DIR}/lib/libxdc.a

# Fetch targets
.PHONY: ${XDC_SOURCE}
${XDC_SOURCE}:
	if ! [ -d ${XDC_SOURCE} ]; then \
		git clone ${XDC_REPO}; \
	else \
		cd ${XDC_SOURCE} && git fetch; \
	fi
	cd ${XDC_SOURCE} && git checkout ${XDC_V}

.PHONY: ${CAPSTONE_SOURCE}
${CAPSTONE_SOURCE}:
	if ! [ -d ${CAPSTONE_SOURCE} ]; then \
		git clone ${CAPSTONE_REPO}; \
	else \
		cd ${CAPSTONE_SOURCE} && git fetch; \
	fi
	cd ${CAPSTONE_SOURCE} && git checkout ${CAPSTONE_V}

# Build targets
${INST_DIR}/lib/libxdc.a: ${XDC_SOURCE} ${INST_DIR}/lib/libcapstone.a
	cd ${XDC_SOURCE} && \
		env CFLAGS"=-I${INST_DIR}/include/capstone -Wno-error" \
		LDFLAGS="-L${INST_DIR}/lib" \
		${MAKE} install PREFIX=${INST_DIR}

${INST_DIR}/lib/libcapstone.a: ${CAPSTONE_SOURCE}
	mkdir ${CAPSTONE_SOURCE}/build || true
	cd ${CAPSTONE_SOURCE}/build && \
		cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${INST_DIR}" -DCAPSTONE_SHARED=OFF -DCAPSTONE_STATIC=ON -DCAPSTONE_ARCHITECTURE_DEFAULT=OFF -DCAPSTONE_X86_SUPPORT=ON .. && \
		${MAKE} && ${MAKE} install

clean:
	rm -rf ${INST_DIR} ${XDC_SOURCE} ${CAPSTONE_SOURCE}
