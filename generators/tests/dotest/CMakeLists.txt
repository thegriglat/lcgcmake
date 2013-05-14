cmake_minimum_required(VERSION 2.6 FATAL_ERROR)

MESSAGE( STATUS "HYDJET_HOME:         " ${hydjet_home} )

add_test(test_hydjet sh ${CMAKE_CURRENT_SOURCE_DIR}/dotest --cd=${CMAKE_CURRENT_SOURCE_DIR} --mode=mcgtest --vers_hydjet=${hydjet_native_version} --mcgtestdir=${hydjet_home}/../../../)
add_test(test_photos sh ${CMAKE_CURRENT_SOURCE_DIR}/dotest --mode=mcgtest --vers_photos=${photos_native_version} --mcgtestdir=${photos_home}/../../)
add_test(test_evtgen sh ${CMAKE_CURRENT_SOURCE_DIR}/dotest --mode=mcgtest --vers_evtgen=${evtgen_native_version} --mcgtestdir=${evtgen_home}/../../)
#add_test(test_alpgen sh ${CMAKE_CURRENT_SOURCE_DIR}/dotest --mode=mcgtest --vers_alpgen=${alpgen_native_version} --mcgtestdir=${alpgen_home}/../../)
#add_test(test_herwig sh ${CMAKE_CURRENT_SOURCE_DIR}/dotest --mode=mcgtest --vers_herwig=${herwig_native_version} --mcgtestdir=${herwig_home}/../../)
#add_test(test_thepeg sh ${CMAKE_CURRENT_SOURCE_DIR}/dotest --mode=mcgtest --vers_thepeg=${thepeg_native_version} --mcgtestdir=${thepeg_home}/../../)
#add_test(test_tauola sh ${CMAKE_CURRENT_SOURCE_DIR}/dotest --mode=mcgtest --vers_tauola=${tauola_native_version} --mcgtestdir=${tauola_home}/../../)
#add_test(test_hijing sh ${CMAKE_CURRENT_SOURCE_DIR}/dotest --mode=mcgtest --vers_hijing=${hijing_native_version} --mcgtestdir=${hijing_home}/../../)
#add_test(test_pythia6 sh ${CMAKE_CURRENT_SOURCE_DIR}/dotest --mode=mcgtest --vers_pythia6=${pythia6_native_version} --mcgtestdir=${pythia6_home}/../../)
#add_test(test_pythia8 sh ${CMAKE_CURRENT_SOURCE_DIR}/dotest --mode=mcgtest --vers_pythia8=${pythia8_native_version} --mcgtestdir=${pythia8_home}/../../)
