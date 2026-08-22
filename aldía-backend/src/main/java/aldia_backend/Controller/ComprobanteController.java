package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.Comprobante;
import com.aldia.aldia_backend.repository.ComprobanteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@RestController
@RequestMapping("/api/v1/comprobantes")
@CrossOrigin(origins = "*")
public class ComprobanteController {

    @Autowired
    private ComprobanteRepository comprobanteRepository;

    private final String UPLOAD_DIR = "uploads/";
    private final String BASE_URL = "https://api.aldiaapp.org/";

    @PostMapping("/upload")
    public ResponseEntity<?> subirComprobante(
            @RequestParam("archivo") MultipartFile archivo,
            @RequestParam("contratoId") Long contratoId,
            @RequestParam("subidoPor") String subidoPor) {

        try {
            File carpeta = new File(UPLOAD_DIR);
            if (!carpeta.exists()) carpeta.mkdirs();

            String nombreGuardado = System.currentTimeMillis() + "_" + archivo.getOriginalFilename();
            Path ruta = Paths.get(UPLOAD_DIR + nombreGuardado);
            Files.write(ruta, archivo.getBytes());

            String contentType = archivo.getContentType() != null ? archivo.getContentType() : "";
            String tipo = contentType.contains("pdf") ? "PDF" : "IMAGEN";

            Comprobante comp = new Comprobante();
            comp.setNombreArchivo(archivo.getOriginalFilename());
            comp.setTipoArchivo(tipo);
            comp.setTamanioBytes(archivo.getSize());
            comp.setContratoId(contratoId);
            comp.setSubidoPor(subidoPor);
            comp.setUrlDescarga(BASE_URL + UPLOAD_DIR + nombreGuardado);

            comprobanteRepository.save(comp);

            return ResponseEntity.ok(comp);
        } catch (IOException e) {
            return ResponseEntity.status(500).body("Error al subir el comprobante: " + e.getMessage());
        }
    }

    @GetMapping("/contrato/{contratoId}")
    public ResponseEntity<List<Comprobante>> obtenerPorContrato(@PathVariable Long contratoId) {
        List<Comprobante> comprobantes = comprobanteRepository.findByContratoId(contratoId);
        return ResponseEntity.ok(comprobantes);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Long id) {
        comprobanteRepository.deleteById(id);
        return ResponseEntity.ok("Comprobante eliminado");
    }
}