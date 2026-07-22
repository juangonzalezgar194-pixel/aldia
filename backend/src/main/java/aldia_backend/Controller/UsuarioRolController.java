package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.UsuarioRol;
import com.aldia.aldia_backend.repository.UsuarioRolRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/usuario-roles")
@CrossOrigin(origins = "*")
public class UsuarioRolController {

    @Autowired
    private UsuarioRolRepository usuarioRolRepository;

    @GetMapping
    public List<UsuarioRol> listar() {
        return usuarioRolRepository.findAll();
    }

    @GetMapping("/usuario/{id}")
    public List<UsuarioRol> porUsuario(@PathVariable Long id) {
        return usuarioRolRepository.findById_UsuarioId(id);
    }

    @GetMapping("/rol/{id}")
    public List<UsuarioRol> porRol(@PathVariable Integer id) {
        return usuarioRolRepository.findById_RolId(id);
    }

    @PostMapping
    public UsuarioRol crear(@RequestBody UsuarioRol usuarioRol) {
        return usuarioRolRepository.save(usuarioRol);
    }

    @DeleteMapping("/usuario/{usuarioId}/rol/{rolId}")
    public ResponseEntity<Void> eliminar(@PathVariable Long usuarioId, @PathVariable Integer rolId) {
        UsuarioRol.UsuarioRolId id = new UsuarioRol.UsuarioRolId();
        id.setUsuarioId(usuarioId);
        id.setRolId(rolId);
        if (usuarioRolRepository.existsById(id)) {
            usuarioRolRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
