package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.Contrato;
import com.aldia.aldia_backend.model.Pago;
import com.aldia.aldia_backend.repository.ContratoRepository;
import com.aldia.aldia_backend.repository.PagoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/pagos")
@CrossOrigin(origins = "*")
public class PagoController {

    @Autowired
    private PagoRepository pagoRepository;

    @Autowired
    private ContratoRepository contratoRepository;

    @GetMapping
    public List<Pago> listar() {
        List<Pago> pagos = pagoRepository.findAll();
        actualizarMora(pagos);
        return pagos;
    }

    @GetMapping("/{id}")
    public ResponseEntity<Pago> buscarPorId(@PathVariable Long id) {
        return pagoRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/contrato/{id}")
    public List<Pago> porContrato(@PathVariable Long id) {
        List<Pago> pagos = pagoRepository.findByContratoIdOrderByPeriodoAsc(id);
        actualizarMora(pagos);
        return pagos;
    }

    @GetMapping("/estado/{estado}")
    public List<Pago> porEstado(@PathVariable Pago.EstadoPago estado) {
        return pagoRepository.findByEstado(estado);
    }

    @PostMapping
    public Pago crear(@RequestBody Pago pago) {
        return pagoRepository.save(pago);
    }

    /**
     * Simula el pago (dinero ficticio, sin pasarela real):
     * marca el registro como PAGADO con la fecha de hoy.
     */
    @PutMapping("/{id}/pagar")
    public ResponseEntity<Pago> pagar(@PathVariable Long id) {
        return pagoRepository.findById(id).map(pago -> {
            Contrato contrato = contratoRepository.findById(pago.getContratoId()).orElse(null);
            pago.setFechaPago(LocalDate.now());
            pago.setEstado(Pago.EstadoPago.PAGADO);
            pago.setMetodoPago(Pago.MetodoPago.TRANSFERENCIA);
            if (contrato != null) {
                pago.setValorPagado(contrato.getValorMensual());
            }
            return ResponseEntity.ok(pagoRepository.save(pago));
        }).orElse(ResponseEntity.notFound().build());
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

    /** Marca como EN_MORA los pagos pendientes cuya fecha límite ya pasó */
    private void actualizarMora(List<Pago> pagos) {
        LocalDate hoy = LocalDate.now();
        for (Pago pago : pagos) {
            if (pago.getEstado() == Pago.EstadoPago.PENDIENTE && pago.getFechaLimite().isBefore(hoy)) {
                pago.setEstado(Pago.EstadoPago.EN_MORA);
                pagoRepository.save(pago);
            }
        }
    }
}