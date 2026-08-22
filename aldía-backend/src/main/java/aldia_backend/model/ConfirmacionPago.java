package com.aldia.aldia_backend.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "confirmacion_pago")
public class ConfirmacionPago {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "contrato_id", nullable = false)
    private Long contratoId;

    // El día de pago (mes/ciclo) que se está confirmando, ej. 2026-08-05
    @Column(name = "periodo_pago", nullable = false)
    private LocalDate periodoPago;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MetodoConfirmacion metodo;

    // Solo aplica si metodo = COMPROBANTE
    @Column(name = "documento_id")
    private Long documentoId;

    // Solo aplica si metodo = EFECTIVO
    @Column(name = "valor")
    private BigDecimal valor;

    @Column(name = "nombre_pagador")
    private String nombrePagador;

    @Column(name = "fecha_pago")
    private LocalDate fechaPago;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EstadoConfirmacion estado = EstadoConfirmacion.PENDIENTE;

    @Column(name = "confirmado_en")
    private LocalDateTime confirmadoEn;

    public enum MetodoConfirmacion {
        EFECTIVO, COMPROBANTE
    }

    public enum EstadoConfirmacion {
        PENDIENTE, CONFIRMADO
    }

    @PrePersist
    public void prePersist() {
        this.confirmadoEn = LocalDateTime.now();
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getContratoId() { return contratoId; }
    public void setContratoId(Long contratoId) { this.contratoId = contratoId; }

    public LocalDate getPeriodoPago() { return periodoPago; }
    public void setPeriodoPago(LocalDate periodoPago) { this.periodoPago = periodoPago; }

    public MetodoConfirmacion getMetodo() { return metodo; }
    public void setMetodo(MetodoConfirmacion metodo) { this.metodo = metodo; }

    public Long getDocumentoId() { return documentoId; }
    public void setDocumentoId(Long documentoId) { this.documentoId = documentoId; }

    public BigDecimal getValor() { return valor; }
    public void setValor(BigDecimal valor) { this.valor = valor; }

    public String getNombrePagador() { return nombrePagador; }
    public void setNombrePagador(String nombrePagador) { this.nombrePagador = nombrePagador; }

    public LocalDate getFechaPago() { return fechaPago; }
    public void setFechaPago(LocalDate fechaPago) { this.fechaPago = fechaPago; }

    public EstadoConfirmacion getEstado() { return estado; }
    public void setEstado(EstadoConfirmacion estado) { this.estado = estado; }

    public LocalDateTime getConfirmadoEn() { return confirmadoEn; }
    public void setConfirmadoEn(LocalDateTime confirmadoEn) { this.confirmadoEn = confirmadoEn; }
}