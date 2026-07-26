package com.aldia.aldia_backend.Controller;

import com.aldia.aldia_backend.model.Usuario;
import com.aldia.aldia_backend.repository.UsuarioRepository;
import com.aldia.aldia_backend.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping
    public List<Usuario> listar() {
        return usuarioRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Usuario> buscarPorId(@PathVariable Long id) {
        return usuarioRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Usuario> crear(@RequestBody Usuario usuario) {
        usuario.setContrasena(passwordEncoder.encode(usuario.getContrasena()));
        return ResponseEntity.status(201).body(usuarioRepository.save(usuario));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Usuario> actualizar(@PathVariable Long id, @RequestBody Usuario datos) {
        return usuarioRepository.findById(id).map(usuario -> {
            usuario.setNombre(datos.getNombre());
            usuario.setApellido(datos.getApellido());
            usuario.setCorreo(datos.getCorreo());
            usuario.setTelefono(datos.getTelefono());
            usuario.setActivo(datos.isActivo());
            return ResponseEntity.ok(usuarioRepository.save(usuario));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        if (usuarioRepository.existsById(id)) {
            usuarioRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Usuario credenciales) {
        return usuarioRepository.findByCorreo(credenciales.getCorreo())
                .filter(u -> passwordEncoder.matches(credenciales.getContrasena(), u.getContrasena()))
                .map(u -> {
                    String token = jwtUtil.generarToken(u.getCorreo(), "USER");
                    Map<String, Object> respuesta = new HashMap<>();
                    respuesta.put("token", token);
                    respuesta.put("id", u.getId());
                    respuesta.put("nombre", u.getNombre());
                    respuesta.put("correo", u.getCorreo());
                    respuesta.put("rol", "USER");
                    return ResponseEntity.ok(respuesta);
                })
                .orElse(ResponseEntity.status(401).build());
    }
}