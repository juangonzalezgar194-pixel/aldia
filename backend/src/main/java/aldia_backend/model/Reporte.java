package com.aldia.aldia_backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "reporte")
public class Reporte {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "contrato_id", nullable = false)
    private Long contratoId;

    @Column(name = "generado_por_id", nullable = false)
    private Long generadoPorId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoReporte tipo = TipoReporte.HISTORIAL_PAGOS;

    @Column(name = "archivo_url", length = 500)
    private String archivoUrl;

    @Column(name = "generado_en")
    private LocalDateTime generadoEn;

    public enum TipoReporte {
        HISTORIAL_PAGOS, ESTADO_CUENTA
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getContratoId() { return contratoId; }
    public void setContratoId(Long contratoId) { this.contratoId = contratoId; }

    public Long getGeneradoPorId() { return generadoPorId; }
    public void setGeneradoPorId(Long generadoPorId) { this.generadoPorId = generadoPorId; }

    public TipoReporte getTipo() { return tipo; }
    public void setTipo(TipoReporte tipo) { this.tipo = tipo; }

    public String getArchivoUrl() { return archivoUrl; }
    public void setArchivoUrl(String archivoUrl) { this.archivoUrl = archivoUrl; }

    public LocalDateTime getGeneradoEn() { return generadoEn; }
    public void setGeneradoEn(LocalDateTime generadoEn) { this.generadoEn = generadoEn; }
}