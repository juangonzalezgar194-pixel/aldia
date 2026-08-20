package com.aldia.aldia_backend.repository;

import com.aldia.aldia_backend.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Optional<Usuario> findByCorreo(String correo);
    Optional<Usuario> findByNombreUsuario(String nombreUsuario);
    Optional<Usuario> findByNumDocumento(String numDocumento);
    boolean existsByCorreo(String correo);
    boolean existsByNombreUsuario(String nombreUsuario);
    boolean existsByNumDocumento(String numDocumento);
    List<Usuario> findByRol(String rol);
}