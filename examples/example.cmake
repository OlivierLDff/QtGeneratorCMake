cmake_minimum_required(VERSION 3.14.0 FATAL_ERROR)

include(../cmake/GenerateQrc.cmake)
include(../cmake/GenerateQrcAliasQtObject.cmake)
include(../cmake/GenerateQmldir.cmake)

# Non recursive example

message(STATUS "qt_generate_qrc_alias_qt_object")
qt_generate_qrc_alias_qt_object(GENERATED_ALIAS_QML_FILENAME
  SOURCE_DIR qml
  NAME qml/Icons.qml
  PREFIX "My/Qrc/Prefix"
  GLOB_EXPRESSION "*.svg"
  SINGLETON
  VERBOSE)
message(STATUS "GENERATED_ALIAS_QML_FILENAME : ${GENERATED_ALIAS_QML_FILENAME}")

message(STATUS "qt_generate_qmldir non recursive")
qt_generate_qmldir(OUTPUT_QMLDIR_FILENAME
  SOURCE_DIR qml
  MODULE "My.Qrc.Prefix"
  VERBOSE)
message(STATUS "OUTPUT_QMLDIR_FILENAME : ${OUTPUT_QMLDIR_FILENAME}")

message(STATUS "qt_generate_qrc non recursive")
qt_generate_qrc(OUTPUT_QRC_FILENAME
  SOURCE_DIR qml
  NAME MyQrcFile.qrc
  PREFIX "My/Qrc/Prefix"
  GLOB_EXPRESSION "*.svg;*.qml"
  VERBOSE)
message(STATUS "OUTPUT_QRC_FILENAME : ${OUTPUT_QRC_FILENAME}")

message(STATUS "qt_generate_qrc non recursive outOfSource")
qt_generate_qrc(OUTPUT_QRC_FILENAME
  SOURCE_DIR qml
  DEST_DIR outOfSource
  NAME MyQrcFile.qrc
  PREFIX "My/Qrc/Prefix"
  GLOB_EXPRESSION "*.svg;*.qml"
  VERBOSE)
message(STATUS "OUTPUT_QRC_FILENAME : ${OUTPUT_QRC_FILENAME}")

# Recursive example

message(STATUS "qt_generate_qmldir recursive")
qt_generate_qmldir(OUTPUT_QMLDIR_FILENAME
  SOURCE_DIR recurse
  MODULE "My.Qrc.Prefix"
  RECURSE
  VERBOSE)
message(STATUS "OUTPUT_QMLDIR_FILENAME : ${OUTPUT_QMLDIR_FILENAME}")

message(STATUS "qt_generate_qrc recursive")
qt_generate_qrc(OUTPUT_QRC_FILENAME
  SOURCE_DIR recurse
  NAME MyQrcFile.qrc
  PREFIX "My/Qrc/Prefix"
  GLOB_EXPRESSION "*.svg;*.qml"
  RECURSE
  VERBOSE)
message(STATUS "OUTPUT_QRC_FILENAME : ${OUTPUT_QRC_FILENAME}")

message(STATUS "qt_generate_qrc recursive out of source")
qt_generate_qrc(OUTPUT_QRC_FILENAME
  SOURCE_DIR recurse
  DEST_DIR outOfSourceRecurse
  NAME MyQrcFile.qrc
  PREFIX "My/Qrc/Prefix"
  GLOB_EXPRESSION "*.svg;*.qml"
  RECURSE
  VERBOSE)
message(STATUS "OUTPUT_QRC_FILENAME : ${OUTPUT_QRC_FILENAME}")

file(GLOB_RECURSE RES_FILES LIST_DIRECTORIES true "*")

foreach(FILE ${RES_FILES})
  if(IS_DIRECTORY "${FILE}")
    message(STATUS "FILE ${FILE}")
  endif()
endforeach()