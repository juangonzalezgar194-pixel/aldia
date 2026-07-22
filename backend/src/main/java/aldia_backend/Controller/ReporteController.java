package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.Reporte;
import com.aldia.aldia_backend.repository.ReporteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/reportes")
@CrossOrigin(origins = "*")
public class ReporteController {

    @Autowired
    private ReporteRepository reporteRepository;

    @GetMapping
    public List<Reporte> listar() {
        return reporteRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Reporte> buscarPorId(@PathVariable Long id) {
        return reporteRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/contrato/{id}")
    public List<Reporte> porContrato(@PathVariable Long id) {
        return reporteRepository.findByContratoId(id);
    }

    @GetMapping("/generado-por/{id}")
    public List<Reporte> porGenerador(@PathVariable Long id) {
        return reporteRepository.findByGeneradoPorId(id);
    }

    @PostMapping
    public Reporte crear(@RequestBody Reporte reporte) {
        return reporteRepository.save(reporte);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (reporteRepository.existsById(id)) {
            reporteRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
