package com.aldia.aldia_backend.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public class CrearContratoRequest {

    // --- Datos del arrendatario (puede ser nuevo o ya existente) ---
    private String arrendatarioNombre;
    private String arrendatarioApellido;
    private String arrendatarioNumDocumento;
    private String arrendatarioCorreo;
    private String arrendatarioTelefono;

    // --- Datos del contrato ---
    private Long inmuebleId;
    private Long arrendadorId;
    private BigDecimal valorMensual;
    private Integer diaPago;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
    private String observaciones;

    public String getArrendatarioNombre() { return arrendatarioNombre; }
    public void setArrendatarioNombre(String arrendatarioNombre) { this.arrendatarioNombre = arrendatarioNombre; }

    public String getArrendatarioApellido() { return arrendatarioApellido; }
    public void setArrendatarioApellido(String arrendatarioApellido) { this.arrendatarioApellido = arrendatarioApellido; }

    public String getArrendatarioNumDocumento() { return arrendatarioNumDocumento; }
    public void setArrendatarioNumDocumento(String arrendatarioNumDocumento) { this.arrendatarioNumDocumento = arrendatarioNumDocumento; }

    public String getArrendatarioCorreo() { return arrendatarioCorreo; }
    public void setArrendatarioCorreo(String arrendatarioCorreo) { this.arrendatarioCorreo = arrendatarioCorreo; }

    public String getArrendatarioTelefono() { return arrendatarioTelefono; }
    public void setArrendatarioTelefono(String arrendatarioTelefono) { this.arrendatarioTelefono = arrendatarioTelefono; }

    public Long getInmuebleId() { return inmuebleId; }
    public void setInmuebleId(Long inmuebleId) { this.inmuebleId = inmuebleId; }

    public Long getArrendadorId() { return arrendadorId; }
    public void setArrendadorId(Long arrendadorId) { this.arrendadorId = arrendadorId; }

    public BigDecimal getValorMensual() { return valorMensual; }
    public void setValorMensual(BigDecimal valorMensual) { this.valorMensual = valorMensual; }

    public Integer getDiaPago() { return diaPago; }
    public void setDiaPago(Integer diaPago) { this.diaPago = diaPago; }

    public LocalDate getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(LocalDate fechaInicio) { this.fechaInicio = fechaInicio; }

    public LocalDate getFechaFin() { return fechaFin; }
    public void setFechaFin(LocalDate fechaFin) { this.fechaFin = fechaFin; }

    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }
}