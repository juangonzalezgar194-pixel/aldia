package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.Contrato;
import com.aldia.aldia_backend.model.Pago;
import com.aldia.aldia_backend.repository.ContratoRepository;
import com.aldia.aldia_backend.repository.PagoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/v1/contratos")
@CrossOrigin(origins = "*")
public class ContratoController {

    @Autowired
    private ContratoRepository contratoRepository;

    @Autowired
    private PagoRepository pagoRepository;

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
        Contrato guardado = contratoRepository.save(contrato);
        generarPagosDelContrato(guardado);
        return guardado;
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

    /**
     * Genera automáticamente los pagos mensuales del contrato (dinero simulado,
     * sin conexión a ninguna pasarela real). Si no hay fechaFin, genera 12 meses.
     */
    private void generarPagosDelContrato(Contrato contrato) {
        // Evita duplicar pagos si el contrato ya los tiene generados
        if (!pagoRepository.findByContratoId(contrato.getId()).isEmpty()) {
            return;
        }

        LocalDate inicio = contrato.getFechaInicio();
        LocalDate fin = contrato.getFechaFin() != null
                ? contrato.getFechaFin()
                : inicio.plusMonths(12);

        int diaPago = contrato.getDiaPago() != null ? contrato.getDiaPago() : 5;

        YearMonth mesActual = YearMonth.from(inicio);
        YearMonth mesFin = YearMonth.from(fin);

        List<Pago> pagosGenerados = new ArrayList<>();

        while (!mesActual.isAfter(mesFin)) {
            Pago pago = new Pago();
            pago.setContratoId(contrato.getId());
            pago.setPeriodo(mesActual.atDay(1));

            int ultimoDia = mesActual.lengthOfMonth();
            int dia = Math.min(diaPago, ultimoDia);
            pago.setFechaLimite(mesActual.atDay(dia));

            pago.setEstado(Pago.EstadoPago.PENDIENTE);
            pagosGenerados.add(pago);

            mesActual = mesActual.plusMonths(1);
        }

        pagoRepository.saveAll(pagosGenerados);
    }
}