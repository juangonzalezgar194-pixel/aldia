package com.aldia.aldia_backend.soap;

import com.aldia.aldia_backend.model.Contrato;
import com.aldia.aldia_backend.model.Inmueble;
import com.aldia.aldia_backend.repository.ContratoRepository;
import com.aldia.aldia_backend.repository.InmuebleRepository;
import com.aldia.soap.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ws.server.endpoint.annotation.Endpoint;
import org.springframework.ws.server.endpoint.annotation.PayloadRoot;
import org.springframework.ws.server.endpoint.annotation.RequestPayload;
import org.springframework.ws.server.endpoint.annotation.ResponsePayload;

import java.util.List;
import java.util.Optional;

@Endpoint
public class AldiaEndpoint {

    private static final String NAMESPACE_URI = "http://aldia.com/soap";

    @Autowired
    private InmuebleRepository inmuebleRepository;

    @Autowired
    private ContratoRepository contratoRepository;

    // ══ OPERACIÓN 1: Consultar Inmueble por ID ══
    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "consultarInmuebleRequest")
    @ResponsePayload
    public ConsultarInmuebleResponse consultarInmueble(
            @RequestPayload ConsultarInmuebleRequest request) {

        ConsultarInmuebleResponse response = new ConsultarInmuebleResponse();
        Optional<Inmueble> inmueble = inmuebleRepository.findById(request.getId());

        if (inmueble.isPresent()) {
            Inmueble i = inmueble.get();
            response.setId(i.getId());
            response.setDireccion(i.getDireccion());
            response.setCiudad(i.getCiudad());
            response.setDepartamento(i.getDepartamento());
            response.setTipo(i.getTipo() != null ? i.getTipo().toString() : "");
            response.setDescripcion(i.getDescripcion());
            response.setActivo(i.isActivo());
        }
        return response;
    }

    // ══ OPERACIÓN 2: Listar todos los Inmuebles ══
    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "listarInmueblesRequest")
    @ResponsePayload
    public ListarInmueblesResponse listarInmuebles(
            @RequestPayload ListarInmueblesRequest request) {

        ListarInmueblesResponse response = new ListarInmueblesResponse();
        List<Inmueble> inmuebles = inmuebleRepository.findAll();

        for (Inmueble i : inmuebles) {
            InmuebleItem item = new InmuebleItem();
            item.setId(i.getId());
            item.setDireccion(i.getDireccion());
            item.setCiudad(i.getCiudad());
            item.setTipo(i.getTipo() != null ? i.getTipo().toString() : "");
            item.setActivo(i.isActivo());
            response.getInmuebles().add(item);
        }
        return response;
    }

    // ══ OPERACIÓN 3: Consultar Contrato por ID ══
    @PayloadRoot(namespace = NAMESPACE_URI, localPart = "consultarContratoRequest")
    @ResponsePayload
    public ConsultarContratoResponse consultarContrato(
            @RequestPayload ConsultarContratoRequest request) {

        ConsultarContratoResponse response = new ConsultarContratoResponse();
        Optional<Contrato> contrato = contratoRepository.findById(request.getId());

        if (contrato.isPresent()) {
            Contrato c = contrato.get();
            response.setId(c.getId());
            response.setInmuebleId(c.getInmuebleId());
            response.setArrendatarioId(c.getArrendatarioId());
            response.setFechaInicio(c.getFechaInicio().toString());
            response.setFechaFin(c.getFechaFin() != null ? c.getFechaFin().toString() : "");
            response.setValorMensual(c.getValorMensual());
            response.setEstado(c.getEstado().toString());
        }
        return response;
    }
}