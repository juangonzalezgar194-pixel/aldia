package com.aldia.aldia_backend.repository;

import com.aldia.aldia_backend.model.Inmueble;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface InmuebleRepository extends JpaRepository<Inmueble, Long> {
    List<Inmueble> findByPropietarioId(Long propietarioId);
    List<Inmueble> findByActivoTrue();
    List<Inmueble> findByTipo(Inmueble.TipoInmueble tipo);
    List<Inmueble> findByCiudad(String ciudad);
    List<Inmueble> findByActivoTrueAndDisponibleTrue();
    List<Inmueble> findByPropietarioIdAndActivoTrueAndDisponibleTrue(Long propietarioId);
}