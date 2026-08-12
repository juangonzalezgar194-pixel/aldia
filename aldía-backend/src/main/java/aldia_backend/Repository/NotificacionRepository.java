package com.aldia.aldia_backend.repository;

import com.aldia.aldia_backend.model.Notificacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface NotificacionRepository extends JpaRepository<Notificacion, Long> {
    List<Notificacion> findByUsuarioDestinoId(Long usuarioDestinoId);
    List<Notificacion> findByContratoId(Long contratoId);
    List<Notificacion> findByEstado(Notificacion.EstadoNotificacion estado);

    // Para el job automático: evitar duplicados del mismo tipo/contrato/periodo
    boolean existsByContratoIdAndTipoAndFechaPagoReferencia(
            Long contratoId, Notificacion.TipoNotificacion tipo, LocalDate fechaPagoReferencia);
}