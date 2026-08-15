package com.aldia.aldia_backend.util;

import java.time.LocalDate;

public class PeriodoPagoUtil {

    // Devuelve la fecha de pago correspondiente al mes de "fechaReferencia"
    public static LocalDate calcularFechaPagoMesActual(Integer diaPago, LocalDate fechaReferencia) {
        int ultimoDiaMes = fechaReferencia.lengthOfMonth();
        int dia = Math.min(diaPago, ultimoDiaMes);
        return fechaReferencia.withDayOfMonth(dia);
    }
}