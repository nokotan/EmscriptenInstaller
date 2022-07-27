function DownloadZip() {
    local DownloadUrl=$1
    local ZipName=$2

    if [ ! -e "${ZipName}" ]; then
        echo "Downloading ${ZipName} ..."
        curl ${DownloadUrl} > ${ZipName}
    fi
}

DownloadZip "https://storage.googleapis.com/webassembly/emscripten-releases-builds/win/8c9e0a76ebed2c5e88a718d43e8b62452def3771/wasm-binaries.zip" zips/emscripten-3.1.8.zip
DownloadZip "https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-v14.15.5-win-x64.zip" zips/emscripten-node.zip
DownloadZip "https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/python-3.9.2-1-embed-amd64+pywin32.zip" zips/emscripten-python.zip
DownloadZip "https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/portable_jre_8_update_152_64bit.zip" zips/emscripten-java.zip

function ExtractZip() {
    local ZipName=$1
    local TargetFolder=$2

    unzip ${ZipName} -d ${TargetFolder}
}

ExtractZip zips/emscripten-3.1.8.zip tmp/emscripten
ExtractZip zips/emscripten-node.zip tmp/node
ExtractZip zips/emscripten-python.zip tmp/python
ExtractZip zips/emscripten-java.zip tmp/java