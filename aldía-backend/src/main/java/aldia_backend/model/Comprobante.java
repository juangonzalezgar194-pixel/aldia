package com.aldia.aldia_backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "comprobante")
public class Comprobante {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nombre_archivo")
    private String nombreArchivo;

    @Column(name = "tipo_archivo")
    private String tipoArchivo; // "IMAGEN" o "PDF"

    @Column(name = "tamanio_bytes")
    private Long tamanioBytes;

    @Column(name = "contrato_id")
    private Long contratoId;

    @Column(name = "subido_por")
    private String subidoPor;

    @Column(name = "url_descarga")
    private String urlDescarga;

    @Column(name = "fecha_subida")
    private LocalDateTime fechaSubida;

    @PrePersist
    public void prePersist() {
        this.fechaSubida = LocalDateTime.now();
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombreArchivo() { return nombreArchivo; }
    public void setNombreArchivo(String nombreArchivo) { this.nombreArchivo = nombreArchivo; }

    public String getTipoArchivo() { return tipoArchivo; }
    public void setTipoArchivo(String tipoArchivo) { this.tipoArchivo = tipoArchivo; }

    public Long getTamanioBytes() { return tamanioBytes; }
    public void setTamanioBytes(Long tamanioBytes) { this.tamanioBytes = tamanioBytes; }

    public Long getContratoId() { return contratoId; }
    public void setContratoId(Long contratoId) { this.contratoId = contratoId; }

    public String getSubidoPor() { return subidoPor; }
    public void setSubidoPor(String subidoPor) { this.subidoPor = subidoPor; }

    public String getUrlDescarga() { return urlDescarga; }
    public void setUrlDescarga(String urlDescarga) { this.urlDescarga = urlDescarga; }

    public LocalDateTime getFechaSubida() { return fechaSubida; }
    public void setFechaSubida(LocalDateTime fechaSubida) { this.fechaSubida = fechaSubida; }
}