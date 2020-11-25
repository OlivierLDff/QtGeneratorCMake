include(CMakeParseArguments)

# Generate a QtObject with property string containing full qrc path to file.
#
# Example:
# qt_generate_qrc_alias_qt_object(GENERATED_ALIAS_QML_FILENAME
#   SOURCE_DIR path/to/qml/folder
#   NAME path/to/qml/folder/Icons.qml
#   PREFIX "My/Qrc/Prefix"
#   GLOB_EXPRESSION "*.svg"
#   SINGLETON)
#
# Usage:
# qt_generate_qrc_alias_qt_object(<var> [options...])
#
# VAR: Absolute path to the generated qml file
# - SOURCE_DIR: folder containing file to pack in qrc
#               The file is also generated in that folder
# - NAME: Name of the qml file. Can be relative or absolute
# - PREFIX: Prefix appended inside each property value
# - GLOB_EXPRESSION: Expression to filter which file are going to be embedded in the qrc.
# - SINGLETON: Should the object be a singleton
#
function(qt_generate_qrc_alias_qt_object VAR)

  set(QT_QRC_OPTIONS SINGLETON ALWAYS_OVERWRITE)
  set(QT_QRC_ONE_VALUE_ARG PREFIX
    SOURCE_DIR
    NAME
    )
  set(QT_QRC_MULTI_VALUE_ARG GLOB_EXPRESSION)

  # parse the macro arguments
  cmake_parse_arguments(ARGGEN "${QT_QRC_OPTIONS}" "${QT_QRC_ONE_VALUE_ARG}" "${QT_QRC_MULTI_VALUE_ARG}" ${ARGN})

  # Create correct filename
  set(OUT_FILENAME ${ARGGEN_NAME})
  get_filename_component(OUT_FILENAME_ABS ${OUT_FILENAME} ABSOLUTE)
  # Set output variable
  set(${VAR} ${OUT_FILENAME_ABS} PARENT_SCOPE)

  if(ARGGEN_ALWAYS_OVERWRITE OR NOT EXISTS ${OUT_FILENAME_ABS})

    if(NOT ARGGEN_GLOB_EXPRESSION)
      set(ARGGEN_GLOB_EXPRESSION "*")
    endif()

    list(TRANSFORM ARGGEN_GLOB_EXPRESSION PREPEND "${ARGGEN_SOURCE_DIR}/")

    # Fetch file that are going to be turned into properties
    file(GLOB RES_FILES ${ARGGEN_GLOB_EXPRESSION})

    set(OUT_CONTENT "")
    # Write Header
    string(APPEND OUT_CONTENT
      "// File auto generated with CMake qt_generate_qrc_alias_singleton.\n"
      "// Everything written here will be lost.\n\n")
    if(ARGGEN_SINGLETON)
    string(APPEND OUT_CONTENT
      "pragma Singleton\n\n")
    endif()
    string(APPEND OUT_CONTENT
      "import QtQml 2.0\n\n"
      "QtObject\n"
      "{\n")
    set(QRC_PATH "qrc:/${ARGGEN_PREFIX}")

    foreach(RES_FILE ${RES_FILES})
      get_filename_component(FILENAME_WE ${RES_FILE} NAME_WE)
      get_filename_component(FILENAME ${RES_FILE} NAME)
      get_filename_component(FILENAME_EXT ${RES_FILE} LAST_EXT)

      if(NOT ${FILENAME_EXT} STREQUAL ".qrc")

        set(PROPERTY_NAME_LIST ${FILENAME_WE})
        # Create a list
        string(REGEX REPLACE "[_ -]" ";" PROPERTY_NAME_LIST ${PROPERTY_NAME_LIST})

        set(PROPERTY_NAME "")

        set(PROPERTY_WORD_INDEX 0)
        foreach(PROPERTY_WORD ${PROPERTY_NAME_LIST})
          if(PROPERTY_WORD_INDEX EQUAL 0)
            string(SUBSTRING ${PROPERTY_WORD} 0 1 FIRST_LETTER)
            string(TOLOWER ${FIRST_LETTER} FIRST_LETTER)
            string(REGEX REPLACE "^.(.*)" "${FIRST_LETTER}\\1" PROPERTY_WORD "${PROPERTY_WORD}")
          else()
            string(SUBSTRING ${PROPERTY_WORD} 0 1 FIRST_LETTER)
            string(TOUPPER ${FIRST_LETTER} FIRST_LETTER)
            string(REGEX REPLACE "^.(.*)" "${FIRST_LETTER}\\1" PROPERTY_WORD "${PROPERTY_WORD}")
          endif()
          set(PROPERTY_NAME "${PROPERTY_NAME}${PROPERTY_WORD}")
          math(EXPR PROPERTY_WORD_INDEX "${PROPERTY_WORD_INDEX}+1")
        endforeach()

        set(FORBIDDEN_PROPERTY_WORDS id index model modelData console do if in for let new try var case else enum eval null this true void with await break catch class const false super throw while yield delete export import public return static switch typeof default extends finally package private continue debugger function arguments interface protected implements instanceof)

        if (${PROPERTY_NAME} IN_LIST FORBIDDEN_PROPERTY_WORDS)
          set(PROPERTY_NAME ${PROPERTY_NAME}_)
        endif()

        string(APPEND OUT_CONTENT
          "  "
          "readonly property string ${PROPERTY_NAME}: "
          "'${QRC_PATH}/${FILENAME}'\n")
      endif()
    endforeach()

    string(APPEND OUT_CONTENT  "}\n")

    # Write file to temp then copy to original if there are diff
    file(WRITE ${OUT_FILENAME_ABS}.temp ${OUT_CONTENT})
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different ${OUT_FILENAME_ABS}.temp ${OUT_FILENAME_ABS})
    file(REMOVE ${OUT_FILENAME_ABS}.temp)

  else()
    message(STATUS "${OUT_FILENAME_ABS} already generated, skip generation for faster cmake.")
  endif() # EXISTS OUT_FILENAME_ABS

endfunction()
