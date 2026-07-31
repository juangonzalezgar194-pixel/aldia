package com.aldia.aldia_backend.repository;

import com.aldia.aldia_backend.model.Pago;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PagoRepository extends JpaRepository<Pago, Long> {
    List<Pago> findByContratoId(Long contratoId);
    List<Pago> findByContratoIdOrderByPeriodoAsc(Long contratoId);
    List<Pago> findByEstado(Pago.EstadoPago estado);
    List<Pago> findByRegistradoPorId(Long registradoPorId);
}