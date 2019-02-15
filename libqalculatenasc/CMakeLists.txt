pkg_check_modules(QALC REQUIRED libqalculate)
link_directories(${QALC_LIBRARY_DIRS})
include_directories(${QALC_INCLUDE_DIRS})
 add_library(qalculatenasc STATIC
  QalculateNasc.cc)
target_link_libraries(qalculatenasc ${QALC_LIBRARIES} -lcln)

