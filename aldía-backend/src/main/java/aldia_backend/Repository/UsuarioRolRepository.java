package com.aldia.aldia_backend.repository;

import com.aldia.aldia_backend.model.UsuarioRol;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository public interface UsuarioRolRepository extends JpaRepository<UsuarioRol, UsuarioRol.UsuarioRolId> {

    List<UsuarioRol> findById_UsuarioId(Long usuarioId);
    List<UsuarioRol> findById_RolId(Integer rolId);
}