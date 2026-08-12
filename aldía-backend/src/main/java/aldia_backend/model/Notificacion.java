package com.aldia.aldia_backend.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "notificacion")
public class Notificacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "contrato_id", nullable = false)
    private Long contratoId;

    @Column(name = "usuario_destino_id", nullable = false)
    private Long usuarioDestinoId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrigenNotificacion origen = OrigenNotificacion.MANUAL;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoNotificacion tipo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CanalNotificacion canal;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EstadoNotificacion estado = EstadoNotificacion.PENDIENTE;

    @Column(columnDefinition = "text")
    private String mensaje;

    @Column(name = "fecha_programada")
    private LocalDateTime fechaProgramada;

    @Column(name = "fecha_envio")
    private LocalDateTime fechaEnvio;

    // Solo se usa en notificaciones AUTOMATICAS, para evitar duplicados por periodo
    @Column(name = "fecha_pago_referencia")
    private LocalDate fechaPagoReferencia;

    @Column(name = "detalle_error", columnDefinition = "text")
    private String detalleError;

    @Column(nullable = false)
    private Boolean leida = false;

    @Column(name = "creado_en")
    private LocalDateTime creadoEn;

    public enum OrigenNotificacion {
        MANUAL, AUTOMATICA
    }

    public enum TipoNotificacion {
        RECORDATORIO_3_DIAS, RECORDATORIO_1_DIA, VENCIMIENTO, MORA,
        PAGO_PROXIMO, PAGO_VENCIDO
    }

    public enum CanalNotificacion {
        EMAIL, PUSH, WHATSAPP
    }

    public enum EstadoNotificacion {
        PENDIENTE, ENVIADA, FALLIDA
    }

    @PrePersist
    public void prePersist() {
        this.creadoEn = LocalDateTime.now();
        if (this.fechaProgramada == null) {
            this.fechaProgramada = LocalDateTime.now();
        }
    }

    // Getters y setters

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getContratoId() { return contratoId; }
    public void setContratoId(Long contratoId) { this.contratoId = contratoId; }

    public Long getUsuarioDestinoId() { return usuarioDestinoId; }
    public void setUsuarioDestinoId(Long usuarioDestinoId) { this.usuarioDestinoId = usuarioDestinoId; }

    public OrigenNotificacion getOrigen() { return origen; }
    public void setOrigen(OrigenNotificacion origen) { this.origen = origen; }

    public TipoNotificacion getTipo() { return tipo; }
    public void setTipo(TipoNotificacion tipo) { this.tipo = tipo; }

    public CanalNotificacion getCanal() { return canal; }
    public void setCanal(CanalNotificacion canal) { this.canal = canal; }

    public EstadoNotificacion getEstado() { return estado; }
    public void setEstado(EstadoNotificacion estado) { this.estado = estado; }

    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }

    public LocalDateTime getFechaProgramada() { return fechaProgramada; }
    public void setFechaProgramada(LocalDateTime fechaProgramada) { this.fechaProgramada = fechaProgramada; }

    public LocalDateTime getFechaEnvio() { return fechaEnvio; }
    public void setFechaEnvio(LocalDateTime fechaEnvio) { this.fechaEnvio = fechaEnvio; }

    public LocalDate getFechaPagoReferencia() { return fechaPagoReferencia; }
    public void setFechaPagoReferencia(LocalDate fechaPagoReferencia) { this.fechaPagoReferencia = fechaPagoReferencia; }

    public String getDetalleError() { return detalleError; }
    public void setDetalleError(String detalleError) { this.detalleError = detalleError; }

    public Boolean getLeida() { return leida; }
    public void setLeida(Boolean leida) { this.leida = leida; }

    public LocalDateTime getCreadoEn() { return creadoEn; }
    public void setCreadoEn(LocalDateTime creadoEn) { this.creadoEn = creadoEn; }
}