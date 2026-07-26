package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.Contrato;
import com.aldia.aldia_backend.repository.ContratoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/contratos")
@CrossOrigin(origins = "*")
public class ContratoController {

    @Autowired
    private ContratoRepository contratoRepository;

    @GetMapping
    public List<Contrato> listar() {
        return contratoRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Contrato> buscarPorId(@PathVariable Long id) {
        return contratoRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/arrendador/{id}")
    public List<Contrato> porArrendador(@PathVariable Long id) {
        return contratoRepository.findByArrendadorId(id);
    }

    @GetMapping("/arrendatario/{id}")
    public List<Contrato> porArrendatario(@PathVariable Long id) {
        return contratoRepository.findByArrendatarioId(id);
    }

    @PostMapping
    public Contrato crear(@RequestBody Contrato contrato) {
        return contratoRepository.save(contrato);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Contrato> actualizar(@PathVariable Long id, @RequestBody Contrato datos) {
        return contratoRepository.findById(id).map(contrato -> {
            contrato.setValorMensual(datos.getValorMensual());
            contrato.setDiaPago(datos.getDiaPago());
            contrato.setFechaFin(datos.getFechaFin());
            contrato.setEstado(datos.getEstado());
            contrato.setObservaciones(datos.getObservaciones());
            return ResponseEntity.ok(contratoRepository.save(contrato));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (contratoRepository.existsById(id)) {
            contratoRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
