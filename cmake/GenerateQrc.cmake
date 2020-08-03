include(CMakeParseArguments)

# Generate a qrc file that pack every file inside a folder.
#
# Example:
# qt_generate_qrc(OUTPUT_QRC_FILENAME
#  SOURCE_DIR path/to/qml/folder
#  NAME MyQrcFile.qrc
#  PREFIX "My/Qrc/Prefix"
#  GLOB_EXPRESSION "*.svg;*.qml")
#
# Usage:
# qt_generate_qrc(<var> [options...])
#
# VAR: Absolute path to the generated qrc file
# - PREFIX: qrc prefix for every file in folder. <qresource prefix="/${PREFIX}">
# - SOURCE_DIR: folder containing file to pack in qrc
#               The file is also generated in that folder if DEST_DIR isn't specified
# - DEST_DIR: folder that will contain the output .qrc file. Default to SOURCE_DIR if not specified
# - NAME: Name of the file (should include .qrc extension, or whatever extension you want)
# - GLOB_EXPRESSION: Expression to filter which files are going to be embedded in the qrc.
# - RECURSE: Also traverse subdirectory when generating qrc file.
# - VERBOSE: Dump useful information for developer.
#
function(qt_generate_qrc VAR)

  set(QT_QRC_OPTIONS VERBOSE RECURSE)
  set(QT_QRC_ONE_VALUE_ARG PREFIX
    SOURCE_DIR
    DEST_DIR
    NAME
    )
  set(QT_QRC_MULTI_VALUE_ARG GLOB_EXPRESSION)

  # parse the macro arguments
  cmake_parse_arguments(ARGGEN "${QT_QRC_OPTIONS}" "${QT_QRC_ONE_VALUE_ARG}" "${QT_QRC_MULTI_VALUE_ARG}" ${ARGN})

  # Create correct filename
  if(ARGGEN_DEST_DIR)
    set(OUT_FILE_DEST_DIR ${ARGGEN_DEST_DIR})
    file(MAKE_DIRECTORY ${OUT_FILE_DEST_DIR})
  else()
    set(OUT_FILE_DEST_DIR ${ARGGEN_SOURCE_DIR})
  endif()
  set(OUT_FILENAME ${OUT_FILE_DEST_DIR}/${ARGGEN_NAME})
  get_filename_component(OUT_FILENAME_ABS ${OUT_FILENAME} ABSOLUTE)
  get_filename_component(SOURCE_DIR_ABS ${ARGGEN_SOURCE_DIR} ABSOLUTE)
  get_filename_component(DEST_DIR_ABS ${OUT_FILE_DEST_DIR} ABSOLUTE)

  # Set output variable
  set(${VAR} ${OUT_FILENAME_ABS} PARENT_SCOPE)

  if(NOT ARGGEN_GLOB_EXPRESSION)
    set(ARGGEN_GLOB_EXPRESSION "*")
  endif()

  list(TRANSFORM ARGGEN_GLOB_EXPRESSION PREPEND "${ARGGEN_SOURCE_DIR}/")

  if(ARGGEN_RECURSE)
    set(FILE_GLOBBING GLOB_RECURSE)
  else()
    set(FILE_GLOBBING GLOB)
  endif()

  file(${FILE_GLOBBING} RES_FILES
    RELATIVE ${SOURCE_DIR_ABS}
    LIST_DIRECTORIES false
    ${ARGGEN_GLOB_EXPRESSION}
  )

  file(WRITE ${OUT_FILENAME_ABS}
    "<!-- File auto generated with CMake qt_generate_qrc. Everything written here will be lost. -->\n"
    "<RCC>\n"
    "  <qresource prefix=\"/${ARGGEN_PREFIX}\">\n")

  foreach(RES_FILE ${RES_FILES})
    get_filename_component(FILENAME ${RES_FILE} NAME)
    get_filename_component(FILENAME_EXT ${RES_FILE} LAST_EXT)
    get_filename_component(FILENAME_DIR ${RES_FILE} DIRECTORY)
    if(FILENAME_DIR)
      set(FILENAME_DIR ${FILENAME_DIR}/)
    endif()

    # Get Relative filepath for alias in qrc
    set(RES_FILE_ABS ${SOURCE_DIR_ABS}/${RES_FILE})
    file(RELATIVE_PATH REL_FILE_PATH "${DEST_DIR_ABS}" "${RES_FILE_ABS}")

    if(NOT FILENAME_EXT OR NOT ${FILENAME_EXT} STREQUAL ".qrc")

      if(${REL_FILE_PATH} STREQUAL ${FILENAME_DIR}${FILENAME})
        file(APPEND ${OUT_FILENAME_ABS} "    <file>${REL_FILE_PATH}</file>\n")
      else()
        file(APPEND ${OUT_FILENAME_ABS} "    <file alias=\"${FILENAME_DIR}${FILENAME}\">${REL_FILE_PATH}</file>\n")
      endif()

      if(ARGGEN_VERBOSE)
        message(STATUS "Add ${FILENAME_DIR}${FILENAME} in ${ARGGEN_NAME}")
      endif()

    endif()
  endforeach()

  file(APPEND ${OUT_FILENAME_ABS}
    "  </qresource>\n"
    "</RCC>\n")

endfunction()
