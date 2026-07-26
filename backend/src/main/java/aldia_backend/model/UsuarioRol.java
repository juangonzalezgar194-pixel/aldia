package com.aldia.aldia_backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "usuario_rol")
public class UsuarioRol {

    @EmbeddedId
    private UsuarioRolId id = new UsuarioRolId();

    @Column(name = "asignado_en")
    private LocalDateTime asignadoEn;

    // Clase de clave compuesta
    @Embeddable
    public static class UsuarioRolId implements java.io.Serializable {

        @Column(name = "usuario_id")
        private Long usuarioId;

        @Column(name = "rol_id")
        private Integer rolId;

        public Long getUsuarioId() { return usuarioId; }
        public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }

        public Integer getRolId() { return rolId; }
        public void setRolId(Integer rolId) { this.rolId = rolId; }
    }

    // Getters y Setters
    public UsuarioRolId getId() { return id; }
    public void setId(UsuarioRolId id) { this.id = id; }

    public LocalDateTime getAsignadoEn() { return asignadoEn; }
    public void setAsignadoEn(LocalDateTime asignadoEn) { this.asignadoEn = asignadoEn; }
}