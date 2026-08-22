package com.aldia.aldia_backend.repository;

import com.aldia.aldia_backend.model.Comprobante;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ComprobanteRepository extends JpaRepository<Comprobante, Long> {
    List<Comprobante> findByContratoId(Long contratoId);
}