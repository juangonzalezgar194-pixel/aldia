package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.Pago;
import com.aldia.aldia_backend.repository.PagoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/pagos")
@CrossOrigin(origins = "*")
public class PagoController {

    @Autowired
    private PagoRepository pagoRepository;

    @GetMapping
    public List<Pago> listar() {
        return pagoRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Pago> buscarPorId(@PathVariable Long id) {
        return pagoRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/contrato/{id}")
    public List<Pago> porContrato(@PathVariable Long id) {
        return pagoRepository.findByContratoId(id);
    }

    @GetMapping("/estado/{estado}")
    public List<Pago> porEstado(@PathVariable Pago.EstadoPago estado) {
        return pagoRepository.findByEstado(estado);
    }

    @PostMapping
    public Pago crear(@RequestBody Pago pago) {
        return pagoRepository.save(pago);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Pago> actualizar(@PathVariable Long id, @RequestBody Pago datos) {
        return pagoRepository.findById(id).map(pago -> {
            pago.setFechaPago(datos.getFechaPago());
            pago.setValorPagado(datos.getValorPagado());
            pago.setMetodoPago(datos.getMetodoPago());
            pago.setComprobanteUrl(datos.getComprobanteUrl());
            pago.setEstado(datos.getEstado());
            pago.setNotas(datos.getNotas());
            return ResponseEntity.ok(pagoRepository.save(pago));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (pagoRepository.existsById(id)) {
            pagoRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
