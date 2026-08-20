package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.Inmueble;
import com.aldia.aldia_backend.repository.InmuebleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/inmuebles")
@CrossOrigin(origins = "*")
public class InmuebleController {

    @Autowired
    private InmuebleRepository inmuebleRepository;

    @GetMapping
    public List<Inmueble> listar() {
        return inmuebleRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Inmueble> buscarPorId(@PathVariable Long id) {
        return inmuebleRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/propietario/{id}")
    public List<Inmueble> porPropietario(@PathVariable Long id) {
        return inmuebleRepository.findByPropietarioId(id);
    }

    @GetMapping("/activos")
    public List<Inmueble> activos() {
        return inmuebleRepository.findByActivoTrue();
    }

    @GetMapping("/disponibles")
    public List<Inmueble> disponibles() {
        return inmuebleRepository.findByActivoTrueAndDisponibleTrue();
    }

    @GetMapping("/propietario/{id}/disponibles")
    public List<Inmueble> porPropietarioDisponibles(@PathVariable Long id) {
        return inmuebleRepository.findByPropietarioIdAndActivoTrueAndDisponibleTrue(id);
    }

    @PostMapping
    public Inmueble crear(@RequestBody Inmueble inmueble) {
        return inmuebleRepository.save(inmueble);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Inmueble> actualizar(@PathVariable Long id, @RequestBody Inmueble datos) {
        return inmuebleRepository.findById(id).map(inmueble -> {
            inmueble.setDireccion(datos.getDireccion());
            inmueble.setCiudad(datos.getCiudad());
            inmueble.setDepartamento(datos.getDepartamento());
            inmueble.setTipo(datos.getTipo());
            inmueble.setDescripcion(datos.getDescripcion());
            inmueble.setActivo(datos.isActivo());
            inmueble.setDisponible(datos.isDisponible());
            inmueble.setPropietarioId(datos.getPropietarioId());
            return ResponseEntity.ok(inmuebleRepository.save(inmueble));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (inmuebleRepository.existsById(id)) {
            inmuebleRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}