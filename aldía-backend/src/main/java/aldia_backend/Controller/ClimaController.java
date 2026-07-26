package com.aldia.aldia_backend.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/clima")
public class ClimaController {

    // Coordenadas de Fusagasugá, Cundinamarca
    private static final double LAT = 4.3378;
    private static final double LON = -74.3644;

    @GetMapping
    public ResponseEntity<Map<String, Object>> obtenerClima() {
        try {
            RestTemplate restTemplate = new RestTemplate();

            String url = "https://api.open-meteo.com/v1/forecast" +
                    "?latitude=" + LAT +
                    "&longitude=" + LON +
                    "&current_weather=true" +
                    "&temperature_unit=celsius" +
                    "&windspeed_unit=kmh";

            Map response = restTemplate.getForObject(url, Map.class);

            Map<String, Object> currentWeather = (Map<String, Object>) response.get("current_weather");

            Map<String, Object> resultado = new HashMap<>();
            resultado.put("ciudad", "Fusagasugá");
            resultado.put("departamento", "Cundinamarca");
            resultado.put("temperatura_celsius", currentWeather.get("temperature"));
            resultado.put("velocidad_viento_kmh", currentWeather.get("windspeed"));
            resultado.put("descripcion", "Datos climáticos para inmuebles en arriendo");
            resultado.put("fuente", "Open-Meteo API (open-meteo.com)");

            return ResponseEntity.ok(resultado);

        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "No se pudo obtener el clima");
            error.put("detalle", e.getMessage());
            return ResponseEntity.internalServerError().body(error);
        }
    }

    @GetMapping("/{ciudad}")
    public ResponseEntity<Map<String, Object>> obtenerClimaPorCiudad(@PathVariable String ciudad) {
        try {
            // Coordenadas predefinidas para ciudades colombianas
            Map<String, double[]> ciudades = new HashMap<>();
            ciudades.put("fusagasuga", new double[]{4.3378, -74.3644});
            ciudades.put("bogota", new double[]{4.7110, -74.0721});
            ciudades.put("medellin", new double[]{6.2442, -75.5812});
            ciudades.put("cali", new double[]{3.4516, -76.5320});

            String ciudadKey = ciudad.toLowerCase()
                    .replace("á", "a").replace("é", "e")
                    .replace("í", "i").replace("ó", "o").replace("ú", "u");

            double[] coords = ciudades.getOrDefault(ciudadKey, new double[]{4.3378, -74.3644});

            RestTemplate restTemplate = new RestTemplate();
            String url = "https://api.open-meteo.com/v1/forecast" +
                    "?latitude=" + coords[0] +
                    "&longitude=" + coords[1] +
                    "&current_weather=true" +
                    "&temperature_unit=celsius" +
                    "&windspeed_unit=kmh";

            Map response = restTemplate.getForObject(url, Map.class);
            Map<String, Object> currentWeather = (Map<String, Object>) response.get("current_weather");

            Map<String, Object> resultado = new HashMap<>();
            resultado.put("ciudad", ciudad);
            resultado.put("temperatura_celsius", currentWeather.get("temperature"));
            resultado.put("velocidad_viento_kmh", currentWeather.get("windspeed"));
            resultado.put("descripcion", "Clima actual para gestión de inmuebles AlDía");
            resultado.put("fuente", "Open-Meteo API (open-meteo.com)");

            return ResponseEntity.ok(resultado);

        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "No se pudo obtener el clima");
            error.put("detalle", e.getMessage());
            return ResponseEntity.internalServerError().body(error);
        }
    }
}