package com.aldia.aldia_backend.repository;

import com.aldia.aldia_backend.model.TokenJwt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface TokenJwtRepository extends JpaRepository<TokenJwt, Long> {
    Optional<TokenJwt> findByToken(String token);
    List<TokenJwt> findByUsuarioId(Long usuarioId);
    List<TokenJwt> findByUsuarioIdAndRevocadoFalseAndExpiradoFalse(Long usuarioId);
}