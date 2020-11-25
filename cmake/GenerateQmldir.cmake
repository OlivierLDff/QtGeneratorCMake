include(CMakeParseArguments)

function(__qt_generate_qmldir VAR)

  set(QT_QRC_OPTIONS
    VERBOSE
  )
  set(QT_QRC_ONE_VALUE_ARG
    SOURCE_DIR
    MODULE
  )
  set(QT_QRC_MULTI_VALUE_ARG
  )

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

  if(RES_FILES)

    set(OUT_CONTENT "")

    string(APPEND OUT_CONTENT
      "# File auto generated with CMake qt_generate_qmldir. Run CMake to regenerate if files changed.\n"
      "\n"
      "module ${ARGGEN_MODULE}\n\n")

    foreach(RES_FILE ${RES_FILES})

      file(READ ${RES_FILE} QML_FILE_TXT)
      string(FIND "${QML_FILE_TXT}" "pragma Singleton" MATCH_SINGLETON)

      get_filename_component(FILENAME ${RES_FILE} NAME)
      get_filename_component(FILENAME_WE ${RES_FILE} NAME_WE)

      if(${MATCH_SINGLETON} EQUAL -1)

        string(APPEND OUT_CONTENT "${FILENAME_WE} 1.0 ${FILENAME}\n")
        if(ARGGEN_VERBOSE)
          message(STATUS "Add ${FILENAME} in ${OUT_FILENAME}")
        endif()

      else()

        string(APPEND OUT_CONTENT "singleton ${FILENAME_WE} 1.0 ${FILENAME}\n")
        if(ARGGEN_VERBOSE)
          message(STATUS "Add Singleton ${FILENAME} in ${OUT_FILENAME}")
        endif()

      endif()
    endforeach()

    # Write file to temp then copy to original if there are diff
    file(WRITE ${OUT_FILENAME_ABS}.temp ${OUT_CONTENT})
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different ${OUT_FILENAME_ABS}.temp ${OUT_FILENAME_ABS})
    file(REMOVE ${OUT_FILENAME_ABS}.temp)

  endif()

endfunction()

# Generate a qmldir file that embed every qml file inside a folder.
#
# Example:
# qt_generate_qmldir(OUTPUT_QMLDIR_FILENAMES
#  SOURCE_DIR path/to/qml/folder
#  MODULE "MyModule.Example"
#  RECURSE
#  VERBOSE)
#
# Usage:
# qt_generate_qmldir(<var> [options...])
#
# VAR: Absolute path to the generated qrc file
# - SOURCE_DIR: folder containing file to pack in qrc
#               The file is also generated in that folder
# - MODULE: Name of the module
# - RECURSE: Generate a `qmldir` for every subdirectory too.
# - VERBOSE: Dump useful information for developer.
#
function(qt_generate_qmldir VAR)

  set(QT_QRC_OPTIONS RECURSE VERBOSE)
  set(QT_QRC_ONE_VALUE_ARG SOURCE_DIR
    MODULE
    )
  set(QT_QRC_MULTI_VALUE_ARG)

  # parse the macro arguments
  cmake_parse_arguments(ARGGEN "${QT_QRC_OPTIONS}" "${QT_QRC_ONE_VALUE_ARG}" "${QT_QRC_MULTI_VALUE_ARG}" ${ARGN})

  # Create a list of every sub directories
  file(GLOB_RECURSE RECURSE_FILES LIST_DIRECTORIES true "${ARGGEN_SOURCE_DIR}/*")

  # And also append SOURCE_DIR
  get_filename_component(SOURCE_DIR_ABS ${ARGGEN_SOURCE_DIR} ABSOLUTE)
  list(APPEND RECURSE_FILES ${SOURCE_DIR_ABS})

  foreach(DIR ${RECURSE_FILES})
    if(IS_DIRECTORY "${DIR}")

      if(ARGGEN_VERBOSE)
        message(STATUS "Generate qmldir for ${DIR}")
      endif()

      # Create module suffix from relative path between SOURCE_DIR and current DIR
      file(RELATIVE_PATH REL_DIR_PATH "${SOURCE_DIR_ABS}" "${DIR}")
      string(REPLACE "/" "." MODULE_SUFFIX "${REL_DIR_PATH}")
      if(MODULE_SUFFIX)
        set(MODULE_SUFFIX ".${MODULE_SUFFIX}")
      endif()

      # Create arguments for __qt_generate_qmldir
      if(ARGGEN_SOURCE_DIR)
        set(SOURCE_DIR "SOURCE_DIR" "${DIR}")
      endif()
      if(ARGGEN_MODULE)
        set(MODULE "MODULE" "${ARGGEN_MODULE}${MODULE_SUFFIX}")
      endif()
      if(ARGGEN_VERBOSE)
        set(VERBOSE "VERBOSE")
      endif()

      # Call real implementation
      __qt_generate_qmldir(OUTPUT_VAR
        ${SOURCE_DIR}
        ${MODULE}
        ${VERBOSE})

      # And keep track of output variable
      list(APPEND OUTPUT_VARS ${OUTPUT_VAR})
    endif()
  endforeach()

  # Copy all qmldir list to PARENT_SCOPE in variable VAR
  set(${VAR} ${OUTPUT_VARS} PARENT_SCOPE)

endfunction()
