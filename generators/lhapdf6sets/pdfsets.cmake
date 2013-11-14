# Arguments:
#   distr   - path to LHAPDF source package
#   repo    - URL of PDF sets repository
#   PDFsets - list of PDF sets to install
#   dst_dir - installation directory

message(STATUS "Distributive: ${distr}")
message(STATUS "PDF repo: ${repo}")
message(STATUS "PDF sets: ${PDFsets}")
message(STATUS "Destination: ${dst_dir}")

# PDF sets directory
set(pdf_dir ${dst_dir})
message(STATUS "PDF sets directory: ${pdf_dir}")

if(EXISTS ${pdf_dir})
  message(STATUS "PDF sets directory exists already, skip download")
  return()
endif()

file(MAKE_DIRECTORY ${pdf_dir})

# download PDF sets
message(STATUS "the following command will be executed: ${distr}/bin/lhapdf-getdata --force --repo=${repo} --dest=${pdf_dir} ${PDFsets}  ")
execute_process(COMMAND ${distr}/bin/lhapdf-getdata --untar --force --repo=${repo} --dest=${pdf_dir} ${PDFsets} RESULT_VARIABLE code)
execute_process(COMMAND ${distr}/bin/lhapdf-getdata --force --repo=${repo} --dest=${pdf_dir} pdfsets.index RESULT_VARIABLE code)


if(NOT code EQUAL 0)
  message(FATAL_ERROR "ERROR: failed to download PDF sets")
endif()

# copy index
#file(COPY ${distr}/pdfsets.index DESTINATION ${dst_dir}/)

# create completion marker
file(WRITE ${pdf_dir}/.complete "")

message(STATUS "PDF sets downloaded successfully")
