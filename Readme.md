# QtGeneratorCMake

Collection of CMake function to generate `qrc`, `qmldir` files for qt applications.

## 🧰 Generate Qrc

Generate a qrc file that pack every file inside a folder.

Example:

```cmake
qt_generate_qrc(OUTPUT_QRC_FILENAME
 SOURCE_DIR path/to/qml/folder
 NAME MyQrcFile.qrc
 PREFIX "My/Qrc/Prefix"
 GLOB_EXPRESSION "*.svg;*.qml")
```

Usage: `qt_generate_qrc(<var> [options...])`

* **VAR**: Absolute path to the generated qrc file

- **PREFIX**: qrc prefix for every file in folder. `<qresource prefix="/${PREFIX}">`
- **SOURCE_DIR**: folder containing file to pack in qrc. The file is also generated in that folder.
- **NAME**: Name of the file (should include .qrc extension, or whatever extension you want)
- **GLOB_EXPRESSION**: Expression to filter which file are going to be embedded in the qrc.

## 🔨 Generate Qmldir

Generate a qmldir file that embed every qml file inside a folder.

Example:

```cmake
qt_generate_qmldir(OUTPUT_QMLDIR_FILENAME
 SOURCE_DIR path/to/qml/folder
 MODULE "MyModule.Example")
```

Usage : `qt_generate_qmldir(<var> [options...])`

* **VAR**: Absolute path to the generated qrc file

- **SOURCE_DIR**: folder containing file to pack in qrc. The file is also generated in that folder
- **MODULE**: Name of the module

> You should call `qt_generate_qmldir` before `qt_generate_qrc` if you want the `qmldir` file to be embedded inside the `qrc` file.

## 🧬 Generate Qrc Alias

Generate a QtObject with property string containing full qrc path to file. This is useful for example if you want a singleton referencing icons or images with readable property name.

Example:

```cmake
qt_generate_qrc_alias_qt_object(GENERATED_ALIAS_QML_FILENAME
  SOURCE_DIR path/to/qml/folder
  NAME path/to/qml/folder/Icons.qml
  PREFIX "My/Qrc/Prefix"
  GLOB_EXPRESSION "*.svg"
  SINGLETON)
```

Usage: `qt_generate_qrc_alias_qt_object(<var> [options...])`

* **VAR**: Absolute path to the generated qml file

- **SOURCE_DIR**: folder containing file to pack in qrc. The file is also generated in that folder.
- **NAME**: Name of the qml file. Can be relative or absolute
- **GLOB_EXPRESSION**: Expression to filter which file are going to be embedded in the qrc.
- **SINGLETON**: Should the object be a singleton. This add a `pragma Singleton` on the first line.

## 🎎 Example

The folder `example` contains an example of every functions in `example/example.cmake`.

Run the example as a script:

```bash
cd example
cmake -P example.cmake
```

Run the example as a cmake project:

```bash
mkdir example/build && cd example/build
cmake ..
```

# 💡 Ideas

* Generate Qrc : 
  * RECURSIVE options
  * OUTPUT_DIR that have relative path to current dir