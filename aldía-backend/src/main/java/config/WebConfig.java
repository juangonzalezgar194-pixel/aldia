package com.aldia.aldia_backend.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.File;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    // Debe coincidir con el UPLOAD_DIR usado en DocumentoController y ComprobanteController
    private static final String UPLOAD_DIR = "uploads/";

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Ruta absoluta a la carpeta uploads/, para que funcione sin importar
        // desde qué directorio de trabajo arranque el proceso (Railway incluido)
        String rutaAbsoluta = new File(UPLOAD_DIR).getAbsolutePath();

        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + rutaAbsoluta + "/");
    }

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/uploads/**")
                .allowedOrigins("*")
                .allowedMethods("GET", "OPTIONS");
    }
}