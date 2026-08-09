//
// Este archivo ha sido generado por Eclipse Implementation of JAXB v4.0.5 
// Visite https://eclipse-ee4j.github.io/jaxb-ri 
// Todas las modificaciones realizadas en este archivo se perderán si se vuelve a compilar el esquema de origen. 
//


package com.aldia.soap;

import java.math.BigDecimal;
import jakarta.xml.bind.annotation.XmlAccessType;
import jakarta.xml.bind.annotation.XmlAccessorType;
import jakarta.xml.bind.annotation.XmlElement;
import jakarta.xml.bind.annotation.XmlRootElement;
import jakarta.xml.bind.annotation.XmlType;


/**
 * <p>Clase Java para anonymous complex type.</p>
 * 
 * <p>El siguiente fragmento de esquema especifica el contenido que se espera que haya en esta clase.</p>
 * 
 * <pre>{@code
 * <complexType>
 *   <complexContent>
 *     <restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       <sequence>
 *         <element name="id" type="{http://www.w3.org/2001/XMLSchema}long"/>
 *         <element name="inmuebleId" type="{http://www.w3.org/2001/XMLSchema}long"/>
 *         <element name="arrendatarioId" type="{http://www.w3.org/2001/XMLSchema}long"/>
 *         <element name="fechaInicio" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         <element name="fechaFin" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         <element name="valorMensual" type="{http://www.w3.org/2001/XMLSchema}decimal"/>
 *         <element name="estado" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *       </sequence>
 *     </restriction>
 *   </complexContent>
 * </complexType>
 * }</pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "id",
    "inmuebleId",
    "arrendatarioId",
    "fechaInicio",
    "fechaFin",
    "valorMensual",
    "estado"
})
@XmlRootElement(name = "consultarContratoResponse")
public class ConsultarContratoResponse {

    protected long id;
    protected long inmuebleId;
    protected long arrendatarioId;
    @XmlElement(required = true)
    protected String fechaInicio;
    @XmlElement(required = true)
    protected String fechaFin;
    @XmlElement(required = true)
    protected BigDecimal valorMensual;
    @XmlElement(required = true)
    protected String estado;

    /**
     * Obtiene el valor de la propiedad id.
     * 
     */
    public long getId() {
        return id;
    }

    /**
     * Define el valor de la propiedad id.
     * 
     */
    public void setId(long value) {
        this.id = value;
    }

    /**
     * Obtiene el valor de la propiedad inmuebleId.
     * 
     */
    public long getInmuebleId() {
        return inmuebleId;
    }

    /**
     * Define el valor de la propiedad inmuebleId.
     * 
     */
    public void setInmuebleId(long value) {
        this.inmuebleId = value;
    }

    /**
     * Obtiene el valor de la propiedad arrendatarioId.
     * 
     */
    public long getArrendatarioId() {
        return arrendatarioId;
    }

    /**
     * Define el valor de la propiedad arrendatarioId.
     * 
     */
    public void setArrendatarioId(long value) {
        this.arrendatarioId = value;
    }

    /**
     * Obtiene el valor de la propiedad fechaInicio.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFechaInicio() {
        return fechaInicio;
    }

    /**
     * Define el valor de la propiedad fechaInicio.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFechaInicio(String value) {
        this.fechaInicio = value;
    }

    /**
     * Obtiene el valor de la propiedad fechaFin.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFechaFin() {
        return fechaFin;
    }

    /**
     * Define el valor de la propiedad fechaFin.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFechaFin(String value) {
        this.fechaFin = value;
    }

    /**
     * Obtiene el valor de la propiedad valorMensual.
     * 
     * @return
     *     possible object is
     *     {@link BigDecimal }
     *     
     */
    public BigDecimal getValorMensual() {
        return valorMensual;
    }

    /**
     * Define el valor de la propiedad valorMensual.
     * 
     * @param value
     *     allowed object is
     *     {@link BigDecimal }
     *     
     */
    public void setValorMensual(BigDecimal value) {
        this.valorMensual = value;
    }

    /**
     * Obtiene el valor de la propiedad estado.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEstado() {
        return estado;
    }

    /**
     * Define el valor de la propiedad estado.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEstado(String value) {
        this.estado = value;
    }

}
