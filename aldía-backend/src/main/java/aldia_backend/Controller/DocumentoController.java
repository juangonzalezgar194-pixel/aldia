package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.Documento;
import com.aldia.aldia_backend.repository.DocumentoRepository;
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
@RequestMapping("/api/v1/documentos")
@CrossOrigin(origins = "*")
public class DocumentoController {

    @Autowired
    private DocumentoRepository documentoRepository;

    private final String UPLOAD_DIR = "uploads/";

    @PostMapping("/subir")
    public ResponseEntity<?> subirDocumento(
            @RequestParam("archivo") MultipartFile archivo,
            @RequestParam("contratoId") Long contratoId) {

        try {
            // Crear carpeta si no existe
            File carpeta = new File(UPLOAD_DIR);
            if (!carpeta.exists()) carpeta.mkdirs();

            // Guardar archivo en disco
            String nombreArchivo = System.currentTimeMillis() + "_" + archivo.getOriginalFilename();
            Path ruta = Paths.get(UPLOAD_DIR + nombreArchivo);
            Files.write(ruta, archivo.getBytes());

            // Guardar en base de datos
            Documento doc = new Documento();
            doc.setNombre(archivo.getOriginalFilename());
            doc.setTipo(archivo.getContentType());
            doc.setUrl(UPLOAD_DIR + nombreArchivo);
            doc.setContratoId(contratoId);

            documentoRepository.save(doc);

            return ResponseEntity.ok(doc);
        } catch (IOException e) {
            return ResponseEntity.status(500).body("Error al subir el archivo: " + e.getMessage());
        }
    }

    @GetMapping("/contrato/{contratoId}")
    public ResponseEntity<List<Documento>> obtenerPorContrato(@PathVariable Long contratoId) {
        List<Documento> documentos = documentoRepository.findByContratoId(contratoId);
        return ResponseEntity.ok(documentos);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Long id) {
        documentoRepository.deleteById(id);
        return ResponseEntity.ok("Documento eliminado");
    }
}
