package com.aldia.aldia_backend.repository;

import com.aldia.aldia_backend.model.Contrato;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ContratoRepository extends JpaRepository<Contrato, Long> {
    List<Contrato> findByArrendadorId(Long arrendadorId);
    List<Contrato> findByArrendatarioId(Long arrendatarioId);
    List<Contrato> findByInmuebleId(Long inmuebleId);
    List<Contrato> findByEstado(Contrato.EstadoContrato estado);
}