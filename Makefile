# $FreeBSD: stable/10/lib/libfetch/Makefile 240496 2012-09-14 13:00:43Z des $

.include <bsd.own.mk>

.if defined(NO_SANDBOX) && defined(SANDBOX_SSL)
.error NO_SANDBOX and SANDBOX_SSL cannot both be specified
.endif

LIB=		fetch
CFLAGS+=	-I.
SRCS=		fetch.c common.c ssl_sandbox.c ftp.c http.c file.c \
		ftperr.h httperr.h
INCS=		fetch.h
MAN=		fetch.3
CLEANFILES=	ftperr.h httperr.h

.if ${MK_INET6_SUPPORT} != "no"
CFLAGS+=	-DINET6
.endif

.if ${MK_OPENSSL} != "no"
CFLAGS+=	-DWITH_SSL
DPADD=		${LIBSSL} ${LIBCRYPTO}
LDADD=		-lssl -lcrypto
.ifdef SANDBOX_SSL
LIBSEP_DIR?= ../libsep
CFLAGS+=	-I${LIBSEP_DIR} -DSANDBOX_SSL
DPADD+=		${LIBSEP_DIR}
LDADD+=		-L${LIBSEP_DIR} -lsep
.else
CFLAGS+=	-DNO_SANDBOX
.endif
.else
DPADD=		${LIBMD}
LDADD=		-lmd
.endif

CFLAGS+=	-DFTP_COMBINE_CWDS

.ifdef DEBUG
CFLAGS+=  -g
.endif

CSTD?=		c99

SHLIB_MAJOR=    6

ftperr.h: ftp.errors ${.CURDIR}/Makefile
	@echo "static struct fetcherr ftp_errlist[] = {" > ${.TARGET}
	@cat ${.CURDIR}/ftp.errors \
	  | grep -v ^# \
	  | sort \
	  | while read NUM CAT STRING; do \
	    echo "    { $${NUM}, FETCH_$${CAT}, \"$${STRING}\" },"; \
	  done >> ${.TARGET}
	@echo "    { -1, FETCH_UNKNOWN, \"Unknown FTP error\" }" >> ${.TARGET}
	@echo "};" >> ${.TARGET}

httperr.h: http.errors ${.CURDIR}/Makefile
	@echo "static struct fetcherr http_errlist[] = {" > ${.TARGET}
	@cat ${.CURDIR}/http.errors \
	  | grep -v ^# \
	  | sort \
	  | while read NUM CAT STRING; do \
	    echo "    { $${NUM}, FETCH_$${CAT}, \"$${STRING}\" },"; \
	  done >> ${.TARGET}
	@echo "    { -1, FETCH_UNKNOWN, \"Unknown HTTP error\" }" >> ${.TARGET}
	@echo "};" >> ${.TARGET}

MLINKS+= fetch.3 fetchFreeURL.3
MLINKS+= fetch.3 fetchGet.3
MLINKS+= fetch.3 fetchGetFTP.3
MLINKS+= fetch.3 fetchGetFile.3
MLINKS+= fetch.3 fetchGetHTTP.3
MLINKS+= fetch.3 fetchGetURL.3
MLINKS+= fetch.3 fetchList.3
MLINKS+= fetch.3 fetchListFTP.3
MLINKS+= fetch.3 fetchListFile.3
MLINKS+= fetch.3 fetchListHTTP.3
MLINKS+= fetch.3 fetchListURL.3
MLINKS+= fetch.3 fetchMakeURL.3
MLINKS+= fetch.3 fetchParseURL.3
MLINKS+= fetch.3 fetchPut.3
MLINKS+= fetch.3 fetchPutFTP.3
MLINKS+= fetch.3 fetchPutFile.3
MLINKS+= fetch.3 fetchPutHTTP.3
MLINKS+= fetch.3 fetchPutURL.3
MLINKS+= fetch.3 fetchStat.3
MLINKS+= fetch.3 fetchStatFTP.3
MLINKS+= fetch.3 fetchStatFile.3
MLINKS+= fetch.3 fetchStatHTTP.3
MLINKS+= fetch.3 fetchStatURL.3
MLINKS+= fetch.3 fetchXGet.3
MLINKS+= fetch.3 fetchXGetFTP.3
MLINKS+= fetch.3 fetchXGetFile.3
MLINKS+= fetch.3 fetchXGetHTTP.3
MLINKS+= fetch.3 fetchXGetURL.3

.include <bsd.lib.mk>

sandbox_fetch:
.ifdef DEBUG
	make -DSANDBOX_FETCH -DDEBUG
.else
	make -DSANDBOX_FETCH
.endif

sandbox_parse:
.ifdef DEBUG
	make -DSANDBOX_PARSE_URL -DDEBUG
.else
	make -DSANDBOX_PARSE_URL
.endif
