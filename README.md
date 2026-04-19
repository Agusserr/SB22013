Simulador Avanzado de Gestión de Memoria (MMU)

Información General

•	Asignatura: Sistemas Operativos / Arquitectura de Computadoras
•	Unidad: 1 - Gestión de Memoria
•	Proyecto: Simulador de Unidad de Administración de Memoria (MMU)
•	Entorno: PSeInt (Pseudocódigo Educativo Interprete)
•	Fecha de entrega: Abril 2026

Objetivo General

Diseñar y programar un simulador de Unidad de Administración de Memoria (MMU) en pseudocódigo que utilice:

•	Estructuras de datos para el rastreo de memoria libre (mapa de bits)
•	Traducción de direcciones lógicas a físicas (segmentación + paginación)
•	Algoritmos de reemplazo de páginas (FIFO y Óptimo)

Especificaciones Técnicas del Simulador

| Componente | Especificación |
|------------|---------------|
| Memoria RAM Física | 16 KB (4 marcos de 4 KB cada uno: M0, M1, M2, M3) |
| Memoria Virtual (Swap) | 32 KB |
| Tamaño de página/marco | 4 KB (4096 bytes) |
| Marcos disponibles | 4 marcos físicos (M0-M3) |
| Marcos para usuario | 3 marcos (simulación de reemplazo) |
| Tabla de páginas | Arreglos paralelos: Presente[p] y MarcoDePagina[p] |

Estructura del Código (3 Fases)

FASE 1: Estructuras de Datos y Asignación (El Administrador)

| Elemento | Implementación |
|----------|---------------|
| InicializarRAM() | SubProceso que inicializa 4 marcos en estado libre (0) |
| MostrarMapaBits() | SubProceso que imprime estado de ocupación (0=libre, 1=ocupado) |
| Arreglos | MarcoOcupado[4], MarcoPagina[4] para tracking de memoria |

Funcionamiento:

•	Inicializa la RAM como arreglo de 4 espacios (Marcos M0 a M3)
•	Mapa de bits: imprime 0 si el marco está libre, 1 si está ocupado
•	Simula la técnica de mapas de bits para gestión de memoria libre

FASE 2: La MMU y Traducción de Direcciones

| Elemento | Implementación |
|----------|---------------|
| InicializarTablaPaginas() | SubProceso que inicializa tabla de páginas (Presente[p]=0, MarcoDePagina[p]=-1) |
| TraducirDireccion(pag, offset, Presente, MarcoDePagina, TAM_MARCO) | Función que convierte dirección lógica a física |
| Fórmula | dirFisica = (MarcoDePagina[pag] * 4096) + offset |
| Manejo de fallos | Retorna -1 si la página no está cargada (bit de presente = 0) |

Proceso de traducción:

1.	Inicializa la Tabla de Páginas del proceso (Presente[p] = 0, MarcoDePagina[p] = -1)
2.	Consulta la Tabla de Páginas del proceso (Presente[p] y MarcoDePagina[p])
3.	Verifica si la página está cargada en marco físico (bit de presente)
4.	Si no está cargada: reporta fallo de página (retorna -1)
5.	Si está cargada: calcula y retorna la dirección física

Ejemplo de uso:

Entrada: Página lógica = 3, Offset = 2810, Marco asignado = 2
Cálculo: (2 * 4096) + 2810 = 8192 + 2810 = 11002
Salida: Dirección física = 11002

FASE 3: La Crisis y los Algoritmos de Reemplazo

| Elemento | Implementación |
|----------|---------------|
| Secuencia de referencias | Secuencia predefinida según PDF: [1,2,3,4,1,2,5,1,2,3,4,5] |
| Marcos disponibles | 3 marcos para el proceso de reemplazo |
| SimularFIFO() | Función que implementa First-In, First-Out |
| ElegirVictimaOPT() | Función auxiliar para seleccionar víctima óptima |
| SimularOPT() | Función que implementa algoritmo Óptimo |

Algoritmo FIFO (First-In, First-Out):

•	Reemplaza la página que lleva más tiempo en memoria
•	Usa un puntero circular (puntero = (puntero + 1) MOD 3)
•	Limitación: No considera el uso futuro de las páginas

Algoritmo Óptimo (OPT):

•	Reemplaza la página que no se usará por más tiempo en el futuro
•	Aprovecha que en el simulador sí conocemos la lista futura de peticiones
•	Ventaja: Produce el mínimo posible de fallos de página

Secuencia de prueba del PDF: [1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5]

Cómo Ejecutar el Script

Paso 1: Abrir PSeInt

1.	Iniciar el programa PSeInt (versión recomendada: 2023 o superior)
2.	Crear un nuevo archivo: Archivo → Nuevo

Paso 2: Copiar el Código

1.	Copiar todo el código del archivo Simulador de Memoria.psc
2.	Pegar en el editor de PSeInt

Paso 3: Configurar Perfil

1.	Ir a Configurar → Opciones del Lenguaje
2.	Seleccionar perfil: "Flexible" o "Estricto"
3.	Asegurar que esté habilitada la sintaxis de funciones y subprocesos

Paso 4: Ejecutar

1.	Presionar F9 o clic en Ejecutar → Iniciar
2.	Seguir las instrucciones interactivas en pantalla para Fase 2 (MMU)
3.	La Fase 3 ejecuta automáticamente la secuencia predefinida

Ejemplo de Ejecución

Entrada de datos (Fase 2 - MMU):

>>> FASE 2: MMU Y TRADUCCION DE DIRECCIONES
Ingrese los datos para traduccion:

Numero de pagina logica (0-15): 3
Offset dentro de la pagina (0-4095): 2810
Marco fisico asignado (0-3): 2

Salida de la Fase 3 (Algoritmos de Reemplazo):

>>> FASE 3: ALGORITMOS DE REEMPLAZO
Marcos disponibles para el proceso: 3
Secuencia de referencias (predefinida): [1,2,3,4,1,2,5,1,2,3,4,5]

Simulacion FIFO:
Paso  Pag  Estado    Marcos
 1     1   FALLO     [-1 -1 1]
 2     2   FALLO     [-1 2 1]
 3     3   FALLO     [3 2 1]
 4     4   FALLO(R)  [3 2 1] -> M0
 5     1   ACIERTO   [4 2 1]
 6     2   ACIERTO   [4 2 1]
 7     5   FALLO(R)  [4 2 1] -> M1
 8     1   ACIERTO   [4 5 1]
 9     2   FALLO(R)  [4 5 1] -> M2
 10    3   FALLO(R)  [4 5 2] -> M0
 11    4   FALLO(R)  [3 5 2] -> M1
 12    5   FALLO(R)  [3 4 2] -> M2

Total fallos FIFO: 9

Simulacion OPT:
Paso  Pag  Estado    Marcos
 1     1   FALLO     [-1 -1 1]
 2     2   FALLO     [-1 2 1]
 3     3   FALLO     [3 2 1]
 4     4   FALLO(R)  [3 2 1] -> M0
 5     1   ACIERTO   [4 2 1]
 6     2   ACIERTO   [4 2 1]
 7     5   FALLO(R)  [4 2 1] -> M0
 8     1   ACIERTO   [5 2 1]
 9     2   ACIERTO   [5 2 1]
 10    3   FALLO(R)  [5 2 1] -> M1
 11    4   FALLO(R)  [5 3 1] -> M1
 12    5   ACIERTO   [5 4 1]

Total fallos OPT: 7

==========================================
  RESUMEN FINAL
==========================================
FASE 1: Mapa de bits - 4 marcos (M0-M3)
FASE 2: Traduccion - Direccion fisica: 11002
FASE 3: FIFO = 9 fallos de pagina
        OPT  = 7 fallos de pagina

El algoritmo OPT fue mejor por 2 fallos menos
Mejora: 22.22%
==========================================
  EJECUCION FINALIZADA
==========================================

Análisis Comparativo: FIFO vs. OPT

Resultados Obtenidos

| Algoritmo | Fallos de Página | Rendimiento |
|-----------|-----------------|-------------|
| FIFO | 9 | 75% de fallos (9/12 accesos) |
| OPT | 7 | 58% de fallos (7/12 accesos) |

¿Por qué OPT superó a FIFO?

1.	Naturaleza del Algoritmo FIFO (First-In, First-Out)

•	Mecanismo: Reemplaza la página que lleva más tiempo en memoria
•	Problema: No considera el uso futuro de las páginas
•	Comportamiento en esta secuencia:

o	Al llegar la página 4, expulsa la página 3 (la más antigua)
o	Posteriormente, al llegar página 5, expulsa la página 2
o	Al llegar página 2 nuevamente (paso 9), debe cargarla de nuevo → fallo
o	Este patrón se repite, generando fallos evitables

2.	Naturaleza del Algoritmo Óptimo (OPT)

•	Mecanismo: Reemplaza la página que no se usará por más tiempo en el futuro
•	Ventaja: Conoce la secuencia futura de peticiones (en este simulador)
•	Comportamiento en esta secuencia:

o	Al llegar la página 4 (paso 4), analiza que la página 3 no se usará pronto
o	Expulsa la página 3 en lugar de la 1
o	La página 1 se mantiene disponible → evita fallo cuando se necesita (paso 5)
o	Al llegar página 5 (paso 7), analiza que la página 4 no se usará pronto
o	Expulsa la página 4, manteniendo 1 y 2 que se usarán pronto

3.	Análisis Matemático de la Diferencia

FIFO:  [1][2][3] → 4 llega → [4][2][3] → 5 llega → [4][5][3] → 1 llega → [4][5][1]
       (fallo)      (fallo)      (fallo)      (fallo)

OPT:   [1][2][3] → 4 llega → [1][2][4] → 5 llega → [5][2][1] → 1 llega → [5][2][1]
       (fallo)      (fallo)      (fallo)      (acierto)
       
Diferencia clave: OPT evitó 2 fallos al mantener páginas que se reutilizarán pronto.

Limitación del Algoritmo Óptimo en la Vida Real

La Paradoja del "Algoritmo Perfecto"

Aunque el algoritmo Óptimo (OPT) demuestra el mejor rendimiento teórico posible, tiene una limitación fundamental que lo hace imposible de implementar en sistemas reales:

El Problema del Conocimiento del Futuro

| Aspecto | Simulador (OPT) | Vida Real |
|---------|----------------|-----------|
| Conocimiento | Conoce toda la secuencia de referencias de antemano | No conoce el futuro |
| Decisión | Puede calcular qué página usará más tarde | Debe decidir sin información futura |
| Implementación | Posible porque es una simulación | Imposible requerir adivinación |

Analogía Práctica

Ejemplo cotidiano: Elegir qué ropa guardar en un armario pequeño
•	FIFO: Guardas la ropa que hace más tiempo no usas (sin importar si la necesitarás mañana)
•	OPT: Guardarías la ropa que sabes que no usarás en los próximos 6 meses
•	Problema: En la vida real, no sabes con certeza qué ropa necesitarás mañana

Alternativas Prácticas en Sistemas Reales

Por esta limitación, los sistemas operativos reales utilizan aproximaciones:

| Algoritmo Real | Mecanismo | Aproximación a OPT |
|----------------|-----------|-------------------|
| LRU (Least Recently Used) | Reemplaza la menos usada recientemente | Asume que el pasado predice el futuro |
| LFU (Least Frequently Used) | Reemplaza la menos frecuentemente usada | Prioriza páginas con más accesos históricos |
| Reloj (Second Chance) | Da una "segunda oportunidad" antes de expulsar | Balance entre FIFO y LRU |

Conclusión sobre la Limitación

El algoritmo Óptimo (OPT) es valioso como referencia teórica para:
1.	Evaluar límites de rendimiento: Ningún algoritmo real puede superar a OPT
2.	Comparar algoritmos prácticos: Medir qué tan cerca están de la perfección
3.	Diseñar mejores algoritmos: Inspirar heurísticas como LRU que aproximan el comportamiento óptimo

En este simulador, OPT obtuvo 7 fallos vs. 9 de FIFO, demostrando una mejora del 22% que representa el límite teórico máximo para esta secuencia de referencias.

Conclusiones del Proyecto

Aprendizajes Técnicos

1.	Estructuras de datos: Implementación de mapas de bits y tablas de páginas en pseudocódigo
2.	Traducción de direcciones: Comprensión del mecanismo de paginación en sistemas operativos
3.	Algoritmos de reemplazo: Diferencias fundamentales entre estrategias FIFO y Óptimo
4.	Modularidad: Uso de funciones y subprocesos para organizar código complejo
5.	Inicialización segura: Importancia de inicializar estructuras antes de usarlas (tabla de páginas)

Aprendizajes Conceptuales

1.	Trade-offs en diseño: No existe el "mejor" algoritmo absoluto; depende del contexto
2.	Teoría vs. práctica: Algoritmos teóricamente perfectos pueden ser impracticables
3.	Importancia de la localidad: Los patrones de acceso a memoria determinan el rendimiento
4.	Predecibilidad: Conocer patrones de acceso permite optimizaciones (como en OPT)

Aplicación Práctica

Este simulador demuestra por qué los sistemas operativos modernos invierten recursos en:
•	Predicción de patrones de acceso (branch prediction, prefetching)
•	Jerarquías de memoria caché (L1, L2, L3)
•	Algoritmos adaptativos que cambian según el comportamiento del programa

Referencias

1.	Silberschatz, A., Galvin, P. B., & Gagne, G. (2018). Operating System Concepts (10th ed.). Wiley.
2.	Tanenbaum, A. S. (2015). Modern Operating Systems (4th ed.). Pearson.
3.	PSeInt Documentation. (2023). Manual de referencia del lenguaje. Retrieved from pseint.sourceforge.net
