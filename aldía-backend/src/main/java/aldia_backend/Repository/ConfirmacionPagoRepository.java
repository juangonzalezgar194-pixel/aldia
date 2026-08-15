package com.aldia.aldia_backend.repository;

import com.aldia.aldia_backend.model.ConfirmacionPago;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface ConfirmacionPagoRepository extends JpaRepository<ConfirmacionPago, Long> {
    boolean existsByContratoIdAndPeriodoPago(Long contratoId, LocalDate periodoPago);
    List<ConfirmacionPago> findByContratoId(Long contratoId);
}