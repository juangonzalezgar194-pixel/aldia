package com.aldia.aldia_backend.repository;

import com.aldia.aldia_backend.model.Documento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface DocumentoRepository extends JpaRepository<Documento, Long> {
    List<Documento> findByContratoId(Long contratoId);
}