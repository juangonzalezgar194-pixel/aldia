package com.aldia.aldia_backend.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "contrato")
public class Contrato {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "inmueble_id", nullable = false)
    private Long inmuebleId;

    @Column(name = "arrendador_id", nullable = false)
    private Long arrendadorId;

    @Column(name = "arrendatario_id", nullable = false)
    private Long arrendatarioId;

    @Column(name = "valor_mensual", nullable = false, precision = 12, scale = 2)
    private BigDecimal valorMensual;

    @Column(name = "dia_pago", nullable = false)
    private Integer diaPago;

    @Column(name = "fecha_inicio", nullable = false)
    private LocalDate fechaInicio;

    @Column(name = "fecha_fin")
    private LocalDate fechaFin;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EstadoContrato estado = EstadoContrato.ACTIVO;

    @Column(columnDefinition = "text")
    private String observaciones;

    @Column(name = "creado_en")
    private LocalDateTime creadoEn;

    @Column(name = "actualizado_en")
    private LocalDateTime actualizadoEn;

    public enum EstadoContrato {
        ACTIVO, TERMINADO, SUSPENDIDO
    }

    @PrePersist
    public void prePersist() {
        this.creadoEn = LocalDateTime.now();
        this.actualizadoEn = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.actualizadoEn = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getInmuebleId() { return inmuebleId; }
    public void setInmuebleId(Long inmuebleId) { this.inmuebleId = inmuebleId; }

    public Long getArrendadorId() { return arrendadorId; }
    public void setArrendadorId(Long arrendadorId) { this.arrendadorId = arrendadorId; }

    public Long getArrendatarioId() { return arrendatarioId; }
    public void setArrendatarioId(Long arrendatarioId) { this.arrendatarioId = arrendatarioId; }

    public BigDecimal getValorMensual() { return valorMensual; }
    public void setValorMensual(BigDecimal valorMensual) { this.valorMensual = valorMensual; }

    public Integer getDiaPago() { return diaPago; }
    public void setDiaPago(Integer diaPago) { this.diaPago = diaPago; }

    public LocalDate getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(LocalDate fechaInicio) { this.fechaInicio = fechaInicio; }

    public LocalDate getFechaFin() { return fechaFin; }
    public void setFechaFin(LocalDate fechaFin) { this.fechaFin = fechaFin; }

    public EstadoContrato getEstado() { return estado; }
    public void setEstado(EstadoContrato estado) { this.estado = estado; }

    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }

    public LocalDateTime getCreadoEn() { return creadoEn; }
    public void setCreadoEn(LocalDateTime creadoEn) { this.creadoEn = creadoEn; }

    public LocalDateTime getActualizadoEn() { return actualizadoEn; }
    public void setActualizadoEn(LocalDateTime actualizadoEn) { this.actualizadoEn = actualizadoEn; }
}