# Copyright (c) 2023-present, Qihoo, Inc.  All rights reserved.
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

INCLUDE(ExternalProject)

SET(OPENSSL_SOURCE_DIR ${THIRD_PARTY_PATH}/openssl)
SET(OPENSSL_INSTALL_DIR ${THIRD_PARTY_PATH}/install/openssl)
SET(OPENSSL_INCLUDE_DIR ${OPENSSL_INSTALL_DIR}/include)
SET(OPENSSL_CONFIGURE_COMMAND ${OPENSSL_SOURCE_DIR}/config)

FILE(MAKE_DIRECTORY ${OPENSSL_INCLUDE_DIR})

ExternalProject_Add(
        OpenSSL
        SOURCE_DIR ${OPENSSL_SOURCE_DIR}
        URL https://github.com/openssl/openssl/archive/refs/tags/openssl-3.2.1.tar.gz
        URL_HASH SHA256=75cc6803ffac92625c06ea3c677fb32ef20d15a1b41ecc8dddbc6b9d6a2da84c
        USES_TERMINAL_DOWNLOAD TRUE
        CONFIGURE_COMMAND
        ${OPENSSL_CONFIGURE_COMMAND}
        --prefix=${OPENSSL_INSTALL_DIR}
        --openssldir=${OPENSSL_INSTALL_DIR}
        BUILD_COMMAND make
        TEST_COMMAND ""
        INSTALL_COMMAND make install
        INSTALL_DIR ${OPENSSL_INSTALL_DIR}
)

SET(OPENSSL_INCLUDE_DIR ${THIRD_PARTY_PATH}/install/openssl/include)
SET(OPENSSL_ROOT_DIR ${THIRD_PARTY_PATH}/install/openssl/bin/openssl)

IF (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    SET(OPENSSL_LIBRARY_SUFFIX "dylib")
    SET(OPENSSL_LIB "lib")
    SET(OPENSSL_CRYPTO_LIBRARY ${THIRD_PARTY_PATH}/install/openssl/lib/libcrypto.dylib)
ELSEIF (CMAKE_SYSTEM_NAME MATCHES "Linux")
    SET(OPENSSL_LIBRARY_SUFFIX "so")
    SET(OPENSSL_LIB "lib64")
    SET(OPENSSL_CRYPTO_LIBRARY ${THIRD_PARTY_PATH}/install/openssl/lib64/libcrypto.so)
ELSE ()
    MESSAGE(FATAL_ERROR "only support linux or macOS")
ENDIF ()

ADD_LIBRARY(ssl STATIC IMPORTED GLOBAL)
SET_PROPERTY(TARGET ssl PROPERTY IMPORTED_LOCATION ${OPENSSL_INSTALL_DIR}/${OPENSSL_LIB}/libssl.${OPENSSL_LIBRARY_SUFFIX})
SET_PROPERTY(TARGET ssl PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR})
ADD_DEPENDENCIES(ssl OpenSSL)

ADD_LIBRARY(crypto STATIC IMPORTED GLOBAL)
SET_PROPERTY(TARGET crypto PROPERTY IMPORTED_LOCATION ${OPENSSL_INSTALL_DIR}/${OPENSSL_LIB}/libcrypto.${OPENSSL_LIBRARY_SUFFIX})
SET_PROPERTY(TARGET crypto PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR})
ADD_DEPENDENCIES(crypto OpenSSL)