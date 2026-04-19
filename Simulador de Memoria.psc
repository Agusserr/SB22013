// =======================================
// MODULO: AdministradorMemoria
// Conjunto de procedimientos y funciones para:
// - Gestion de memoria RAM (mapa de bits)
// - Traduccion de direcciones logicas a fisicas (MMU)
// - Algoritmos de reemplazo de paginas (FIFO, OPT)
// =======================================

// =======================================
// SUBPROCESOS Y FUNCIONES (FUERA DEL PROCESO PRINCIPAL)
// =======================================

// ---------- FASE 1: ESTRUCTURAS DE DATOS ----------
SubProceso InicializarRAM(MarcoOcupado Por Referencia, MarcoPagina Por Referencia)
    Definir i Como Entero
    Para i <- 0 Hasta 3 Con Paso 1 Hacer
        MarcoOcupado[i] <- 0
        MarcoPagina[i] <- -1
    FinPara
FinSubProceso

SubProceso MostrarMapaBits(MarcoOcupado, MarcoPagina)
    Definir i Como Entero
    Escribir "Mapa de bits (M0..M3):"
    Para i <- 0 Hasta 3 Con Paso 1 Hacer
        Si MarcoOcupado[i] = 0 Entonces
            Escribir "  M", i, ": 0 (libre)"
        Sino
            Escribir "  M", i, ": 1 (ocupado - pagina ", MarcoPagina[i], ")"
        FinSi
    FinPara
FinSubProceso

// ---------- FASE 2: INICIALIZACION TABLA DE PAGINAS ----------
SubProceso InicializarTablaPaginas(Presente Por Referencia, MarcoDePagina Por Referencia)
    Definir i Como Entero
    Para i <- 0 Hasta 15 Con Paso 1 Hacer
        Presente[i] <- 0
        MarcoDePagina[i] <- -1
    FinPara
FinSubProceso

// ---------- FASE 2: MMU Y TRADUCCION ----------
Funcion dirFisica <- TraducirDireccion(pag, offset, Presente, MarcoDePagina, TAM_MARCO)
    Definir marco Como Entero
    Si Presente[pag] = 0 Entonces
        dirFisica <- -1
    Sino
        marco <- MarcoDePagina[pag]
        dirFisica <- (marco * TAM_MARCO) + offset
    FinSi
FinFuncion

// ---------- UTILIDADES PARA FASE 3 ----------
SubProceso InicializarMarcos(Marcos Por Referencia, Ocupado Por Referencia)
    Definir i Como Entero
    Para i <- 0 Hasta 2 Con Paso 1 Hacer
        Marcos[i] <- -1
        Ocupado[i] <- 0
    FinPara
FinSubProceso

Funcion idx <- BuscarPagina(pag, Marcos, Ocupado)
    Definir i Como Entero
    idx <- -1
    Para i <- 0 Hasta 2 Con Paso 1 Hacer
        Si Ocupado[i] = 1 Y Marcos[i] = pag Entonces
            idx <- i
        FinSi
    FinPara
FinFuncion

Funcion idx <- BuscarLibre(Ocupado)
    Definir i Como Entero
    idx <- -1
    Para i <- 0 Hasta 2 Con Paso 1 Hacer
        Si Ocupado[i] = 0 Entonces
            idx <- i
        FinSi
    FinPara
FinFuncion

SubProceso CargarPagina(idx, pag, Marcos Por Referencia, Ocupado Por Referencia, MarcoOcupado Por Referencia, MarcoPagina Por Referencia)
    Ocupado[idx] <- 1
    Marcos[idx] <- pag
    MarcoOcupado[idx] <- 1
    MarcoPagina[idx] <- pag
FinSubProceso

// ---------- FASE 3: ALGORITMO FIFO ----------
Funcion totalFallos <- SimularFIFO(Referencias, Marcos, Ocupado, MarcoOcupado, MarcoPagina)
    Definir t, pag, libre, puntero, i, idx Como Entero
    InicializarMarcos(Marcos, Ocupado)
    totalFallos <- 0
    puntero <- 0
    
    Escribir ""
    Escribir "Simulacion FIFO:"
    Escribir "Paso  Pag  Estado    Marcos"
    
    Para t <- 0 Hasta 11 Con Paso 1 Hacer
        pag <- Referencias[t]
        idx <- BuscarPagina(pag, Marcos, Ocupado)
        
        Si idx = -1 Entonces
            totalFallos <- totalFallos + 1
            libre <- BuscarLibre(Ocupado)
            
            Si libre <> -1 Entonces
                CargarPagina(libre, pag, Marcos, Ocupado, MarcoOcupado, MarcoPagina)
                Escribir " ", t+1, "    ", pag, "   FALLO     [", Marcos[0], " ", Marcos[1], " ", Marcos[2], "]"
            Sino
                Escribir " ", t+1, "    ", pag, "   FALLO(R)  [", Marcos[0], " ", Marcos[1], " ", Marcos[2], "] -> M", puntero
                Marcos[puntero] <- pag
                MarcoPagina[puntero] <- pag
                puntero <- (puntero + 1) MOD 3
            FinSi
        Sino
            Escribir " ", t+1, "    ", pag, "   ACIERTO   [", Marcos[0], " ", Marcos[1], " ", Marcos[2], "]"
        FinSi
    FinPara
FinFuncion

// ---------- FASE 3: ALGORITMO OPT ----------
Funcion victima <- ElegirVictimaOPT(tActual, Referencias, Marcos, Ocupado)
    Definir i, k, dist, mayorDist Como Entero
    mayorDist <- -1
    victima <- 0
    
    Para i <- 0 Hasta 2 Con Paso 1 Hacer
        Si Ocupado[i] = 0 Entonces
            victima <- i
            mayorDist <- 99999
        Sino
            dist <- 9999
            k <- tActual + 1
            Mientras k <= 11 Y dist = 9999 Hacer
                Si Referencias[k] = Marcos[i] Entonces
                    dist <- k - tActual
                FinSi
                k <- k + 1
            FinMientras
            Si dist > mayorDist Entonces
                mayorDist <- dist
                victima <- i
            FinSi
        FinSi
    FinPara
FinFuncion

Funcion totalFallos <- SimularOPT(Referencias, Marcos, Ocupado, MarcoOcupado, MarcoPagina)
    Definir t, pag, libre, v, i, idx Como Entero
    InicializarMarcos(Marcos, Ocupado)
    totalFallos <- 0
    
    Escribir ""
    Escribir "Simulacion OPT:"
    Escribir "Paso  Pag  Estado    Marcos"
    
    Para t <- 0 Hasta 11 Con Paso 1 Hacer
        pag <- Referencias[t]
        idx <- BuscarPagina(pag, Marcos, Ocupado)
        
        Si idx = -1 Entonces
            totalFallos <- totalFallos + 1
            libre <- BuscarLibre(Ocupado)
            
            Si libre <> -1 Entonces
                CargarPagina(libre, pag, Marcos, Ocupado, MarcoOcupado, MarcoPagina)
                Escribir " ", t+1, "    ", pag, "   FALLO     [", Marcos[0], " ", Marcos[1], " ", Marcos[2], "]"
            Sino
                v <- ElegirVictimaOPT(t, Referencias, Marcos, Ocupado)
                Escribir " ", t+1, "    ", pag, "   FALLO(R)  [", Marcos[0], " ", Marcos[1], " ", Marcos[2], "] -> M", v
                Marcos[v] <- pag
                MarcoPagina[v] <- pag
            FinSi
        Sino
            Escribir " ", t+1, "    ", pag, "   ACIERTO   [", Marcos[0], " ", Marcos[1], " ", Marcos[2], "]"
        FinSi
    FinPara
FinFuncion

// =======================================
// PROCESO PRINCIPAL
// =======================================
Proceso SimuladorMMU
    Definir TAM_MARCO Como Entero
    TAM_MARCO <- 4096
    
    Dimension MarcoOcupado[4]
    Dimension MarcoPagina[4]
    Dimension Presente[16]
    Dimension MarcoDePagina[16]
    Dimension Marcos[3]
    Dimension Ocupado[3]
    Dimension Referencias[12]
    
    Definir dir, paginaLogica, offset, numFallosFIFO, numFallosOPT, i, marcoAsignado Como Entero
    
    // ---------- FASE 1 ----------
    Escribir "=========================================="
    Escribir "  SIMULADOR MMU - UNIDAD 1"
    Escribir "=========================================="
    Escribir ""
    Escribir ">>> FASE 1: ESTRUCTURAS DE DATOS Y MAPA DE BITS"
    Escribir "Memoria RAM: 16KB (4 marcos de 4KB)"
    Escribir ""
    
    InicializarRAM(MarcoOcupado, MarcoPagina)
    MostrarMapaBits(MarcoOcupado, MarcoPagina)
    
    // ---------- FASE 2 ----------
    Escribir ""
    Escribir ">>> FASE 2: MMU Y TRADUCCION DE DIRECCIONES"
    Escribir "Ingrese los datos para traduccion:"
    Escribir ""
    
    Escribir Sin Saltar "Numero de pagina logica (0-15): "
    Leer paginaLogica
    
    Escribir Sin Saltar "Offset dentro de la pagina (0-4095): "
    Leer offset
    
    Escribir Sin Saltar "Marco fisico asignado (0-3): "
    Leer marcoAsignado
    
    // Inicializar tabla de paginas antes de usar
    InicializarTablaPaginas(Presente, MarcoDePagina)
    
    Presente[paginaLogica] <- 1
    MarcoDePagina[paginaLogica] <- marcoAsignado
    MarcoOcupado[marcoAsignado] <- 1
    MarcoPagina[marcoAsignado] <- paginaLogica
    
    dir <- TraducirDireccion(paginaLogica, offset, Presente, MarcoDePagina, TAM_MARCO)
    
    Escribir ""
    Escribir "RESULTADO:"
    Escribir "  Pagina logica: ", paginaLogica
    Escribir "  Offset: ", offset
    Escribir "  Marco asignado: ", marcoAsignado
    Escribir "  Formula: (", marcoAsignado, " * 4096) + ", offset
    Escribir "  Direccion FISICA: ", dir
    Escribir ""
    
    MostrarMapaBits(MarcoOcupado, MarcoPagina)
    
    // ---------- FASE 3 ----------
    Escribir ""
    Escribir ">>> FASE 3: ALGORITMOS DE REEMPLAZO"
    Escribir "Marcos disponibles para el proceso: 3"
    Escribir "Secuencia de referencias (predefinida): [1,2,3,4,1,2,5,1,2,3,4,5]"
    Escribir ""
    
    // Secuencia FIJA segun el PDF - NO pedir al usuario
    Referencias[0] <- 1
    Referencias[1] <- 2
    Referencias[2] <- 3
    Referencias[3] <- 4
    Referencias[4] <- 1
    Referencias[5] <- 2
    Referencias[6] <- 5
    Referencias[7] <- 1
    Referencias[8] <- 2
    Referencias[9] <- 3
    Referencias[10] <- 4
    Referencias[11] <- 5
    
    // Reiniciar marcos para simulacion FIFO (solo 3 marcos)
    Para i <- 0 Hasta 2 Con Paso 1 Hacer
        MarcoOcupado[i] <- 0
        MarcoPagina[i] <- -1
    FinPara
    
    numFallosFIFO <- SimularFIFO(Referencias, Marcos, Ocupado, MarcoOcupado, MarcoPagina)
    Escribir ""
    Escribir "Total fallos FIFO: ", numFallosFIFO
    
    // Reiniciar marcos para simulacion OPT (solo 3 marcos)
    Para i <- 0 Hasta 2 Con Paso 1 Hacer
        MarcoOcupado[i] <- 0
        MarcoPagina[i] <- -1
    FinPara
    
    numFallosOPT <- SimularOPT(Referencias, Marcos, Ocupado, MarcoOcupado, MarcoPagina)
    Escribir ""
    Escribir "Total fallos OPT: ", numFallosOPT
    
    // ---------- RESUMEN ----------
    Escribir ""
    Escribir "=========================================="
    Escribir "  RESUMEN FINAL"
    Escribir "=========================================="
    Escribir "FASE 1: Mapa de bits - 4 marcos (M0-M3)"
    Escribir "FASE 2: Traduccion - Direccion fisica: ", dir
    Escribir "FASE 3: FIFO = ", numFallosFIFO, " fallos de pagina"
    Escribir "        OPT  = ", numFallosOPT, " fallos de pagina"
    
    Si numFallosOPT < numFallosFIFO Entonces
        Escribir ""
        Escribir "El algoritmo OPT fue mejor por ", numFallosFIFO - numFallosOPT, " fallos menos"
        Escribir "Mejora: ", ((numFallosFIFO - numFallosOPT) / numFallosFIFO * 100), "%"
    FinSi
    
    Escribir ""
    Escribir "=========================================="
    Escribir "  EJECUCION FINALIZADA"
    Escribir "=========================================="
FinProceso
