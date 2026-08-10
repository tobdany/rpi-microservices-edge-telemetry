cmake_minimum_required(VERSION 3.14)
project(rpi_edge_monitor CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ------------------------------------------------------------------------------
# 1. Buscar dependencias del sistema
# ------------------------------------------------------------------------------
find_package(Threads REQUIRED)

find_path(MYSQL_INCLUDE_DIR mysql/mysql.h)
find_library(MYSQL_LIBRARY NAMES mysqlclient mariadb)

if(NOT MYSQL_INCLUDE_DIR OR NOT MYSQL_LIBRARY)
    message(FATAL_ERROR "MySQL Client library/headers no encontrados. Instala libmysqlclient-dev o mariadb-client.")
endif()

# ------------------------------------------------------------------------------
# 2. Rutas de cabeceras (Incluimos la carpeta src/ donde están tus .h / .hpp)
# ------------------------------------------------------------------------------
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${MYSQL_INCLUDE_DIR}
)

# ------------------------------------------------------------------------------
# 3. Definir el ejecutable (Apuntando a src/main.cpp)
# ------------------------------------------------------------------------------
add_executable(telemetry_server src/main.cpp)

# ------------------------------------------------------------------------------
# 4. Vincular librerías
# ------------------------------------------------------------------------------
target_link_libraries(telemetry_server PRIVATE
    ${MYSQL_LIBRARY}
    Threads::Threads
)

# ------------------------------------------------------------------------------
# 5. Copiar el archivo .env desde src/ al directorio donde se compila el binario
# ------------------------------------------------------------------------------
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/.env")
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/src/.env" "${CMAKE_CURRENT_BINARY_DIR}/.env" COPYONLY)
endif()