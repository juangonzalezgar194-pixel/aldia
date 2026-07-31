package com.aldia.aldia_backend.controller;

import com.aldia.aldia_backend.model.TokenJwt;
import com.aldia.aldia_backend.repository.TokenJwtRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/tokens")
@CrossOrigin(origins = "*")
public class TokenJwtController {

    @Autowired
    private TokenJwtRepository tokenJwtRepository;

    @GetMapping
    public List<TokenJwt> listar() {
        return tokenJwtRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<TokenJwt> buscarPorId(@PathVariable Long id) {
        return tokenJwtRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/usuario/{id}")
    public List<TokenJwt> porUsuario(@PathVariable Long id) {
        return tokenJwtRepository.findByUsuarioId(id);
    }

    @PostMapping
    public TokenJwt crear(@RequestBody TokenJwt token) {
        return tokenJwtRepository.save(token);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TokenJwt> revocar(@PathVariable Long id) {
        return tokenJwtRepository.findById(id).map(token -> {
            token.setRevocado(true);
            token.setExpirado(true);
            return ResponseEntity.ok(tokenJwtRepository.save(token));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (tokenJwtRepository.existsById(id)) {
            tokenJwtRepository.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
