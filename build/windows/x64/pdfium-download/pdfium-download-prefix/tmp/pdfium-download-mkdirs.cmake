# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "D:/flutter project/receptions_app/build/windows/x64/pdfium-src"
  "D:/flutter project/receptions_app/build/windows/x64/pdfium-build"
  "D:/flutter project/receptions_app/build/windows/x64/pdfium-download/pdfium-download-prefix"
  "D:/flutter project/receptions_app/build/windows/x64/pdfium-download/pdfium-download-prefix/tmp"
  "D:/flutter project/receptions_app/build/windows/x64/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp"
  "D:/flutter project/receptions_app/build/windows/x64/pdfium-download/pdfium-download-prefix/src"
  "D:/flutter project/receptions_app/build/windows/x64/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp"
)

set(configSubDirs Debug;Release;MinSizeRel;RelWithDebInfo)
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "D:/flutter project/receptions_app/build/windows/x64/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "D:/flutter project/receptions_app/build/windows/x64/pdfium-download/pdfium-download-prefix/src/pdfium-download-stamp${cfgdir}") # cfgdir has leading slash
endif()
