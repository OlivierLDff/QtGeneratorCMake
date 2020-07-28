include(CMakeParseArguments)

# Generate a qmldir file that embed every qml file inside a folder.
#
# Example:
# qt_generate_qmldir(OUTPUT_QMLDIR_FILENAME
#  SOURCE_DIR path/to/qml/folder
#  MODULE "MyModule.Example")
#
# Usage:
# qt_generate_qmldir(<var> [options...])
#
# VAR: Absolute path to the generated qrc file
# - SOURCE_DIR: folder containing file to pack in qrc
#               The file is also generated in that folder
# - MODULE: Name of the module
#
function(qt_generate_qmldir VAR)

  set(QT_QRC_OPTIONS VERBOSE)
  set(QT_QRC_ONE_VALUE_ARG SOURCE_DIR
    MODULE
    )
  set(QT_QRC_MULTI_VALUE_ARG)

  # parse the macro arguments
  cmake_parse_arguments(ARGGEN "${QT_QRC_OPTIONS}" "${QT_QRC_ONE_VALUE_ARG}" "${QT_QRC_MULTI_VALUE_ARG}" ${ARGN})

  # Create correct filename
  set(OUT_FILENAME ${ARGGEN_SOURCE_DIR}/qmldir)
  get_filename_component(OUT_FILENAME_ABS ${OUT_FILENAME} ABSOLUTE)
  # Set output variable
  set(${VAR} ${OUT_FILENAME_ABS} PARENT_SCOPE)

  if(NOT ARGGEN_GLOB_EXPRESSION)
    set(ARGGEN_GLOB_EXPRESSION "*.qml")
  endif()

  list(TRANSFORM ARGGEN_GLOB_EXPRESSION PREPEND "${ARGGEN_SOURCE_DIR}/")

  file(GLOB RES_FILES ${ARGGEN_GLOB_EXPRESSION})

  file(WRITE ${OUT_FILENAME_ABS}
    "# File auto generated with CMake qt_generate_qmldir. Run CMake to regenerate if files changed.\n"
    "\n"
    "module ${ARGGEN_MODULE}\n\n")

  foreach(RES_FILE ${RES_FILES})

    file(READ ${RES_FILE} QML_FILE_TXT)
    string(FIND "${QML_FILE_TXT}" "pragma Singleton" MATCH_SINGLETON)

    get_filename_component(FILENAME ${RES_FILE} NAME)
    get_filename_component(FILENAME_WE ${RES_FILE} NAME_WE)

    if(${MATCH_SINGLETON} EQUAL -1)

      file(APPEND ${OUT_FILENAME_ABS} "${FILENAME_WE} 1.0 ${FILENAME}\n")
      if(ARGGEN_VERBOSE)
        message(STATUS "Add ${FILENAME} in ${OUT_FILENAME}")
      endif()

    else()

      file(APPEND ${OUT_FILENAME_ABS} "singleton ${FILENAME_WE} 1.0 ${FILENAME}\n")
      if(ARGGEN_VERBOSE)
        message(STATUS "Add Singleton ${FILENAME} in ${OUT_FILENAME}")
      endif()

    endif()
  endforeach()

endfunction()
