package com.aldia.aldia_backend.repository;

import com.aldia.aldia_backend.model.Reporte;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ReporteRepository extends JpaRepository<Reporte, Long> {
    List<Reporte> findByContratoId(Long contratoId);
    List<Reporte> findByGeneradoPorId(Long generadoPorId);
    List<Reporte> findByTipo(Reporte.TipoReporte tipo);
}