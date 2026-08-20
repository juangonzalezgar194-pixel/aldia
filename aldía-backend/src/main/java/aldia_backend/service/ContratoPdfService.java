package com.aldia.aldia_backend.service;

import com.aldia.aldia_backend.model.Contrato;
import com.aldia.aldia_backend.model.Inmueble;
import com.aldia.aldia_backend.model.Usuario;
import com.aldia.aldia_backend.repository.ContratoRepository;
import com.aldia.aldia_backend.repository.InmuebleRepository;
import com.aldia.aldia_backend.repository.UsuarioRepository;
import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.draw.LineSeparator;   
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;

@Service
public class ContratoPdfService {

    @Autowired
    private ContratoRepository contratoRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private InmuebleRepository inmuebleRepository;

    private static final DateTimeFormatter FORMATO_FECHA = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    public byte[] generarPdf(Long contratoId) throws Exception {
        Contrato contrato = contratoRepository.findById(contratoId)
                .orElseThrow(() -> new IllegalArgumentException("Contrato no encontrado con id: " + contratoId));

        Usuario arrendador = usuarioRepository.findById(contrato.getArrendadorId())
                .orElseThrow(() -> new IllegalArgumentException("Arrendador no encontrado con id: " + contrato.getArrendadorId()));

        Usuario arrendatario = usuarioRepository.findById(contrato.getArrendatarioId())
                .orElseThrow(() -> new IllegalArgumentException("Arrendatario no encontrado con id: " + contrato.getArrendatarioId()));

        Inmueble inmueble = inmuebleRepository.findById(contrato.getInmuebleId())
                .orElseThrow(() -> new IllegalArgumentException("Inmueble no encontrado con id: " + contrato.getInmuebleId()));

        ByteArrayOutputStream salida = new ByteArrayOutputStream();
        Document documento = new Document(PageSize.A4, 40, 40, 40, 40);
        PdfWriter.getInstance(documento, salida);
        documento.open();

        Font fuenteTitulo = new Font(Font.HELVETICA, 18, Font.BOLD);
        Font fuenteSubtitulo = new Font(Font.HELVETICA, 11, Font.NORMAL);
        Font fuenteSeccion = new Font(Font.HELVETICA, 12, Font.BOLD);
        Font fuenteNormal = new Font(Font.HELVETICA, 11, Font.NORMAL);
        Font fuenteNegrita = new Font(Font.HELVETICA, 11, Font.BOLD);
        Font fuentePequena = new Font(Font.HELVETICA, 9, Font.NORMAL);

        Paragraph titulo = new Paragraph("CONTRATO DE ARRENDAMIENTO", fuenteTitulo);
        titulo.setAlignment(Element.ALIGN_CENTER);
        documento.add(titulo);

        Paragraph subtitulo = new Paragraph("AlDía - Sistema de Gestión de Arriendos", fuenteSubtitulo);
        subtitulo.setAlignment(Element.ALIGN_CENTER);
        subtitulo.setSpacingAfter(15);
        documento.add(subtitulo);

        documento.add(new LineSeparator());
        documento.add(new Paragraph(" "));

        documento.add(new Paragraph("Entre las partes:", fuenteSeccion));
        documento.add(new Paragraph(" "));
        agregarFila(documento, "Arrendador", nombreCompleto(arrendador), fuenteNegrita, fuenteNormal);
        agregarFila(documento, "Documento arrendador", valorODefecto(arrendador.getNumDocumento()), fuenteNegrita, fuenteNormal);
        agregarFila(documento, "Arrendatario", nombreCompleto(arrendatario), fuenteNegrita, fuenteNormal);
        agregarFila(documento, "Documento arrendatario", valorODefecto(arrendatario.getNumDocumento()), fuenteNegrita, fuenteNormal);

        documento.add(new Paragraph(" "));
        documento.add(new LineSeparator());
        documento.add(new Paragraph(" "));

        documento.add(new Paragraph("Detalles del inmueble y contrato:", fuenteSeccion));
        documento.add(new Paragraph(" "));
        agregarFila(documento, "Inmueble", inmueble.getDireccion(), fuenteNegrita, fuenteNormal);
        agregarFila(documento, "Ciudad", inmueble.getCiudad(), fuenteNegrita, fuenteNormal);
        agregarFila(documento, "Tipo de inmueble", inmueble.getTipo().name(), fuenteNegrita, fuenteNormal);
        agregarFila(documento, "Valor mensual", "$" + contrato.getValorMensual().toPlainString(), fuenteNegrita, fuenteNormal);
        agregarFila(documento, "Día de pago", String.valueOf(contrato.getDiaPago()), fuenteNegrita, fuenteNormal);
        agregarFila(documento, "Fecha de inicio", contrato.getFechaInicio().format(FORMATO_FECHA), fuenteNegrita, fuenteNormal);
        agregarFila(documento, "Fecha de fin",
                contrato.getFechaFin() != null ? contrato.getFechaFin().format(FORMATO_FECHA) : "Indefinido",
                fuenteNegrita, fuenteNormal);
        agregarFila(documento, "Estado", contrato.getEstado().name(), fuenteNegrita, fuenteNormal);

        documento.add(new Paragraph(" "));
        documento.add(new LineSeparator());
        documento.add(new Paragraph(" "));

        documento.add(new Paragraph("Cláusulas:", fuenteSeccion));
        documento.add(new Paragraph(" "));
        documento.add(new Paragraph("1. El arrendatario se compromete a pagar el valor mensual acordado antes o en el día de pago estipulado.", fuenteNormal));
        documento.add(new Paragraph("2. El arrendador se compromete a mantener el inmueble en condiciones habitables durante la vigencia del contrato.", fuenteNormal));
        documento.add(new Paragraph("3. Cualquier modificación al presente contrato deberá ser acordada por escrito entre ambas partes.", fuenteNormal));
        documento.add(new Paragraph("4. Este contrato se rige por las leyes colombianas vigentes en materia de arrendamiento (Ley 820 de 2003).", fuenteNormal));

        if (contrato.getObservaciones() != null && !contrato.getObservaciones().isBlank()) {
            documento.add(new Paragraph(" "));
            documento.add(new LineSeparator());
            documento.add(new Paragraph(" "));
            documento.add(new Paragraph("Observaciones:", fuenteSeccion));
            documento.add(new Paragraph(" "));
            documento.add(new Paragraph(contrato.getObservaciones(), fuenteNormal));
        }

        documento.add(new Paragraph(" "));
        documento.add(new LineSeparator());
        documento.add(new Paragraph(" "));
        documento.add(new Paragraph(" "));

        Table tablaFirmas = new Table(2);
        tablaFirmas.setBorderWidth(0);
        tablaFirmas.setWidth(100);

        Cell celdaFirmaArrendador = new Cell();
        celdaFirmaArrendador.setBorder(0);
        celdaFirmaArrendador.setHorizontalAlignment(Element.ALIGN_CENTER);
        celdaFirmaArrendador.addElement(new Paragraph("_______________________", fuenteNormal));
        celdaFirmaArrendador.addElement(new Paragraph("Arrendador", fuenteNegrita));
        celdaFirmaArrendador.addElement(new Paragraph(nombreCompleto(arrendador), fuentePequena));
        tablaFirmas.addCell(celdaFirmaArrendador);

        Cell celdaFirmaArrendatario = new Cell();
        celdaFirmaArrendatario.setBorder(0);
        celdaFirmaArrendatario.setHorizontalAlignment(Element.ALIGN_CENTER);
        celdaFirmaArrendatario.addElement(new Paragraph("_______________________", fuenteNormal));
        celdaFirmaArrendatario.addElement(new Paragraph("Arrendatario", fuenteNegrita));
        celdaFirmaArrendatario.addElement(new Paragraph(nombreCompleto(arrendatario), fuentePequena));
        tablaFirmas.addCell(celdaFirmaArrendatario);

        documento.add(tablaFirmas);

        documento.add(new Paragraph(" "));
        Paragraph pie = new Paragraph(
                "Generado por AlDía - " + java.time.LocalDate.now().format(FORMATO_FECHA),
                fuentePequena);
        pie.setAlignment(Element.ALIGN_CENTER);
        documento.add(pie);

        documento.close();
        return salida.toByteArray();
    }

    private void agregarFila(Document documento, String etiqueta, String valor, Font fuenteNegrita, Font fuenteNormal) throws DocumentException {
        Paragraph fila = new Paragraph();
        fila.add(new Chunk(etiqueta + ": ", fuenteNegrita));
        fila.add(new Chunk(valor != null ? valor : "", fuenteNormal));
        fila.setSpacingAfter(4);
        documento.add(fila);
    }

    private String nombreCompleto(Usuario usuario) {
        String nombre = usuario.getNombre() != null ? usuario.getNombre() : "";
        String apellido = usuario.getApellido() != null ? usuario.getApellido() : "";
        return (nombre + " " + apellido).trim();
    }

    private String valorODefecto(String valor) {
        return valor != null && !valor.isBlank() ? valor : "No registrado";
    }
}