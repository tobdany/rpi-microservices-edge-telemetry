#include <iostream>
#include <string>
#include <mysql/mysql.h>
#include "httplib.h"
#include "json.hpp"

using namespace std;
using json = nlohmann::json;

// Guarda la lectura enviada por el nodo en la base de datos MySQL
bool save_to_mysql(const string &node_id, double temp, double cpu, int ram)
{
	MYSQL *conn = mysql_init(NULL);

	if (!mysql_real_connect(conn, "127.0.0.1", "root", "a704Test!", "rpi_edge_monitor", 3306, NULL, 0))
	{
		cerr << "Error de conexión a MySQL: " << mysql_error(conn) << endl;
		mysql_close(conn);
		return false;
	}

	string query = "INSERT INTO node_telemetry (node_id, cpu_temp_celsius, cpu_usage_pct, used_ram_mb) VALUES ('" + node_id + "', " + to_string(temp) + ", " + to_string(cpu) + ", " + to_string(ram) + ");";

	if (mysql_query(conn, query.c_str()))
	{
		cerr << "Error al insertar en MySQL: " << mysql_error(conn) << endl;
		mysql_close(conn);
		return false;
	}

	cout << "Registro insertado exitosamente para el nodo: " << node_id << endl;
	mysql_close(conn);
	return true;
}

// Recupera las últimas 10 lecturas registradas
json get_telemetry_history()
{
	json history = json::array();
	MYSQL *conn = mysql_init(NULL);

	if (!mysql_real_connect(conn, "127.0.0.1", "root", "a704Test!", "rpi_edge_monitor", 3306, NULL, 0))
	{
		cerr << "Error de conexión a MySQL: " << mysql_error(conn) << endl;
		mysql_close(conn);
		return history;
	}

	string query = "SELECT reading_id, node_id, cpu_temp_celsius, cpu_usage_pct, used_ram_mb, recorded_at FROM node_telemetry ORDER BY reading_id DESC LIMIT 10;";

	if (mysql_query(conn, query.c_str()) == 0)
	{
		MYSQL_RES *result = mysql_store_result(conn);
		MYSQL_ROW row;

		while ((row = mysql_fetch_row(result)))
		{
			json item;
			item["reading_id"] = stoi(row[0]);
			item["node_id"] = row[1];
			item["cpu_temp_celsius"] = stod(row[2]);
			item["cpu_usage_pct"] = stod(row[3]);
			item["used_ram_mb"] = stoi(row[4]);
			item["recorded_at"] = row[5] ? row[5] : "";
			history.push_back(item);
		}
		mysql_free_result(result);
	}

	mysql_close(conn);
	return history;
}

int main()
{
	httplib::Server svr;

	// Recepción de métricas de hardware
	svr.Post("/telemetry", [](const httplib::Request &req, httplib::Response &res)
			 {
        cout << "\nPetición POST recibida en /telemetry" << endl;

        try {
            auto body = json::parse(req.body);

            string node_id = body["node_id"];
            double cpu_temp = body["hardware"]["cpu_temp"];
            double cpu_usage = body["hardware"]["cpu_usage_pct"];
            int ram_used = body["hardware"]["ram_used_mb"];

            // Alerta preventiva si se detecta alta temperatura
            if (cpu_temp > 70.0) {
                cout << "Sobrecalentamiento en " << node_id << ": " << cpu_temp << "°C" << endl;
            }

            if (save_to_mysql(node_id, cpu_temp, cpu_usage, ram_used)) {
                res.status = 201;
                res.set_content(R"({"status":"success","message":"Telemetry ingested and stored in MySQL"})", "application/json");
            } else {
                res.status = 500;
                res.set_content(R"({"status":"error","message":"Database insertion failed"})", "application/json");
            }

        } catch (const exception& e) {
            res.status = 400;
            res.set_content(R"({"status":"error","message":"Invalid JSON format"})", "application/json");
        } });

	// Consulta del historial de lecturas
	svr.Get("/telemetry", [](const httplib::Request &req, httplib::Response &res)
			{
        cout << "\nPetición GET recibida en /telemetry" << endl;

        json data = get_telemetry_history();

        json response;
        response["status"] = "success";
        response["count"] = data.size();
        response["data"] = data;

        res.status = 200;
        res.set_content(response.dump(4), "application/json"); });

	cout << "Servidor REST C++ corriendo en http://localhost:8085" << endl;
	cout << "Esperando peticiones en /telemetry..." << endl;

	svr.listen("0.0.0.0", 8085);
	return 0;
}