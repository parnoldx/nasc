project (com.github.parnold-x.nasc)
cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.6)

include(GNUInstallDirs)

add_definitions(-w)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if (NOT DEFINED DATADIR)
  set (DATADIR "${CMAKE_INSTALL_PREFIX}/share/nasc")
endif ()
if (NOT DEFINED STYLEDIR)
  set (STYLEDIR "${CMAKE_INSTALL_PREFIX}/share/qalculate/styles/")
endif ()
set (PKGDATADIR "${DATADIR}")
set (GETTEXT_PACKAGE "nasc")
set (RELEASE_NAME "nasc")
set (VERSION "0.4")
set (VERSION_INFO "Release")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")
add_definitions ("-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

file(GLOB_RECURSE sources src/*.vala)

# Some configuration
configure_file (${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_SOURCE_DIR}/src/config.vala)

#GSettings
include(GSettings)
add_schema("com.github.parnold-x.nasc.gschema.xml")

set(NEEDED_PKG
    glib-2.0
    gee-0.8
    gtk+-3.0
    granite
    libsoup-2.4
)

# Definitions
add_definitions (-DGETTEXT_PACKAGE="nasc")

find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED ${NEEDED_PKG} gthread-2.0 gtksourceview-3.0>=3.10 libqalculate)
add_definitions(${DEPS_CFLAGS})

add_subdirectory(libqalculatenasc)

link_directories(${DEPS_LIBRARY_DIRS})
link_directories(${CMAKE_BINARY_DIR})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.28.0" MINIMUM)
include(ValaPrecompile)
vala_precompile(VALA_C
    src/Nasc.vala
    src/MainWindow.vala
    src/config.vala
    src/Calculator.vala
    src/Controller.vala
    src/HelpBox.vala
    src/InputView.vala
    src/ListFooter.vala
    src/NascSettings.vala
    src/OpenBox.vala
    src/PasteBinDialog.vala
    src/PeriodicTable.vala
    src/ResultBoxWidget.vala
    src/ResultLine.vala
    src/ResultView.vala
    src/Tutorial.vala
PACKAGES
    ${NEEDED_PKG}
    gtksourceview-3.0
    posix
CUSTOM_VAPIS
    vapi/QalculateNasc.vapi
OPTIONS
  #  --enable-experimental
    --target-glib=2.32 # Remember to keep this updated.
  #  The --thread option is now deprecated.
  #  Should be ignored, but actually it leads to a build failure.
  #  --thread
  #  -X -rdynamic
  #  -g
)

#add_subdirectory (po)
include_directories(${CMAKE_BINARY_DIR})
include_directories(${CMAKE_SOURCE_DIR})
include_directories(${CMAKE_SOURCE_DIR}/libqalculatenasc)
add_executable(com.github.parnold-x.nasc ${VALA_C})
add_dependencies(com.github.parnold-x.nasc
    qalculatenasc)
target_link_libraries(com.github.parnold-x.nasc
  ${QALCULATE_LIB_PATH}
  ${DEPS_LIBRARIES}
  qalculatenasc
  -lcln)

install (TARGETS com.github.parnold-x.nasc RUNTIME DESTINATION bin)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.parnold-x.nasc.desktop DESTINATION share/applications)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.parnold-x.nasc.appdata.xml DESTINATION share/metainfo)
# install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/datasets/country.xml DESTINATION share/qalculate)
# install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/datasets/datasetsNasc.xml DESTINATION share/qalculate)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/16/com.github.parnold-x.nasc.svg DESTINATION share/icons/hicolor/16x16/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/24/com.github.parnold-x.nasc.svg DESTINATION share/icons/hicolor/24x24/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/32/com.github.parnold-x.nasc.svg DESTINATION share/icons/hicolor/32x32/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/48/com.github.parnold-x.nasc.svg DESTINATION share/icons/hicolor/48x48/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/64/com.github.parnold-x.nasc.svg DESTINATION share/icons/hicolor/64x64/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/128/com.github.parnold-x.nasc.svg DESTINATION share/icons/hicolor/128x128/apps)
install (FILES ${QALCULATE_LIB_PATH} DESTINATION ${CMAKE_INSTALL_LIBDIR})
install (DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/data/styles DESTINATION share/qalculate)
#overwrite the standard libqalculate datasets.xml with a extended one
# install (CODE
#     "execute_process (COMMAND cp -R /usr/share/qalculate/datasetsNasc.xml /usr/share/qalculate/datasets.xml)"
# )
# install (CODE
#     "execute_process (COMMAND rm /usr/share/qalculate/datasetsNasc.xml)"
# )
install (CODE
    "execute_process (COMMAND gtk-update-icon-cache /usr/share/icons/hicolor)"
)

# uninstall target
 configure_file(
     "${CMAKE_SOURCE_DIR}/cmake/Uninstall.cmake"
     "${CMAKE_CURRENT_BINARY_DIR}/Uninstall.cmake"
     IMMEDIATE @ONLY)

 add_custom_target(uninstall
     COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/Uninstall.cmake)
