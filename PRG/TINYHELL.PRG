//------------------------------------------------------------------------------
// TITULO:      VSHOOT10.PRG - Sistema Completo de Juego con Cinemáticas
// AUTOR:       Sebastian J. MONCHO MAQUET
// FECHA:       02/02/2026
// DESCRIPCION: Sistema de niveles con dificultad progresiva y narrativa completa.
//              - 14 niveles (LEVEL000.FPG a LEVEL013.FPG) con música específica por rangos
//              - Numero creciente de enemigos: nivel 0=40, nivel 1=50, ..., nivel 13=160+
//              - Distribucion escalonada en cada nivel: pocos enemigos al inicio, mas al final
//              - Sistema de vidas (3 toques antes de morir)
//              - 11 cinemáticas con narrativa basada en Tanya the Evil (lore de "Youjo Senki")
//              - Música dinámica: LEVEL02/03/04/07/08/10/12/13.WAV + ENDING.WAV para cinemática final
//              - Controles: flechas para mover, espacio para disparar, ESC para salir
//              - Final completo con vuelta automática al menú principal

//
// NOTA:        Usa las flechas para mover la nave, espacio para disparar y ESC para salir.
//              Requiere DIV2.PAL, todos los FPG de la carpeta FPG/TANYA, los WAV de WAV/TANYA y los FNT de la carpeta FNT/TANYA.
//              Hace uso de los sonidos de disparo de los ejemplos de DIV2 (TOKENKAI)
//              Codigo y comentarios en castellano para facilitar la comprension.
//------------------------------------------------------------------------------

PROGRAM vshooter;
// Constantes del juego
CONST
    // Las constantes son variables inmutables que definen parametros del juego.
    // No se pueden cambiar durante la ejecucion del programa.
    // Estas constantes controlan aspectos como resolucion, velocidad, colores y tamanos.
    // El compilador traduce estas constantes directamente en valores fijos en el codigo maquina.
    // Usar constantes reduce el consumo de memoria y los calculos en tiempo de ejecucion.
    // - Si haces una resta o una suma entre constantes, el compilador lo calcula en tiempo de compilacion y no entiempo de ejecucion.

    _DEBUG_ = 0;    // Flag de debug (0 = desactivado, 1 = activado). Sirve para saltar el nivel con la tecla P y ver el consumo de RAM y el contador de FPS en pantalla.

    // Mensajes de texto al salir del juego
    TEXTO_SALIDA = "Hasta la próxima, camarada.";

    // Resolucion y rendimiento
    // 320x200 pixeles a 60 FPS
    ANCHO_PANTALLA = 320;
    ALTO_PANTALLA = 200;
    FPS_JUEGO = 60;

    // Parametros del jugador
    VEL_JUGADOR = 3;                // Velocidad de movimiento de la nave del jugador
    TIEMPO_DISPARO_JUGADOR = 5;     // Tiempo minimo entre disparos del jugador (en frames)
    VEL_BALA_JUGADOR = 5;           // Velocidad de las balas disparadas por el jugador
    COLOR_NAVE = 31;                // Color de la nave del jugador (paleta DIV2.PAL)
    DISTANCIA_COLISION_JUGADOR = 12; // Distancia de colision para el jugador
    TAMANO_NAVE_X = 8;              // Tamano horizontal de la nave del jugador en pixeles
    TAMANO_NAVE_Y_ALTURA = 10;      // Altura del vertice superior de la nave del jugador en pixeles

    // Parametros de enemigos
    NUM_ENEMIGOS_MAXIMOS = 160;     // Numero maximo de enemigos (nivel 12 = 160 enemigos)
    NUM_ENEMIGOS_NIVEL_0 = 40;      // Numero de enemigos en nivel 0
    INCREMENTO_ENEMIGOS_POR_NIVEL = 10;  // Incremento de enemigos por cada nivel (+10)
    DISTANCIA_COLISION = 12;        // Distancia minima para considerar una colision entre objetos
    DISTANCIA_COLISION_CUADRADO = 144;  // DISTANCIA_COLISION * DISTANCIA_COLISION (optimizacion)
    DISTANCIA_COLISION_JUGADOR = 12; // Distancia de colision para el jugador
    DISTANCIA_COLISION_JUGADOR_CUADRADO = 144;  // DISTANCIA_COLISION_JUGADOR * DISTANCIA_COLISION_JUGADOR (optimizacion)
    PUNTOS_POR_ENEMIGO = 10;        // Puntos otorgados por destruir a un enemigo

    // Enemigo tipo 1
    VEL_ENEMIGO1_HORIZONTAL = 2;    // Velocidad horizontal del enemigo tipo 1
    DESCENSO_ENEMIGO1 = 5;          // Descenso vertical del enemigo tipo 1 al cambiar de direccion
    TIEMPO_DISPARO_ENEMIGO1 = 80;   // Tiempo entre disparos del enemigo tipo 1 (en frames)
    COLOR_ENEMIGO1 = 114;           // Color del enemigo tipo 1 (paleta DIV2.PAL)
    TAMANO_ENEMIGO1 = 8;            // Tamano del enemigo tipo 1 en pixeles

    // Enemigo tipo 2
    INCREMENTO_ANGULO_ENEMIGO2 = 5000;  // Incremento del angulo para movimiento circular del enemigo tipo 2
    RADIO_MOVIMIENTO_ENEMIGO2 = 1;      // Radio del movimiento circular del enemigo tipo 2
    TIEMPO_DISPARO_ENEMIGO2 = 65;       // Tiempo entre disparos del enemigo tipo 2 (en frames)
    COLOR_ENEMIGO2 = 9;                 // Color del enemigo tipo 2 (paleta DIV2.PAL)
    TAMANO_ENEMIGO2_LINEA = 8;          // Tamano de las lineas del enemigo tipo 2 en pixeles
    TAMANO_ENEMIGO2_CIRCULO = 2;        // Tamano del circulo interno del enemigo tipo 2 en pixeles

    // Enemigo tipo 3
    VEL_ENEMIGO3_VERTICAL = 2;          // Velocidad vertical del enemigo tipo 3 (de arriba a abajo)
    VEL_ENEMIGO3_HORIZONTAL = 1;        // Velocidad horizontal del enemigo tipo 3 (acercándose al jugador)
    COLOR_ENEMIGO3 = 114;               // Color del enemigo tipo 3 (paleta DIV2.PAL)

    // Balas
    MAX_BALAS_JUGADOR = 50;            // Numero maximo de balas simultaneas del jugador
    MAX_BALAS_ENEMIGO = 150;            // Numero maximo de balas simultaneas de enemigos
    TIPO_BALA_ENEMIGA1 = 1;             // Tipo de bala: enemigo tipo 1
    TIPO_BALA_ENEMIGA2 = 2;             // Tipo de bala: enemigo tipo 2
    VEL_BALA_ENEMIGA1 = 3;              // Velocidad de las balas disparadas por el enemigo tipo 1
    VEL_BALA_ENEMIGA2 = 2;              // Velocidad de las balas disparadas por el enemigo tipo 2
    ANGULO_DEFECTO_BALA = 90000;        // Angulo por defecto para balas enemigas (hacia abajo)
    TAMANO_BALA_JUGADOR = 3;            // Tamano de las balas disparadas por el jugador en pixeles
    TAMANO_BALA_ENEMIGA1 = 2;           // Tamano de las balas disparadas por el enemigo tipo 1 en pixeles
    TAMANO_BALA_ENEMIGA2 = 3;           // Tamano de las balas disparadas por el enemigo tipo 2 en pixeles

    // Explosiones
    RADIO_INICIAL_EXPLOSION = 3;        // Radio inicial de la explosion en pixeles
    INCREMENTO_RADIO_EXPLOSION = 2;     // Incremento del radio por iteracion en pixeles
    FRAMES_ESPERA_EXPLOSION = 2;        // Frames a esperar para ver la explosion antes de game over
    FRAMES_ANIMACION_EXPLOSION = 9;     // Numero de frames para la animacion de explosion
    OFFSET_DISPARO_Y = 30;              // Offset Y para la posicion del disparo del jugador

    // Cuenta regresiva
    SEGUNDOS_CUENTA_REGRESIVA = 3;      // Segundos para la cuenta regresiva al acabar un nivel

    // Posiciones de UI
    POS_X_ETIQUETAS = 10;               // Posicion X para etiquetas de texto
    POS_Y_PUNTOS = 10;                  // Posicion Y para "PUNTOS:"
    POS_Y_NIVEL = 20;                   // Posicion Y para "NIVEL:"
    POS_X_VALORES = 80;                 // Posicion X para valores de puntos y nivel
    CENTRO_X = ANCHO_PANTALLA / 2;      // Centro horizontal de la pantalla
    CENTRO_Y = ALTO_PANTALLA / 2;       // Centro vertical de la pantalla
    POS_Y_FPS = 190;                    // Posicion Y para "FPS:"
    POS_X_FPS = 40;                     // Posicion X para valor de FPS

    // Parametros de dibujo
    OPACIDAD_DRAW = 15;                 // Opacidad para dibujos (0-15)
    REGION_DRAW = 0;                    // Region para dibujos (normalmente 0)
    ALINEACION_CENTRADO = 4;            // Alineacion centrada para textos
    ALINEACION_IZQUIERDA = 0;           // Alineacion izquierda para textos
    TIPO_DIBUJO_CIRCULO_RELLENO = 5;   // Tipo de dibujo para circulos rellenos

    // Parametros de colision y optimizacion
    MARGEN_BOUNDING_BOX = 20;           // Margen para bounding box de colision rapida
    VARIACION_TIEMPO_DISPARO_ENEMIGO = 15; // Variacion aleatoria en tiempo de disparo enemigo

    // Colores adicionales
    COLOR_EXPLOSION_PEQUENA = 61;       // Color para explosiones pequenas

    // Parametros de explosiones
    ITERACIONES_EXPLOSION_PEQUENA = 3; // Numero de iteraciones para explosion pequena

    // Parametros de graficos y rotaciones
    GRAFICO_ENEMIGO1 = 2;               // Grafico FPG para enemigo tipo 1
    GRAFICO_ENEMIGO2 = 3;               // Grafico FPG para enemigo tipo 2
    ANGULO_ROTACION_ENEMIGO = 15000;   // Angulo de rotacion para enemigos tipo 1 (15 grados * 1000)
    ANGULO_ROTACION_ENEMIGO_OPUESTA = 345000; // Angulo opuesto (360° - 15°)
    ESCALA_ENEMIGO = 100;               // Escala para xput de enemigos

    // Posiciones de texto para pantallas de cuenta regresiva
    POS_Y_CUENTA_REGRESIVA_BASE = 30;   // Posicion Y base para mensajes de cuenta regresiva
    ESPACIADO_LINEA_NORMAL = 30;        // Espaciado entre lineas de texto normal

    // Posiciones de texto para pantalla de game over
    ESPACIADO_GAMEOVER = 30;            // Espaciado vertical para textos en game over
    POS_Y_GAMEOVER = CENTRO_Y - ESPACIADO_GAMEOVER;  // Posicion Y para "GAME OVER!"
    POS_Y_PUNTOS_GAMEOVER = CENTRO_Y;   // Posicion Y para puntos en game over
    POS_Y_PULSA_ESPACIO = CENTRO_Y + ESPACIADO_GAMEOVER;  // Posicion Y para "[PULSA ESPACIO]"

    // Parametros del scroll
    ALTO_MAPA = 1536;                   // Altura total del mapa en pixeles
    VELOCIDAD_SCROLL = 1;               // Velocidad de desplazamiento automatico del scroll (1 pixel cada 3 frames)
    MARGEN_VISIBLE_ARRIBA = 30;         // Margen superior para considerar enemigos visibles (fuera de pantalla)
    MARGEN_VISIBLE_ABAJO = 50;          // Margen inferior para considerar enemigos visibles (fuera de pantalla)
    MARGEN_INFERIOR_JUGADOR = 20;       // Margen minimo del jugador respecto al borde inferior visible
    MARGEN_LATERAL = 20;                // Margen lateral para posicionar enemigos
    MARGEN_SUPERIOR = 30;               // Margen superior para posicionar enemigos
    MARGEN_CORTESIA_INICIAL = 300;      // Margen de cortesia desde el inicio (no generar enemigos cerca del jugador)

    // Sistema de niveles
    NUM_NIVELES = 14;               // Total de niveles diferentes (LEVEL000.FPG a LEVEL009.FPG)
    NIVEL_INICIAL = 0;              // Nivel inicial del juego (0-9)

    // Distribucion escalonada de enemigos por zonas
    // Estas son proporciones que se aplicaran segun el numero de enemigos del nivel
    // Zona alta (Y bajas) = se ve cuando el scroll ha subido mucho
    // Zona baja (Y altas) = se ve al principio del juego
    PROPORCION_ZONA_ALTA = 38;        // 38% enemigos en zona alta (mas dificil cuando scroll sube)
    PROPORCION_ZONA_MEDIA_ALTA = 31;  // 31% enemigos en zona media-alta
    PROPORCION_ZONA_MEDIA = 19;       // 19% enemigos en zona media
    PROPORCION_ZONA_BAJA = 12;        // 12% enemigos en zona baja (al inicio, mas facil)

    // Limites Y de las zonas de spawneo
    Y_LIMITE_ZONA_ALTA = 400;         // Zona alta: 0-400px
    Y_LIMITE_ZONA_MEDIA_ALTA = 800;   // Zona media-alta: 400-800px
    Y_LIMITE_ZONA_MEDIA = 1000;       // Zona media: 800-1000px
    // Zona baja: 1000 hasta ALTO_MAPA-MARGEN_CORTESIA_INICIAL

    // Rutas de archivos
    RUTA_PALETA = "DIV2.PAL";           // Ruta de la paleta de colores
    RUTA_FPG_LEVEL = "TANYA/LEVEL000.FPG"; // Ruta del FPG del nivel
    RUTA_FPG_PLAYER = "TANYA/PLAYER.FPG";  // Ruta del FPG del jugador
    RUTA_FPG_PLAYERME = "TANYA/PLAYERME.FPG";  // Ruta del FPG del jugador con dano medio
    RUTA_FPG_PLAYERLO = "TANYA/PLAYERLO.FPG";  // Ruta del FPG del jugador con dano bajo
    RUTA_FNT_HUD = "TANYA/HUD.FNT";   // Ruta del FNT para HUD
    RUTA_FNT_NORMAL = "TANYA/NORMAL.FNT";  // Ruta del FNT normal
    RUTA_FNT_COUNTER = "TANYA/COUNTER.FNT"; // Ruta del FNT para contadores
    RUTA_FNT_PRESS = "TANYA/PRESS.FNT";     // Ruta del FNT para "PULSA ESPACIO"
    RUTA_FNT_GAMEOVER = "TANYA/GAMEOVER.FNT"; // Ruta del FNT para "GAME OVER"
    RUTA_FNT_COPY = "TANYA/COPY.FNT";        // Ruta del FNT para créditos
    RUTA_FNT_X = "TANYA/X.FNT";        // Ruta del FNT para cuenta Twitter
    RUTA_FPG_START = "TANYA/START.FPG";   // Ruta del FPG para pantalla de inicio
    RUTA_WAV_TITLE = "TANYA/TITLE.WAV";   // Ruta del WAV para música de pantalla de inicio
    RUTA_WAV_DISPARO = "../PCM/TOKENKAI/PISTOLA0.WAV"; // Ruta del WAV para sonido de disparo (incluído en los ejemplos de DIV2, NO EN MI GITHUB)

    // Rutas de archivos para cinematicas
    RUTA_FPG_CG001 = "TANYA/CG001.FPG"; // Ruta del FPG para cinematica 1
    RUTA_FPG_CG002 = "TANYA/CG002.FPG"; // Ruta del FPG para cinematica 2
    RUTA_FPG_CG003 = "TANYA/CG003.FPG"; // Ruta del FPG para cinematica 3
    RUTA_FPG_CG004 = "TANYA/CG004.FPG"; // Ruta del FPG para cinematica 4
    RUTA_FPG_CG005 = "TANYA/CG005.FPG"; // Ruta del FPG para cinematica 5
    RUTA_FPG_CG006 = "TANYA/CG006.FPG"; // Ruta del FPG para cinematica 6
    RUTA_FPG_CG007 = "TANYA/CG007.FPG"; // Ruta del FPG para cinematica 7
    RUTA_FPG_CG008 = "TANYA/CG008.FPG"; // Ruta del FPG para cinematica 8
    RUTA_FPG_CG009 = "TANYA/CG009.FPG"; // Ruta del FPG para cinematica 9
    RUTA_FPG_CG010 = "TANYA/CG010.FPG"; // Ruta del FPG para cinematica 10
    RUTA_FPG_CG011 = "TANYA/CG011.FPG"; // Ruta del FPG para cinematica 11
    RUTA_FPG_CG012 = "TANYA/CG012.FPG"; // Ruta del FPG para cinematica 12
    RUTA_FPG_CG013 = "TANYA/CG013.FPG"; // Ruta del FPG para cinematica 13
    RUTA_FPG_CG014 = "TANYA/CG014.FPG"; // Ruta del FPG para cinematica 14
    RUTA_FPG_CG015 = "TANYA/CG015.FPG"; // Ruta del FPG para cinematica 15
    RUTA_FPG_CG016 = "TANYA/CG016.FPG"; // Ruta del FPG para cinematica 16
    RUTA_FPG_CG017 = "TANYA/CG017.FPG"; // Ruta del FPG para cinematica 17
    RUTA_FPG_CG018 = "TANYA/CG018.FPG"; // Ruta del FPG para cinematica 18
    RUTA_FPG_CG019 = "TANYA/CG019.FPG"; // Ruta del FPG para cinematica 19
    RUTA_FPG_CG020 = "TANYA/CG020.FPG"; // Ruta del FPG para cinematica 20
    RUTA_FPG_CG021 = "TANYA/CG021.FPG"; // Ruta del FPG para cinematica 21
    RUTA_WAV_CG001 = "TANYA/CG001.WAV"; // Ruta del WAV para música de cinematica 1
    RUTA_WAV_CG002 = "TANYA/CG002.WAV"; // Ruta del WAV para música de cinematica 2
    RUTA_WAV_CG003 = "TANYA/CG003.WAV"; // Ruta del WAV para música de cinematica 3
    RUTA_WAV_CG004 = "TANYA/CG004.WAV"; // Ruta del WAV para música de cinematica 4
    RUTA_WAV_LEVEL01 = "TANYA/LEVEL01.WAV"; // Ruta del WAV para música del nivel 1
    RUTA_WAV_LEVEL02 = "TANYA/LEVEL02.WAV"; // Ruta del WAV para música del nivel 2
    RUTA_WAV_LEVEL03 = "TANYA/LEVEL03.WAV"; // Ruta del WAV para música del nivel 3
    RUTA_WAV_LEVEL04 = "TANYA/LEVEL04.WAV"; // Ruta del WAV para música del nivel 4
    RUTA_WAV_LEVEL7 = "TANYA/LEVEL07.WAV"; // Ruta del WAV para música del nivel 7
    RUTA_WAV_LEVEL08 = "TANYA/LEVEL08.WAV"; // Ruta del WAV para música del nivel 8
    RUTA_WAV_LEVEL10 = "TANYA/LEVEL10.WAV"; // Ruta del WAV para música del nivel 10
    RUTA_WAV_LEVEL12 = "TANYA/LEVEL12.WAV"; // Ruta del WAV para música del nivel 12
    RUTA_WAV_LEVEL13 = "TANYA/LEVEL13.WAV"; // Ruta del WAV para música del nivel 13
    RUTA_WAV_ENDING = "TANYA/ENDING.WAV"; // Ruta del WAV para música de la cinemática final
    VOL_MAX = 256;                      // Volumen máximo (0 mínimo, 256 máximo)
    FREQ_NORMAL = 256;                  // Frecuencia normal (0 grave máximo, 256 normal, 512 agudo máximo)
    FREQ_AGUDA = 512;                   // Frecuencia aguda máxima
    LOOP_NO = 0;                        // Reproducción normal (no bucle)
    LOOP_SI = 1;                        // Reproducción en bucle
    FONDO_SD = 1;                         // Fondo de pantalla (screen data)

    // Parametros del menu principal
    MENU_ANCHO = 160;                   // Ancho del recuadro del menu
    MENU_ALTO = 50;                     // Alto del recuadro del menu
    MENU_Y = ALTO_PANTALLA - MENU_ALTO; // Posicion Y del menu (parte inferior)
    MENU_X = (ANCHO_PANTALLA - MENU_ANCHO) / 2; // Posicion X del menu (centrado)
    FRECUENCIA_PARPADEO_INICIO = 15;    // Frames entre cada cambio de visibilidad en pantalla inicio

    // Parametros de cinematicas
    CG_ALTO_IMAGEN = 150;               // Alto de la imagen de fondo de cinematica (0-150)
    CG_ALTO_DIALOGO = 50;               // Alto del area de dialogo (150-200)
    CG_Y_DIALOGO = 150;                 // Posicion Y donde empieza el area de dialogo
    CG_ANCHO = 320;                     // Ancho de la cinematica (pantalla completa)
    CG_ESPACIADO_LINEA = 10;            // Espaciado entre lineas de texto en cinematica
    CG_Y_TEXTO_BASE = 160;              // Posicion Y base para empezar a escribir texto
    CG_POS_X_ENTER = 295;               // Posicion X para texto [ENTER] (esquina inferior derecha)
    CG_POS_Y_ENTER = 175;               // Posicion Y para texto [ENTER]
    CG_FRECUENCIA_PARPADEO_ENTER = 20;  // Frames entre cada cambio de visibilidad del texto [ENTER]
    FRAMES_FADE = 30;                   // Frames para fundido (0.5 segundos a 60 FPS)

    // Parametros del menu de pausa de cinematicas
    MENU_CG_ANCHO = 200;                // Ancho del menu de pausa de cinematica
    MENU_CG_ALTO = 90;                  // Alto del menu de pausa de cinematica
    MENU_CG_OPCIONES = 4;               // Numero de opciones del menu
    MENU_CG_ESPACIADO = 15;             // Espaciado entre opciones

    // Sistema de vidas del jugador
    VIDAS_INICIALES = 3;                // Numero de vidas iniciales (3 toques antes de morir)
    TIEMPO_INMUNIDAD = 180;             // Tiempo de inmunidad tras recibir dano (3 segundos a 60 FPS)
    FRECUENCIA_PARPADEO = 5;            // Frames entre cada cambio de visibilidad durante parpadeo
    FRECUENCIA_PARPADEO_GAMEOVER = 30;  // Frames entre cada cambio de visibilidad en pantalla game over

// Variables globales del juego
// Estas variables mantienen el estado del juego y son accesibles desde cualquier parte del programa.
GLOBAL
    INT puntos = 0;                     // Puntuacion actual del jugador

    // Sistema de puntuaciones altas (top 10)
    STRUCT top_scores[10]
        INT score;                      // Puntuacion
    END
    INT enemigos_vivos = 0;             // Numero de enemigos vivos en el nivel actual
    INT nivel = 1;                      // Contador de niveles completados (para mostrar al jugador)
    INT nivel_actual = 0;               // Nivel FPG actual (0-9, cicla al llegar a 10)
    INT num_enemigos_nivel = 0;         // Numero de enemigos en el nivel actual
    game_over = 0;                      // Indicador de estado de juego (0 = jugando, 1 = game over)
    enemigo_muerto_id = 0;              // ID del enemigo marcado como "muerto"
    controles_activos = 0;              // Contemplaa si los controles del jugador estan activos (1) o desactivados (0), empleado, por ejemplo, durante la cuenta regresiva
    STRING musica_actual = "";          // Ruta de la música actualmente sonando
    primera_bala_jugador_activa = -1;   // Indice de la primera bala jugador activa en la lista enlazada (-1 = lista vacia)
    primer_slot_libre_jugador = 0;      // Indice del primer slot libre para balas jugador
    primera_bala_enemigo_activa = -1;   // Indice de la primera bala enemigo activa en la lista enlazada (-1 = lista vacia)
    primer_slot_libre_enemigo = 0;      // Indice del primer slot libre para balas enemigo
    primera_enemigo_activo = -1;        // Indice del primer enemigo activo en la lista enlazada (-1 = lista vacia)
    FPG_LEVEL = 0;                      // Codigo del fichero FPG del nivel
    FPG_PLAYER = 0;                     // Codigo del fichero FPG del jugador
    FNT_HUD = 0;                        // Codigo del fichero FNT para el HUD
    FNT_NORMAL = 0;                     // Codigo del fichero FNT normal
    FNT_COUNTER = 0;                    // Codigo del fichero FNT para contadores
    FNT_PRESS = 0;                      // Codigo del fichero FNT para "PULSA ESPACIO"
    FNT_GAMEOVER = 0;                   // Codigo del fichero FNT para "GAME OVER"
    FNT_COPY = 0;                       // Codigo del fichero FNT para créditos
    FNT_X = 0;                          // Codigo del fichero FNT para cuenta Twitter
    FPG_START = 0;                      // Codigo del fichero FPG para pantalla de inicio
    WAV_CHANNEL = 0;                    // Canal de sonido para la música de fondo
    WAV_MUSIC = 0;                      // Codigo del fichero WAV para música de pantalla de inicio
    WAV_DISPARO = 0;                    // Codigo del fichero WAV para el disparo
    scroll_y_objetivo = 0;              // Posicion Y objetivo del scroll (para movimiento automatico)
    contador_scroll = 0;                // Contador para scroll lento (mueve 1 pixel cada 3 frames)
    vidas_jugador = VIDAS_INICIALES;    // Vidas actuales del jugador (3 = salud completa, 2 = dano medio, 1 = dano critico, 0 = muerte)
    jugador_inmune = 0;                 // Flag de inmunidad temporal (0 = vulnerable, >0 = inmune con contador)
    FPG_PLAYERME = 0;                   // Codigo del fichero FPG del jugador con dano medio
    FPG_PLAYERLO = 0;                   // Codigo del fichero FPG del jugador con dano bajo
    juego_pausado = 0;                  // Flag de pausa del juego (0 = jugando, 1 = pausado)
    volver_menu = 0;                    // Flag para volver al menu principal (0 = continuar, 1 = volver al menu)
    salir_juego = 0;                    // Flag para salir del juego (0 = continuar, 1 = salir)
    saltar_cinematica = 0;              // Flag para saltar la cinematica actual (0 = no, 1 = si)
    resultado_pagina_global = -1;       // Resultado de pagina cinematica
    resultado_menu_global = -1;         // Resultado del menu de pausa de cinematicas
    memoria_inicial = 0;                // Memoria libre al arrancar el juego (en KB)
    memoria_usada = 0;                  // Memoria consumida por el juego (en KB)

    // Definicion de struct para enemigo
    STRUCT enemigo[NUM_ENEMIGOS_MAXIMOS]
        INT x;       // Posicion X
        INT y;       // Posicion Y
        INT tipo;    // Tipo de enemigo (1, 2 o 3)
        INT activo;  // Si esta activo (1) o muerto/inactivo (0)
        INT dir;     // Direccion horizontal para tipo1 (1 derecha, -1 izquierda)
        INT ang;     // Angulo para movimiento circular de tipo2
        INT grafico_tipo3; // Grafico aleatorio para tipo3 (GRAFICO_ENEMIGO1 o GRAFICO_ENEMIGO2)
        INT siguiente; // Indice del siguiente enemigo activo (-1 = fin de lista)
    END

    // Definicion de struct para balas del jugador (OPTIMIZACION: Lista enlazada separada)
    // Almacena balas del jugador en array con lista enlazada para optimizar acceso
    STRUCT bala_jugador[MAX_BALAS_JUGADOR]
        INT x;         // Posicion X de la bala
        INT y;         // Posicion Y de la bala
        INT activo;    // Si esta activa (1) o inactiva (0)
        INT dx;        // Delta X precalculado para movimiento (siempre 0 para jugador)
        INT dy;        // Delta Y precalculado para movimiento (hacia arriba)
        INT tamano;    // Tamano precalculado para dibujo
        INT color;     // Color precalculado para dibujo
        INT draw_id;   // ID del dibujo de la bala
        INT siguiente; // Indice del siguiente slot en la lista (-1 = fin de lista)
    END

    // Definicion de struct para balas enemigas (OPTIMIZACION: Lista enlazada separada)
    // Almacena balas enemigas en array con lista enlazada para optimizar acceso
    STRUCT bala_enemigo[MAX_BALAS_ENEMIGO]
        INT x;         // Posicion X de la bala
        INT y;         // Posicion Y de la bala
        INT tipo;      // Tipo de bala enemiga (1=enemigo1, 2=enemigo2)
        INT activo;    // Si esta activa (1) o inactiva (0)
        INT angulo;    // Angulo de movimiento (para balas enemigo tipo 2)
        INT dx;        // Delta X precalculado para movimiento
        INT dy;        // Delta Y precalculado para movimiento
        INT tamano;    // Tamano precalculado para dibujo
        INT color;     // Color precalculado para dibujo
        INT draw_id;   // ID del dibujo de la bala
        INT siguiente; // Indice del siguiente slot en la lista (-1 = fin de lista)
    END

    // Estructuras de datos para cinematicas
    STRUCT cinematics[10]
        INT num_cg;
        INT siguiente_nivel;
        STRUCT cgs[5]
            STRING fpg_ruta;
            STRING pal_ruta;
            STRING wav_ruta;
            INT num_paginas;
            STRUCT paginas[10]
                STRING linea1[50];
                STRING linea2[50];
                STRING linea3[50];
                STRING linea4[50];
            END
        END
    END

// Variables internas
// Estas variables son utilizadas dentro del programa principal para gestionar la logica del juego.
// No son accesibles desde otros procesos o funciones, incluyendo sus procesos hijos.
PRIVATE
    procesos_tipo1 = 0;                 // Contador temporal de procesos vivos del enemigo tipo 1
    procesos_tipo2 = 0;                 // Contador temporal de procesos vivos del enemigo tipo 2
    temp_id = 0;                        // ID temporal para iterar sobre procesos
    INT i = 0;                          // Variable de bucle
// Programa principal
// Posee el bucle principal del juego que gestiona la logica general, niveles y condiciones de victoria/derrota.
BEGIN
    // Capturar memoria libre antes de cargar recursos
    memoria_inicial = memory_free();

    // Arrancamos el juego a 320x200 a 60 FPS con la paleta cargada
    /* En DIV se suelen usar constantes como m320x200, pero aqui definimos la resolucion manualmente
       Al compilar, estas constantes se traducen en valores numericos.
       Podemos poner esos valores fijos directamente si queremos.
    Resoluiones disponibles en DIV y DIV2:
        m320x200 = 320200   VGA estandar
        m320x240 = 320240   Modo X
        m320x400 = 320400   Modo X
        m360x240 = 360240   Modo X
        m360x360 = 360360   Modo X
        m376x282 = 376282   Modo X
        m640x400 = 640400   SVGA VESA
        m640x480 = 640480   SVGA VESA
        m800x600 = 800600   SVGA VESA
        m1024x768 = 1024768 SVGA VESA
     */
    set_mode(ANCHO_PANTALLA * 1000 + ALTO_PANTALLA);
    set_fps(FPS_JUEGO, 0);

    cargar_recursos_juego();
    init_cinematics();

    iniciar_nueva_partida();

    // Bucle principal del juego
    LOOP
        // Verificar si debemos salir del juego
        IF (salir_juego == 1)
            exit(TEXTO_SALIDA, 0);
        END

        // Verificar si debemos volver al menu principal
        IF (volver_menu == 1)
            // Limpiar todos los procesos
            let_me_alone();

            // Detener el scroll activo
            stop_scroll(0);

            // Limpiar graficos y textos
            delete_text(all_text);
            delete_draw(all_drawing);
            clear_screen();

            limpiar_recursos_y_reiniciar();

            // Iniciar nueva partida
            iniciar_nueva_partida();
        END

        // Actualizar el scroll automaticamente
        actualizar_scroll();

        // Salir con ESC en cualquier momento
        IF (key(_ESC))
            // Mostrar menu de confirmacion de salida
            confirmar_salida();
            mostrar_textos_hud(); // Volver a mostrar textos del HUD despues de cerrar el menu
        END

        // Verificar si debemos volver al menu principal
        IF (volver_menu == 1)
            // Limpiar todos los procesos
            let_me_alone();

            // Detener el scroll activo
            stop_scroll(0);

            // Limpiar graficos y textos
            delete_text(all_text);
            delete_draw(all_drawing);
            clear_screen();

            // Descargar FPG del nivel
            limpiar_recursos_y_reiniciar();
            salir_juego = 0;

            // Reiniciar listas enlazadas
            primera_bala_jugador_activa = -1;
            primer_slot_libre_jugador = 0;
            primera_bala_enemigo_activa = -1;
            primer_slot_libre_enemigo = 0;
            primera_enemigo_activo = -1;

            // Iniciar nueva partida
            iniciar_nueva_partida();
        END
        IF (game_over == 1)
            FROM i=0 to FRAMES_ESPERA_EXPLOSION * FPS_JUEGO; // Esperar a que se vea la explosion del jugador
                FRAME;  // Frames para ver la explosion
                delete_draw(all_drawing);  // Limpiar todos los dibujos para el siguiente frame
            END
            // Nos aseguramos que este sea el unico proceso en ejecucion
            let_me_alone();

            // Actualizar y guardar puntuaciones
            actualizar_top_scores(puntos);
            guardar_top_scores();

            // Mostramos la pantalla de game over
            pantalla_game_over();

            // Reiniciamos las variables del juego (manteniendo el nivel actual)
            puntos = 0;
            game_over = 0;
            vidas_jugador = VIDAS_INICIALES;  // Reiniciar vidas a 3
            jugador_inmune = 0;  // Quitar inmunidad
            // Mantenemos: nivel (progreso), nivel_actual (nivel actual), num_enemigos_nivel
            enemigos_vivos = num_enemigos_nivel;

            // El FPG del nivel actual ya esta cargado, no necesitamos recargarlo

            // Iniciamos un nuevo nivel
            delete_draw(all_drawing);  // Limpiar todos los dibujos de la partida anterior
            inicio_nivel();
        END
        // Pasar al siguiente nivel si no quedan enemigos
        IF (enemigos_vivos <= 0)
            FROM i=0 to FRAMES_ESPERA_EXPLOSION * FPS_JUEGO; // Pequena pausa para ver las explosiones finales
                FRAME;  // Frames para ver la explosion
                delete_draw(all_drawing);  // Limpiar todos los dibujos para el siguiente frame
            END
            let_me_alone();
            cuenta_regresiva();
            nivel++;

            // Mostrar cinematicas segun el nivel completado
            IF (nivel == 2 && volver_menu == 0)  // Acabamos de completar nivel 1
                mostrar_cinematica_final(1);
            END
            IF (nivel == 3 && volver_menu == 0)  // Acabamos de completar nivel 2
                mostrar_cinematica_final(2);
            END
            IF (nivel == 4 && volver_menu == 0)  // Acabamos de completar nivel 3
                mostrar_cinematica_final(3);
            END
            IF (nivel == 7 && volver_menu == 0)  // Acabamos de completar nivel 6
                mostrar_cinematica_final(4);
            END
            IF (nivel == 8 && volver_menu == 0)  // Acabamos de completar nivel 7
                mostrar_cinematica_final(5);
            END
            IF (nivel == 9 && volver_menu == 0)  // Acabamos de completar nivel 8
                mostrar_cinematica_final(6);
            END
            IF (nivel == 10 && volver_menu == 0)  // Acabamos de completar nivel 9
                mostrar_cinematica_final(7);
            END
            IF (nivel == 12 && volver_menu == 0)  // Acabamos de completar nivel 11
                mostrar_cinematica_final(8);
            END
            IF (nivel == 13 && volver_menu == 0)  // Acabamos de completar nivel 12
                mostrar_cinematica_final(9);
            END
            IF (nivel == 14 && volver_menu == 0)  // Acabamos de completar nivel 13
                mostrar_cinematica_final(10);
                volver_menu = 1;  // Fin del juego, volver al menú principal
            END

            // Si el usuario eligió volver al menú desde la cinemática, dejar que el bloque principal lo maneje
            IF (volver_menu == 1)
                CONTINUE;  // El bloque de línea 450 hará toda la limpieza y reset
            END

            // Resetear flag de saltar cinematica
            saltar_cinematica = 0;

            // Avanzar al siguiente nivel (ciclico 0-9)
            nivel_actual++;
            IF (nivel_actual >= NUM_NIVELES)
                nivel_actual = 0;  // Volver al nivel 0 despues del 9
            END
            // Calcular enemigos del nuevo nivel y cargar su FPG
            num_enemigos_nivel = calcular_num_enemigos(nivel_actual);
            enemigos_vivos = num_enemigos_nivel;
            cargar_fpg_nivel(nivel_actual);

            // RESETEAR VIDAS AL PASAR DE NIVEL (nuevo nivel = nueva oportunidad)
            vidas_jugador = VIDAS_INICIALES;  // Reiniciar vidas a 3
            jugador_inmune = 0;  // Quitar cualquier inmunidad residual

            let_me_alone();
            inicio_nivel();
        END

        // Actualizar memoria usada solo si es el valor maximo (pico de consumo)
        IF (memoria_inicial - memory_free() > memoria_usada)
            memoria_usada = memoria_inicial - memory_free();
        END

        // Limpiar todos los dibujos al final del frame para el siguiente
        delete_draw(all_drawing);
        FRAME;
    END
END

//------------------------------------------------------------------------------
// FUNCION: mostrar_cinematica_final
// DESCRIPCION: Muestra una cinematica de final de nivel, reseteando flags y deteniendo scroll
// PARAMETROS:
//   - cinematic_id: ID de la cinematica a mostrar
//------------------------------------------------------------------------------
FUNCTION mostrar_cinematica_final(INT cinematic_id)
PRIVATE
    INT resultado = 0;
BEGIN
    stop_scroll(0);  // Detener scroll
    saltar_cinematica = 0;  // Resetear flag para mostrar cinemática
    resultado = cinematica(cinematic_id);
    RETURN(resultado);
END

//------------------------------------------------------------------------------
// FUNCION: mostrar_textos_hud
// Descripcion: Escribe en pantalla la puntuacion, nivel y los frames por segundo reales
// Los PROCESS se ejecutan en paralelo, mientras que las FUNCTION se ejecutan de forma secuencial
// - Es decir, hasta que no termine esta funcion, el proceso que lo llama queda bloqueado
FUNCTION mostrar_textos_hud();
BEGIN
    // Dibujar labels estaticos para los textos
    write(FNT_HUD, POS_X_ETIQUETAS, POS_Y_PUNTOS, ALINEACION_IZQUIERDA, "PUNTOS:");
    write(FNT_HUD, POS_X_ETIQUETAS, POS_Y_NIVEL, ALINEACION_IZQUIERDA, "NIVEL:");
    write(FNT_X, POS_X_ETIQUETAS+215, POS_Y_FPS-3, ALINEACION_IZQUIERDA, "x.com/Hamster_ruso");

    // Dibujar valores dinamicos usando write_int
    // Offset para pasar la direccion de la variable (puntero)
    // El valor se actualizara automaticamente al cambiar la variable
    write_int(FNT_HUD, POS_X_VALORES, POS_Y_PUNTOS, 0, OFFSET puntos);
    write_int(FNT_HUD, POS_X_VALORES, POS_Y_NIVEL, 0, OFFSET nivel);

    IF (_DEBUG_ == 1)
        // Mostrar FPS reales (solo en modo debug)
        write(0, POS_X_ETIQUETAS, POS_Y_FPS, ALINEACION_IZQUIERDA, "FPS:");
        write_int(0, POS_X_FPS, POS_Y_FPS, 0, OFFSET fps);

        // Mostrar RAM usada (en KB)
        write(0, POS_X_ETIQUETAS + 60, POS_Y_FPS, ALINEACION_IZQUIERDA, "RAM (KB):");
        write_int(0, POS_X_ETIQUETAS + 90, POS_Y_FPS, 0, OFFSET memoria_usada);
    END
END

//------------------------------------------------------------------------------
// FUNCION: calcular_num_enemigos
// DESCRIPCION: Calcula el numero de enemigos segun el nivel actual
//              Nivel 0 = 40, nivel 1 = 50, ..., nivel 9 = 130
//              Niveles 10+ = 130 (maximo permitido)
//------------------------------------------------------------------------------
FUNCTION calcular_num_enemigos(INT nivel_fpg);
PRIVATE
    INT num_calculado;
BEGIN
    num_calculado = NUM_ENEMIGOS_NIVEL_0 + (nivel_fpg * INCREMENTO_ENEMIGOS_POR_NIVEL);
    // Limitar al maximo permitido para no exceder el tamano del array
    IF (num_calculado > NUM_ENEMIGOS_MAXIMOS)
        RETURN (NUM_ENEMIGOS_MAXIMOS);
    END
    RETURN (num_calculado);
END

//------------------------------------------------------------------------------
// FUNCION: cargar_fpg_nivel
// DESCRIPCION: Carga el FPG correspondiente al nivel actual
//              Descarga el FPG anterior si existe y carga el nuevo
//------------------------------------------------------------------------------
FUNCTION cargar_fpg_nivel(INT nivel_fpg);
PRIVATE
    STRING ruta_fpg;  // Ruta del FPG a cargar
    STRING numero_str;  // Numero del nivel como string
BEGIN
    // Descargar el FPG anterior si existe
    IF (FPG_LEVEL != 0)
        unload_fpg(FPG_LEVEL);
    END

    // Construir la ruta del FPG segun el nivel
    // LEVEL000.FPG, LEVEL001.FPG, ..., LEVEL009.FPG, LEVEL010.FPG, LEVEL011.FPG, LEVEL012.FPG
    numero_str = itoa(nivel_fpg);

    // Agregar ceros a la izquierda segun sea necesario
    IF (nivel_fpg < 10)
        ruta_fpg = "TANYA/LEVEL00" + numero_str + ".FPG";
    ELSE
        ruta_fpg = "TANYA/LEVEL0" + numero_str + ".FPG";
    END

    // Cargar el nuevo FPG
    FPG_LEVEL = load_fpg(ruta_fpg);
END

// Funcion: inicializar_balas_jugador (OPTIMIZACION: Lista enlazada separada)
// Descripcion: Inicializa la lista enlazada de slots libres para balas del jugador
FUNCTION inicializar_balas_jugador();
PRIVATE
    INT i;  // Variable de bucle
BEGIN
    // Construir lista enlazada de slots libres
    FOR (i=0; i<MAX_BALAS_JUGADOR-1; i++)
        bala_jugador[i].activo = 0;
        bala_jugador[i].draw_id = 0;
        bala_jugador[i].siguiente = i + 1;  // Apuntar al siguiente slot
    END
    // Ultimo slot
    bala_jugador[MAX_BALAS_JUGADOR-1].activo = 0;
    bala_jugador[MAX_BALAS_JUGADOR-1].draw_id = 0;
    bala_jugador[MAX_BALAS_JUGADOR-1].siguiente = -1;  // Fin de lista

    // Inicializar cabeceras de listas
    primera_bala_jugador_activa = -1;  // Lista de activas vacia
    primer_slot_libre_jugador = 0;      // Lista de libres empieza en 0
END

// Funcion: inicializar_balas_enemigo (OPTIMIZACION: Lista enlazada separada)
// Descripcion: Inicializa la lista enlazada de slots libres para balas enemigas
FUNCTION inicializar_balas_enemigo();
PRIVATE
    INT i;  // Variable de bucle
BEGIN
    // Construir lista enlazada de slots libres
    FOR (i=0; i<MAX_BALAS_ENEMIGO-1; i++)
        bala_enemigo[i].activo = 0;
        bala_enemigo[i].draw_id = 0;
        bala_enemigo[i].siguiente = i + 1;  // Apuntar al siguiente slot
    END
    // Ultimo slot
    bala_enemigo[MAX_BALAS_ENEMIGO-1].activo = 0;
    bala_enemigo[MAX_BALAS_ENEMIGO-1].draw_id = 0;
    bala_enemigo[MAX_BALAS_ENEMIGO-1].siguiente = -1;  // Fin de lista

    // Inicializar cabeceras de listas
    primera_bala_enemigo_activa = -1;  // Lista de activas vacia
    primer_slot_libre_enemigo = 0;      // Lista de libres empieza en 0
END

// Funcion: crear_bala_jugador (OPTIMIZACION: Lista enlazada separada)
// Descripcion: Crea una nueva bala del jugador usando lista enlazada de slots libres
// Parametros:
//   - pos_x: Posicion X inicial de la bala
//   - pos_y: Posicion Y inicial de la bala
// Retorna: Indice de la bala creada, o -1 si no hay espacio
FUNCTION crear_bala_jugador(INT pos_x, INT pos_y);
PRIVATE
    INT slot;  // Indice del slot tomado
BEGIN
    // Verificar si hay slots libres
    IF (primer_slot_libre_jugador == -1)
        RETURN(-1);  // No hay espacio disponible
    END

    // Tomar el primer slot libre
    slot = primer_slot_libre_jugador;
    primer_slot_libre_jugador = bala_jugador[slot].siguiente;  // Avanzar la lista de libres

    // Inicializar la bala
    bala_jugador[slot].x = pos_x;
    bala_jugador[slot].y = pos_y;
    bala_jugador[slot].activo = 1;
    bala_jugador[slot].draw_id = 0;

    // OPTIMIZACION: Precalcular deltas de movimiento (siempre hacia arriba para jugador)
    bala_jugador[slot].dx = 0;
    bala_jugador[slot].dy = -VEL_BALA_JUGADOR;

    // OPTIMIZACION: Precalcular tamano y color (fijos para jugador)
    bala_jugador[slot].tamano = TAMANO_BALA_JUGADOR;
    bala_jugador[slot].color = 10;

    // Anadir a la lista de balas activas (al principio)
    bala_jugador[slot].siguiente = primera_bala_jugador_activa;
    primera_bala_jugador_activa = slot;

    RETURN(slot);  // Retornar el indice
END

// Funcion: crear_bala_enemigo (OPTIMIZACION: Lista enlazada separada)
// Descripcion: Crea una nueva bala enemiga usando lista enlazada de slots libres
// Parametros:
//   - pos_x: Posicion X inicial de la bala
//   - pos_y: Posicion Y inicial de la bala
//   - tipo_bala: Tipo de bala enemiga (1=enemigo1, 2=enemigo2)
//   - ang: Angulo de movimiento (solo para balas enemigo tipo 2)
// Retorna: Indice de la bala creada, o -1 si no hay espacio
FUNCTION crear_bala_enemigo(INT pos_x, INT pos_y, INT tipo_bala, INT ang);
PRIVATE
    INT slot;  // Indice del slot tomado
BEGIN
    // Verificar si hay slots libres
    IF (primer_slot_libre_enemigo == -1)
        RETURN(-1);  // No hay espacio disponible
    END

    // Tomar el primer slot libre
    slot = primer_slot_libre_enemigo;
    primer_slot_libre_enemigo = bala_enemigo[slot].siguiente;  // Avanzar la lista de libres

    // Inicializar la bala
    bala_enemigo[slot].x = pos_x;
    bala_enemigo[slot].y = pos_y;
    bala_enemigo[slot].tipo = tipo_bala;
    bala_enemigo[slot].activo = 1;
    bala_enemigo[slot].angulo = ang;
    bala_enemigo[slot].draw_id = 0;

    // OPTIMIZACION: Precalcular deltas de movimiento segun tipo
    IF (tipo_bala == TIPO_BALA_ENEMIGA1)
        bala_enemigo[slot].dx = 0;
        bala_enemigo[slot].dy = VEL_BALA_ENEMIGA1;
    ELSE  // TIPO_BALA_ENEMIGA2
        bala_enemigo[slot].dx = get_distx(ang, VEL_BALA_ENEMIGA2);
        bala_enemigo[slot].dy = get_disty(ang, VEL_BALA_ENEMIGA2);
    END

    // OPTIMIZACION: Precalcular tamano y color segun tipo
    IF (tipo_bala == TIPO_BALA_ENEMIGA1)
        bala_enemigo[slot].tamano = TAMANO_BALA_ENEMIGA1;
        bala_enemigo[slot].color = COLOR_ENEMIGO1;
    ELSE  // TIPO_BALA_ENEMIGA2
        bala_enemigo[slot].tamano = TAMANO_BALA_ENEMIGA2;
        bala_enemigo[slot].color = COLOR_ENEMIGO2;
    END

    // Anadir a la lista de balas activas (al principio)
    bala_enemigo[slot].siguiente = primera_bala_enemigo_activa;
    primera_bala_enemigo_activa = slot;

    RETURN(slot);  // Retornar el indice
END

// Proceso: proceso_balas_jugador (OPTIMIZACION: Proceso separado para balas del jugador)
// Descripcion: Proceso dedicado que gestiona solo balas del jugador usando lista enlazada
// - Solo procesa balas activas del jugador siguiendo la lista enlazada
// - Mueve, dibuja y verifica colisiones con enemigos
// - Elimina balas que salen de pantalla o colisionan
PROCESS proceso_balas_jugador();
PRIVATE
    INT actual;             // Indice de la bala actual en la lista
    INT anterior;           // Indice de la bala anterior en la lista
    INT siguiente;          // Indice de la bala siguiente (guardado antes de posible eliminacion)
    INT enemigo_index;      // Indice del enemigo colisionado
    INT color_explosion;    // Color de explosion
    INT debe_eliminar;      // Flag para marcar si debe eliminarse
BEGIN
    LOOP
        // Si el juego termino, salimos
        IF (game_over == 1) RETURN; END

        // PROCESAR BALAS DEL JUGADOR
        anterior = -1;
        actual = primera_bala_jugador_activa;

        WHILE (actual != -1)
            // Guardar el siguiente antes de posibles modificaciones
            siguiente = bala_jugador[actual].siguiente;
            debe_eliminar = 0;

            // Solo mover si el juego no está pausado
            IF (juego_pausado == 0)
                // Mover la bala segun deltas precalculados
                bala_jugador[actual].x += bala_jugador[actual].dx;
                bala_jugador[actual].y += bala_jugador[actual].dy;
            END

            // Solo verificar colisiones si el juego no está pausado
            IF (juego_pausado == 0 AND (bala_jugador[actual].y < scroll.y0 - MARGEN_VISIBLE_ARRIBA OR
                bala_jugador[actual].y > scroll.y0 + ALTO_PANTALLA + MARGEN_VISIBLE_ABAJO OR
                bala_jugador[actual].x < 0 OR
                bala_jugador[actual].x > ANCHO_PANTALLA))
                debe_eliminar = 1;
            ELSE
                // Colision con enemigos
                enemigo_index = comprobar_colision_bala_enemigos(bala_jugador[actual].x, bala_jugador[actual].y);
                IF (enemigo_index != -1)
                    puntos += PUNTOS_POR_ENEMIGO;
                    IF (enemigo[enemigo_index].tipo == 1)
                        color_explosion = COLOR_ENEMIGO1;
                    ELSE
                        IF (enemigo[enemigo_index].tipo == 2)
                            color_explosion = COLOR_ENEMIGO2;
                        ELSE
                            color_explosion = COLOR_ENEMIGO3;
                        END
                    END
                    explosion(enemigo[enemigo_index].x, enemigo[enemigo_index].y, color_explosion);
                    enemigo[enemigo_index].activo = 0;
                    remover_enemigo_lista(enemigo_index);
                    enemigos_vivos--;
                    debe_eliminar = 1;
                END
            END

            // Eliminar bala de la lista si es necesario
            IF (debe_eliminar == 1)
                // Sacar de lista de activas
                IF (anterior == -1)
                    primera_bala_jugador_activa = siguiente;
                ELSE
                    bala_jugador[anterior].siguiente = siguiente;
                END

                // Marcar como inactiva
                bala_jugador[actual].activo = 0;

                // Devolver a lista de libres
                bala_jugador[actual].siguiente = primer_slot_libre_jugador;
                primer_slot_libre_jugador = actual;
            ELSE
                // Dibujar la bala solo si el juego no está pausado (convertir coordenadas de mapa a pantalla)
                IF (juego_pausado == 0)
                    bala_jugador[actual].draw_id = draw(TIPO_DIBUJO_CIRCULO_RELLENO, bala_jugador[actual].color, OPACIDAD_DRAW, REGION_DRAW,
                        (bala_jugador[actual].x - scroll.x0) - bala_jugador[actual].tamano,
                        (bala_jugador[actual].y - scroll.y0) - bala_jugador[actual].tamano,
                        (bala_jugador[actual].x - scroll.x0) + bala_jugador[actual].tamano,
                        (bala_jugador[actual].y - scroll.y0) + bala_jugador[actual].tamano);
                END

                // Avanzar anterior solo si no eliminamos
                anterior = actual;
            END

            // Avanzar al siguiente
            actual = siguiente;
        END

        FRAME;  // Esperar al siguiente frame
    END
END

// Proceso: proceso_balas_enemigo (OPTIMIZACION: Proceso separado para balas enemigas)
// Descripcion: Proceso dedicado que gestiona solo balas enemigas usando lista enlazada
// - Solo procesa balas activas enemigas siguiendo la lista enlazada
// - Mueve, dibuja y verifica colisiones con el jugador
// - Elimina balas que salen de pantalla o colisionan
PROCESS proceso_balas_enemigo();
PRIVATE
    INT actual;             // Indice de la bala actual en la lista
    INT anterior;           // Indice de la bala anterior en la lista
    INT siguiente;          // Indice de la bala siguiente (guardado antes de posible eliminacion)
    INT id_player;          // ID del jugador
    INT debe_eliminar;      // Flag para marcar si debe eliminarse
    INT dx, dy;             // Diferencias para calculo de distancia
    INT dist_cuadrado;      // Distancia al cuadrado (optimizacion)
BEGIN
    id_player = get_id(type jugador);
    LOOP
        // Si el juego termino, salimos
        IF (game_over == 1) RETURN; END

        // PROCESAR BALAS ENEMIGAS
        anterior = -1;
        actual = primera_bala_enemigo_activa;

        WHILE (actual != -1)
            // Guardar el siguiente antes de posibles modificaciones
            siguiente = bala_enemigo[actual].siguiente;
            debe_eliminar = 0;

            // Solo mover si el juego no está pausado
            IF (juego_pausado == 0)
                // Mover la bala segun deltas precalculados
                bala_enemigo[actual].x += bala_enemigo[actual].dx;
                bala_enemigo[actual].y += bala_enemigo[actual].dy;
            END

            // Solo verificar colisiones si el juego no está pausado
            IF (juego_pausado == 0 AND (bala_enemigo[actual].y < scroll.y0 - MARGEN_VISIBLE_ARRIBA OR
                bala_enemigo[actual].y > scroll.y0 + ALTO_PANTALLA + MARGEN_VISIBLE_ABAJO OR
                bala_enemigo[actual].x < 0 OR
                bala_enemigo[actual].x > ANCHO_PANTALLA))
                debe_eliminar = 1;
            ELSE
                // Colision con jugador (solo si no esta inmune y el juego no está pausado)
                IF (juego_pausado == 0 AND id_player != 0 AND jugador_inmune == 0)
                    // Bounding box rapida
                    IF (abs(bala_enemigo[actual].x - id_player.x) < MARGEN_BOUNDING_BOX AND abs(bala_enemigo[actual].y - id_player.y) < MARGEN_BOUNDING_BOX)
                        // Calcular distancia al cuadrado
                        dx = bala_enemigo[actual].x - id_player.x;
                        dy = bala_enemigo[actual].y - id_player.y;
                        dist_cuadrado = dx * dx + dy * dy;
                        IF (dist_cuadrado < DISTANCIA_COLISION_CUADRADO)
                            // El jugador recibe un impacto
                            vidas_jugador--;
                            explosion(id_player.x, id_player.y, COLOR_NAVE);

                            // Verificar si el jugador murio
                            IF (vidas_jugador <= 0)
                                // Tercera bala = muerte
                                game_over = 1;
                            ELSE
                                // Activar inmunidad temporal y parpadeo
                                jugador_inmune = TIEMPO_INMUNIDAD;

                                // Cambiar FPG segun vidas restantes
                                IF (vidas_jugador == 2)
                                    // Primera bala: cambiar a PLAYERME.FPG
                                    id_player.file = FPG_PLAYERME;
                                ELSE
                                    // Segunda bala: cambiar a PLAYERLO.FPG
                                    id_player.file = FPG_PLAYERLO;
                                END
                            END

                            debe_eliminar = 1;
                        END
                    END
                END
            END

            // Eliminar bala de la lista si es necesario
            IF (debe_eliminar == 1)
                // Sacar de lista de activas
                IF (anterior == -1)
                    primera_bala_enemigo_activa = siguiente;
                ELSE
                    bala_enemigo[anterior].siguiente = siguiente;
                END

                // Marcar como inactiva
                bala_enemigo[actual].activo = 0;

                // Devolver a lista de libres
                bala_enemigo[actual].siguiente = primer_slot_libre_enemigo;
                primer_slot_libre_enemigo = actual;
            ELSE
                // Dibujar la bala solo si el juego no está pausado (convertir coordenadas de mapa a pantalla)
                IF (juego_pausado == 0)
                    bala_enemigo[actual].draw_id = draw(TIPO_DIBUJO_CIRCULO_RELLENO, bala_enemigo[actual].color, OPACIDAD_DRAW, REGION_DRAW,
                        (bala_enemigo[actual].x - scroll.x0) - bala_enemigo[actual].tamano,
                        (bala_enemigo[actual].y - scroll.y0) - bala_enemigo[actual].tamano,
                        (bala_enemigo[actual].x - scroll.x0) + bala_enemigo[actual].tamano,
                        (bala_enemigo[actual].y - scroll.y0) + bala_enemigo[actual].tamano);
                END

                // Avanzar anterior solo si no eliminamos
                anterior = actual;
            END

            // Avanzar al siguiente
            actual = siguiente;
        END

        FRAME;  // Esperar al siguiente frame
    END
END

//------------------------------------------------------------------------------
// FUNCION: actualizar_scroll
// DESCRIPCION: Actualiza la posicion del scroll de forma automatica hacia arriba.
//              El scroll se mueve desde la parte inferior del mapa (y=1536) hacia
//              arriba (y=0) a velocidad de 1 pixel cada 3 frames.
//------------------------------------------------------------------------------
FUNCTION actualizar_scroll()
BEGIN
    // Mover el scroll hacia arriba automaticamente (1 pixel cada 3 frames)
    IF (scroll_y_objetivo > 0)
        contador_scroll++;
        IF (contador_scroll >= 3)
            scroll_y_objetivo = scroll_y_objetivo - VELOCIDAD_SCROLL;
            IF (scroll_y_objetivo < 0)
                scroll_y_objetivo = 0;
            END
            contador_scroll = 0;
        END
    END

    // Actualizar la posicion del scroll
    scroll.y0 = scroll_y_objetivo;
END

//------------------------------------------------------------------------------
// FUNCION: crear_enemigos (MODIFICADA PARA SCROLL Y NIVELES)
// DESCRIPCION: Inicializa el STRUCT de enemigos al inicio de cada nivel.
//              Distribuye num_enemigos_nivel enemigos por todo el mapa de 1536 pixeles de forma escalonada.
//              Distribucion proporcional: pocos enemigos al principio, mas conforme nos acercamos al final.
//------------------------------------------------------------------------------
PROCESS crear_enemigos();
PRIVATE
    i;  // Variable para el bucle
    j;  // Variable para inicializar draws
    tipo_enemigo;  // Tipo aleatorio de enemigo
    zona_y_min;  // Y minima de la zona de spawneo
    zona_y_max;  // Y maxima de la zona de spawneo
    enemigos_zona_alta;  // Numero de enemigos en zona alta (calculado)
    enemigos_zona_media_alta;  // Numero de enemigos en zona media-alta (calculado)
    enemigos_zona_media;  // Numero de enemigos en zona media (calculado)
    enemigos_zona_baja;  // Numero de enemigos en zona baja (calculado)
BEGIN
    // Calcular distribucion de enemigos segun el numero total del nivel
    // Usamos proporciones fijas: 38%, 31%, 19%, 12%
    enemigos_zona_alta = num_enemigos_nivel * PROPORCION_ZONA_ALTA / 100;
    enemigos_zona_media_alta = num_enemigos_nivel * PROPORCION_ZONA_MEDIA_ALTA / 100;
    enemigos_zona_media = num_enemigos_nivel * PROPORCION_ZONA_MEDIA / 100;
    enemigos_zona_baja = num_enemigos_nivel * PROPORCION_ZONA_BAJA / 100;

    rand_seed(memory_free() + FPS);  // Semilla aleatoria basada en el nivel actual
    // Crear enemigos repartidos por todo el mapa de forma escalonada
    // Dividimos el mapa en zonas y aumentamos la densidad de enemigos conforme bajamos
    FOR (i=0; i<num_enemigos_nivel; i++)
        // Posicion X aleatoria dentro de los margenes de la pantalla
        enemigo[i].x = MARGEN_LATERAL + rand(0, ANCHO_PANTALLA - (MARGEN_LATERAL * 2));

        // Distribucion escalonada por Y:
        // - Zona alta (0-Y_LIMITE_ZONA_ALTA): enemigos_zona_alta enemigos
        // - Zona media-alta (Y_LIMITE_ZONA_ALTA-Y_LIMITE_ZONA_MEDIA_ALTA): enemigos_zona_media_alta enemigos
        // - Zona media (Y_LIMITE_ZONA_MEDIA_ALTA-Y_LIMITE_ZONA_MEDIA): enemigos_zona_media enemigos
        // - Zona baja (Y_LIMITE_ZONA_MEDIA-ALTO_MAPA-MARGEN): enemigos_zona_baja enemigos

        IF (i < enemigos_zona_alta)  // Primeros enemigos_zona_alta enemigos en zona alta (mas dificil cuando scroll sube)
            zona_y_min = MARGEN_SUPERIOR;
            zona_y_max = Y_LIMITE_ZONA_ALTA;
        ELSE
            IF (i < enemigos_zona_alta + enemigos_zona_media_alta)  // Siguientes enemigos_zona_media_alta enemigos en zona media-alta
                zona_y_min = Y_LIMITE_ZONA_ALTA;
                zona_y_max = Y_LIMITE_ZONA_MEDIA_ALTA;
            ELSE
                IF (i < enemigos_zona_alta + enemigos_zona_media_alta + enemigos_zona_media)  // Siguientes enemigos_zona_media enemigos en zona media
                    zona_y_min = Y_LIMITE_ZONA_MEDIA_ALTA;
                    zona_y_max = Y_LIMITE_ZONA_MEDIA;
                ELSE  // Ultimos enemigos_zona_baja enemigos en zona baja (cerca del inicio)
                    zona_y_min = Y_LIMITE_ZONA_MEDIA;
                    zona_y_max = ALTO_MAPA - MARGEN_CORTESIA_INICIAL;
                END
            END
        END

        enemigo[i].y = rand(zona_y_min, zona_y_max);

        // Tipo aleatorio de enemigo (1, 2 o 3) con tipo 3 al 20% en todos los niveles
        // Excepcion: en nivel 3 (nivel_actual=2, LEVEL002.FPG) solo enemigos tipo 2 y tipo 3
        IF (nivel_actual == 2)
            IF (rand(1, 100) <= 20)
                tipo_enemigo = 3;  // 20% tipo 3
            ELSE
                tipo_enemigo = 2;  // 80% tipo 2
            END
        ELSE
            // Excepcion: en nivel 7 (nivel_actual=6, LEVEL006.FPG) solo enemigos tipo 1 y tipo 3
            IF (nivel_actual == 6)
                IF (rand(1, 100) <= 20)
                    tipo_enemigo = 3;  // 20% tipo 3
                ELSE
                    tipo_enemigo = 1;  // 80% tipo 1
                END
            ELSE
                // Resto de niveles: tipo 1, 2 o 3 con tipo 3 al 20%
                IF (rand(1, 100) <= 20)
                    tipo_enemigo = 3;  // 20% tipo 3
                ELSE
                    tipo_enemigo = rand(1, 2);  // 40% tipo 1, 40% tipo 2
                END
            END
        END
        enemigo[i].tipo = tipo_enemigo;

        // Para tipo 3, asignar grafico aleatorio (1 o 2)
        IF (tipo_enemigo == 3)
            enemigo[i].grafico_tipo3 = rand(GRAFICO_ENEMIGO1, GRAFICO_ENEMIGO2);
        END

        // Marcar como activo
        enemigo[i].activo = 1;

        // Direccion inicial
        IF (tipo_enemigo == 1)
            // Direccion aleatoria: -1 (izquierda) o 1 (derecha), nunca 0
            IF (rand(0, 1) == 0)
                enemigo[i].dir = -1;  // Izquierda
            ELSE
                enemigo[i].dir = 1;   // Derecha
            END
        ELSE
            enemigo[i].dir = 0;  // Tipo 2: direccion 0
        END

        // Angulo inicial
        enemigo[i].ang = 0;

        // No necesitamos inicializar array de dibujos (ya no se usa)
    END

    // OPTIMIZACION: Construir lista enlazada de enemigos activos
    primera_enemigo_activo = 0;
    FOR (i=0; i<num_enemigos_nivel-1; i++)
        enemigo[i].siguiente = i + 1;
    END
    enemigo[num_enemigos_nivel-1].siguiente = -1; // Fin de lista

    // Crear el proceso unico de enemigos
    proceso_enemigos();
END

//------------------------------------------------------------------------------
// PROCESS: jugador (MODIFICADO PARA SCROLL)
// DESCRIPCION: Controla la nave del jugador.
//              - Maneja el dibujo, movimientos, disparos y colisiones en un bucle continuo.
//              - Se detiene si el juego termina (game_over).
//              - Ahora usa ctype=c_scroll para moverse dentro del sistema de scroll.
//------------------------------------------------------------------------------
PROCESS jugador();
PRIVATE
    vel = VEL_JUGADOR;  // Velocidad de movimiento de la nave
    tiempo_disparo = 0; // Contador para controlar la frecuencia de disparos
    disparando = 0;        // Estado de disparo (0 = no dispara, 1 = disparando)
    dir_x = 0;             // Direccion de movimiento (-1, 0, 1)
    dir_y = 0;             // Direccion de movimiento (-1, 0, 1)
    grafico_actual = 1;    // Grafico actual a mostrar
BEGIN
    // Configurar el proceso como scrollable
    ctype = c_scroll;

    // Posicion inicial de la nave en el centro inferior del MAPA (coordenadas de scroll)
    x = CENTRO_X;  // Posicion inicial x en el centro
    y = ALTO_MAPA - 20;  // Posicion inicial y cerca del fondo del mapa
    file = FPG_PLAYER;
    graph = 1;
    z = -10;  // Asegurar que el jugador este sobre el fondo

    // Bucle principal del jugador
    LOOP
        // Si el jugador ha muerto, paramos el proceso
        IF (game_over == 1)
            // La sentencia RETURN finaliza el proceso actual de forma inmediata
            RETURN;
        END

        // Gestionar inmunidad temporal y parpadeo
        IF (jugador_inmune > 0)
            jugador_inmune--;
            // Parpadeo: alternar visibilidad cada FRECUENCIA_PARPADEO frames
            IF ((jugador_inmune / FRECUENCIA_PARPADEO) MOD 2 == 0)
                flags = 0;  // Visible
            ELSE
                flags = 4;  // Invisible (flag oculto)
            END

            // Al terminar la inmunidad, asegurar que sea visible
            IF (jugador_inmune == 0)
                flags = 0;
            END
        END

        // Verificamos si los controles estan activos (para evitar mover durante la cuenta regresiva)
        IF (controles_activos == 1 AND juego_pausado == 0)
            // Mover la nave segun las teclas
            manejar_controles_jugador(&x, &y, &dir_x, &dir_y, vel);
            // Disparar si pulsamos la tecla de disparo
            manejar_disparo_jugador(&tiempo_disparo, x, y, &disparando);
            // Seleccionar grafico segun direccion y estado de disparo
            grafico_actual = calcular_grafico_jugador(dir_x, dir_y, disparando);
            graph = grafico_actual;
            // Comprobar colisiones con enemigos (solo si no esta inmune)
            IF (jugador_inmune == 0)
                comprobar_colision_jugador_enemigos(x, y);
            END
        END

        FRAME;  // Esperar al siguiente frame
    END
END

//------------------------------------------------------------------------------
// FUNCION: manejar_controles_jugador (MODIFICADA PARA SCROLL)
// DESCRIPCION: Maneja el movimiento de la nave del jugador segun las teclas de flecha.
//              Ahora usa coordenadas de scroll (mapa) en lugar de coordenadas de pantalla.
//------------------------------------------------------------------------------
FUNCTION manejar_controles_jugador(INT x_offset, INT y_offset, INT dir_x_offset, INT dir_y_offset, INT vel);
BEGIN
    // Resetear direccion
    *dir_x_offset = 0;
    *dir_y_offset = 0;

    // Mover a la izquierda si se presiona la flecha izquierda
    // Controlamos que no podamos salirnos de la pantalla con > TAMANO_NAVE_X (margen izquierdo basado en el tamano de la nave)
    IF (key(_left) AND *x_offset > TAMANO_NAVE_X)
        *x_offset -= vel;
        *dir_x_offset = -1;
    END

     // Mover a la derecha si se presiona la flecha derecha y no se sale de la pantalla
   IF (key(_right) AND *x_offset < ANCHO_PANTALLA - TAMANO_NAVE_X)
        *x_offset += vel;
        *dir_x_offset = 1;
    END

    // Mover arriba si se presiona la flecha arriba y no se sale del mapa
    IF (key(_up) AND *y_offset > TAMANO_NAVE_Y_ALTURA)
        *y_offset -= vel;
        *dir_y_offset = -1;
    END

    // Mover abajo si se presiona la flecha abajo y no pasa el limite inferior visible
    // El jugador no puede bajar mas alla de scroll.y0 + ALTO_PANTALLA - MARGEN_INFERIOR_JUGADOR
    IF (key(_down) AND *y_offset < scroll.y0 + ALTO_PANTALLA - MARGEN_INFERIOR_JUGADOR)
        *y_offset += vel;
        *dir_y_offset = 1;
    END

    // Auto-desplazamiento: el jugador sube automaticamente con el scroll (1 pixel cada 3 frames)
    // Solo si no esta presionando abajo (para permitir quedarse quieto respecto al scroll)
    // Y solo si el scroll no ha llegado al tope (scroll.y0 > 0) y si quedan enemigos vivos
    IF (NOT key(_down) AND scroll.y0 > 0 AND enemigos_vivos > 0)
        IF (contador_scroll == 0)  // Sincronizar con el movimiento del scroll
            *y_offset -= VELOCIDAD_SCROLL;
        END
    END

    // Verificar que no se salga del limite inferior visible
    IF (*y_offset > scroll.y0 + ALTO_PANTALLA - MARGEN_INFERIOR_JUGADOR)
        *y_offset = scroll.y0 + ALTO_PANTALLA - MARGEN_INFERIOR_JUGADOR;
    END

    // Control de debug: presionar P para acabar el nivel (para pruebas)
    IF (_DEBUG_ == 1 && key(_p))
        enemigos_vivos = 0;
    END
END

// Funcion: manejar_disparo_jugador (MODIFICADA)
// Descripcion: Controla el disparo de balas por parte del jugador.
// - Incrementa un contador de tiempo y dispara si se presiona espacio y ha pasado suficiente tiempo.
// - Ahora usa el sistema de balas optimizado con crear_bala()
// Parametros:
//   - tiempo_disparo_offset: Puntero al contador de tiempo entre disparos. -> Usamos el puntero para modificar la variable original.
//   - x: Posicion x de la nave (por valor, ya que no se modifica).
//   - y: Posicion y de la nave (por valor, ya que no se modifica).
//   - disparando_offset: Puntero al estado de disparo. -> Usamos el puntero para modificar la variable original.
// Los punteros sirven para modificar las variables originales fuera de la funcion.
// - Si modificas una varariable del puntero dentro de la funcion, se refleja fuera tambien.
// - Sirve para evitar el uso de variables globales innecesarias.
// Los PROCESS se ejecutan en paralelo, mientras que las FUNCTION se ejecutan de forma secuencial
// - Es decir, hasta que no termine esta funcion, el proceso que lo llama queda bloqueado
FUNCTION manejar_disparo_jugador(INT tiempo_disparo_offset, INT x, INT y, INT disparando_offset);
BEGIN
    // Incrementar el contador de tiempo
    // Esto controla la frecuencia de disparo
    // Permite tener un espacio minimo entre disparos
    // *tiempo_disparo_offset es un puntero, por eso usamos el operador *
    // Lo ponemos entre parentesis para que la suma se haga sobre el valor apuntado
    (*tiempo_disparo_offset)++;

    // Mostrar sprite de disparo mientras se mantenga pulsado el boton
    IF (key(_space))
        *disparando_offset = 1;
        IF (*tiempo_disparo_offset > TIEMPO_DISPARO_JUGADOR)
            explosion_pequena(x, y - OFFSET_DISPARO_Y, COLOR_EXPLOSION_PEQUENA);  // Explosion pequena al disparar
            crear_bala_jugador(x, y - OFFSET_DISPARO_Y);  // Crear bala en el array
            sound(WAV_DISPARO, VOL_MAX, FREQ_AGUDA);  // Reproducir sonido de disparo (frecuencia mayor)
            *tiempo_disparo_offset = 0;
        END
    ELSE
        *disparando_offset = 0;
    END
END

// Funcion: comprobar_colision_jugador_enemigos (OPTIMIZADA)
// Descripcion: Verifica si la nave del jugador colisiona con algun enemigo.
// - Si hay colision, suma puntos, crea explosiones y termina el juego.
// Parametros:
//   - x: Posicion x de la nave (por valor, ya que no se modifica).
//   - y: Posicion y de la nave (por valor, ya que no se modifica).
// OPTIMIZACION: Usa distancia al cuadrado para evitar raiz cuadrada y lista enlazada
// Los PROCESS se ejecutan en paralelo, mientras que las FUNCTION se ejecutan de forma secuencial
// - Es decir, hasta que no termine esta funcion, el proceso que lo llama queda bloqueado
FUNCTION comprobar_colision_jugador_enemigos(INT x, INT y);
PRIVATE
    INT actual;  // Indice actual en la lista
    INT dx, dy;  // Diferencias para calculo de distancia
    INT dist_cuadrado;  // Distancia al cuadrado
    INT id_player;  // ID del jugador
BEGIN
    // OPTIMIZACION: Recorrer solo enemigos activos siguiendo la lista enlazada
    actual = primera_enemigo_activo;
    WHILE (actual != -1)
        // OPTIMIZACION: Calcular distancia al cuadrado (evita raiz cuadrada)
        dx = x - enemigo[actual].x;
        dy = y - enemigo[actual].y;
        dist_cuadrado = dx * dx + dy * dy;
        IF (dist_cuadrado < DISTANCIA_COLISION_JUGADOR_CUADRADO)
            // El jugador choca con un enemigo
            puntos += PUNTOS_POR_ENEMIGO;  // Sumamos los puntos
            IF (enemigo[actual].tipo == 1)
                explosion(enemigo[actual].x, enemigo[actual].y, COLOR_ENEMIGO1);  // Explosion del enemigo
            ELSE
                IF (enemigo[actual].tipo == 2)
                    explosion(enemigo[actual].x, enemigo[actual].y, COLOR_ENEMIGO2);  // Explosion del enemigo
                ELSE
                    explosion(enemigo[actual].x, enemigo[actual].y, COLOR_ENEMIGO3);  // Explosion del enemigo
                END
            END
            enemigo[actual].activo = 0;  // Marcar enemigo como muerto
            remover_enemigo_lista(actual);
            enemigos_vivos--;  // Reducir contador

            // El jugador recibe dano
            vidas_jugador--;
            explosion(x, y, COLOR_NAVE);  // Explosion del jugador

            // Verificar si el jugador murio
            IF (vidas_jugador <= 0)
                // Tercera colision = muerte
                game_over = 1;
            ELSE
                // Activar inmunidad temporal y parpadeo
                jugador_inmune = TIEMPO_INMUNIDAD;

                // Obtener ID del jugador para cambiar su FPG
                id_player = get_id(type jugador);
                IF (id_player != 0)
                    // Cambiar FPG segun vidas restantes
                    IF (vidas_jugador == 2)
                        // Primera colision: cambiar a PLAYERME.FPG
                        id_player.file = FPG_PLAYERME;
                    ELSE
                        // Segunda colision: cambiar a PLAYERLO.FPG
                        id_player.file = FPG_PLAYERLO;
                    END
                END
            END

            RETURN;
        END
        actual = enemigo[actual].siguiente;
    END
END

// Funcion: calcular_grafico_jugador
// Descripcion: Calcula el ID del grafico segun direccion y estado de disparo
// Retorna: ID del grafico (1-18)
FUNCTION calcular_grafico_jugador(INT dir_x, INT dir_y, INT disparando);
PRIVATE
    INT base_grafico = 0;
    INT offset_direccion = 0;
BEGIN
    // Base: 0 si no dispara, 9 si dispara
    IF (disparando == 1)
        base_grafico = 9;
    ELSE
        base_grafico = 0;
    END

    // Calcular offset segun direccion
    // Quieto
    IF (dir_x == 0 AND dir_y == 0)
        offset_direccion = 1;
    END
    // Arriba
    IF (dir_x == 0 AND dir_y == -1)
        offset_direccion = 2;
    END
    // Arriba derecha
    IF (dir_x == 1 AND dir_y == -1)
        offset_direccion = 3;
    END
    // Derecha
    IF (dir_x == 1 AND dir_y == 0)
        offset_direccion = 4;
    END
    // Derecha abajo
    IF (dir_x == 1 AND dir_y == 1)
        offset_direccion = 5;
    END
    // Abajo
    IF (dir_x == 0 AND dir_y == 1)
        offset_direccion = 6;
    END
    // Abajo izquierda
    IF (dir_x == -1 AND dir_y == 1)
        offset_direccion = 7;
    END
    // Izquierda
    IF (dir_x == -1 AND dir_y == 0)
        offset_direccion = 8;
    END
    // Arriba izquierda
    IF (dir_x == -1 AND dir_y == -1)
        offset_direccion = 9;
    END

    RETURN(base_grafico + offset_direccion);
END

// Funcion: comprobar_colision_bala_enemigos (OPTIMIZADA)
// Descripcion: Verifica si la bala del jugador colisiona con algun enemigo. Si hay colision, retorna el index del enemigo.
// Parametros:
//   - x: Posicion x de la bala.
//   - y: Posicion y de la bala.
// Retorna: Index del enemigo colisionado (0-9), o -1 si no hay colision.
// OPTIMIZACION: Usa distancia al cuadrado para evitar raiz cuadrada y lista enlazada para solo activos
// Los PROCESS se ejecutan en paralelo, mientras que las FUNCTION se ejecutan de forma secuencial
// - Es decir, hasta que no termine esta funcion, el proceso que lo llama queda bloqueado
FUNCTION comprobar_colision_bala_enemigos(INT x, INT y);
PRIVATE
    INT actual;  // Indice actual en la lista
    INT dx, dy;  // Diferencias para calculo de distancia
    INT dist_cuadrado;  // Distancia al cuadrado
BEGIN
    // OPTIMIZACION: Recorrer solo enemigos activos siguiendo la lista enlazada
    actual = primera_enemigo_activo;
    WHILE (actual != -1)
        // OPTIMIZACION: Calcular distancia al cuadrado (evita raiz cuadrada)
        dx = x - enemigo[actual].x;
        dy = y - enemigo[actual].y;
        dist_cuadrado = dx * dx + dy * dy;
        IF (dist_cuadrado < DISTANCIA_COLISION_CUADRADO)
            RETURN(actual);  // Retornamos el index del enemigo colisionado
        END
        actual = enemigo[actual].siguiente;
    END
    RETURN(-1);  // No hay colision
END

// Funcion: remover_enemigo_lista (OPTIMIZACION)
// Descripcion: Remueve un enemigo de la lista enlazada de activos
// Parametros:
//   - index: Indice del enemigo a remover
// OPTIMIZACION: Mantiene la lista enlazada actualizada para colisiones eficientes
FUNCTION remover_enemigo_lista(INT index);
PRIVATE
    INT actual;  // Indice actual en la lista
    INT anterior; // Indice anterior en la lista
BEGIN
    anterior = -1;
    actual = primera_enemigo_activo;

    WHILE (actual != -1)
        IF (actual == index)
            // Encontrado, remover
            IF (anterior == -1)
                // Es el primero
                primera_enemigo_activo = enemigo[actual].siguiente;
            ELSE
                // Esta en medio o al final
                enemigo[anterior].siguiente = enemigo[actual].siguiente;
            END
            RETURN;
        END
        anterior = actual;
        actual = enemigo[actual].siguiente;
    END
END

//------------------------------------------------------------------------------
// PROCESS: proceso_enemigos (MODIFICADO PARA SCROLL)
// DESCRIPCION: Controla el comportamiento de todos los enemigos usando un STRUCT array.
//              Maneja movimiento, disparos y eliminacion de enemigos tipo 1 y 2.
//              Ahora solo procesa y dibuja enemigos visibles en la pantalla actual del scroll.
//              Usa procesos hijos con ctype=c_screen para visualizar cada enemigo.
//------------------------------------------------------------------------------
PROCESS proceso_enemigos();
PRIVATE
    INT i, j;
    INT tiempo_disparo[NUM_ENEMIGOS_MAXIMOS];  // Contador de tiempo para disparos de cada enemigo
    INT enemigo_visible;     // Flag para verificar si el enemigo esta visible
    INT procesos_enemigo[NUM_ENEMIGOS_MAXIMOS]; // IDs de procesos hijos para cada enemigo
BEGIN
    // Inicializar array de procesos
    FOR (i=0; i<num_enemigos_nivel; i++)
        procesos_enemigo[i] = 0;
    END

    LOOP
        // Si el juego ha terminado, salimos del proceso
        IF (game_over == 1)
            // Terminar todos los procesos hijos
            FOR (i=0; i<num_enemigos_nivel; i++)
                IF (procesos_enemigo[i] != 0)
                    signal(procesos_enemigo[i], s_kill);
                    procesos_enemigo[i] = 0;
                END
            END
            RETURN;
        END

        // Por cada enemigo
        FOR (i=0; i<num_enemigos_nivel; i++)
            // Verificamos si esta vivo
            IF (enemigo[i].activo == 1)
                // OPTIMIZACION: Solo procesar enemigos visibles en el scroll actual
                // Un enemigo es visible si su Y esta entre scroll.y0 - MARGEN y scroll.y0 + ALTO_PANTALLA + MARGEN
                enemigo_visible = 0;
                IF (enemigo[i].y >= scroll.y0 - MARGEN_VISIBLE_ARRIBA AND enemigo[i].y <= scroll.y0 + ALTO_PANTALLA + MARGEN_VISIBLE_ABAJO)
                    enemigo_visible = 1;
                END

                // Solo procesar si esta visible
                IF (enemigo_visible == 1)
                    // Crear proceso hijo si no existe
                    IF (procesos_enemigo[i] == 0)
                        procesos_enemigo[i] = proceso_enemigo_visual(i);
                    END

                    // Solo mover y disparar si los controles estan activos y el juego no está pausado
                    IF (controles_activos == 1 AND juego_pausado == 0)
                        // Movemos en funcion del tipo
                        IF (enemigo[i].tipo == 1)
                            // Movemos el enemigo tipo 1
                            mover_enemigo_tipo1(&enemigo[i].x, &enemigo[i].y, &enemigo[i].dir);
                        ELSE
                            IF (enemigo[i].tipo == 2)
                                // Movemos el enemigo tipo 2
                                mover_enemigo_tipo2(&enemigo[i].x, &enemigo[i].y, &enemigo[i].ang);
                            ELSE
                                // Movemos el enemigo tipo 3
                                mover_enemigo_tipo3(&enemigo[i].x, &enemigo[i].y);
                            END
                        END

                        // Verificar si sale del area visible por abajo
                        IF (enemigo[i].y > scroll.y0 + ALTO_PANTALLA + MARGEN_VISIBLE_ABAJO)
                            enemigo[i].activo = 0;
                            remover_enemigo_lista(i);
                            enemigos_vivos--;
                        END

                        // Disparar en funcion del tipo (tipo 3 no dispara)
                        IF (enemigo[i].tipo == 1)
                            disparar_enemigo_tipo1(&tiempo_disparo[i], enemigo[i].x, enemigo[i].y);
                        ELSE
                            IF (enemigo[i].tipo == 2)
                                disparar_enemigo_tipo2(&tiempo_disparo[i], enemigo[i].x, enemigo[i].y);
                            END
                        END
                    END
                ELSE
                    // Enemigo no visible, eliminar proceso hijo si existe
                    IF (procesos_enemigo[i] != 0)
                        signal(procesos_enemigo[i], s_kill);
                        procesos_enemigo[i] = 0;
                    END
                END
            ELSE
                // Enemigo muerto, eliminar proceso hijo si existe
                IF (procesos_enemigo[i] != 0)
                    signal(procesos_enemigo[i], s_kill);
                    procesos_enemigo[i] = 0;
                END
            END
        END

        FRAME;
    END
END

//------------------------------------------------------------------------------
// PROCESS: proceso_enemigo_visual (NUEVO)
// DESCRIPCION: Proceso hijo liviano que solo se encarga de visualizar un enemigo.
//              Usa ctype=c_screen para coordenadas de pantalla.
//              Lee los datos del enemigo desde el struct enemigo[].
//------------------------------------------------------------------------------
PROCESS proceso_enemigo_visual(INT index);
BEGIN
    ctype = c_screen;  // Usar coordenadas de pantalla
    file = FPG_LEVEL;  // Archivo de graficos

    LOOP
        // Si el enemigo ya no esta activo o el juego termino, salir
        IF (enemigo[index].activo == 0 OR game_over == 1)
            RETURN;
        END

        // Actualizar posicion en pantalla (convertir de coordenadas de mapa a pantalla)
        x = enemigo[index].x - scroll.x0;
        y = enemigo[index].y - scroll.y0;

        // Actualizar grafico segun tipo
        IF (enemigo[index].tipo == 1)
            graph = GRAFICO_ENEMIGO1;
            // Rotar segun direccion de movimiento
            IF (enemigo[index].dir == 1)
                angle = ANGULO_ROTACION_ENEMIGO;  // Rotar 15° a la derecha
            ELSE
                angle = ANGULO_ROTACION_ENEMIGO_OPUESTA;  // Rotar 15° a la izquierda
            END
            size = ESCALA_ENEMIGO;
        ELSE
            IF (enemigo[index].tipo == 2)
                graph = GRAFICO_ENEMIGO2;
                angle = 0;
                size = 100;
            ELSE
                // Tipo 3: usar grafico aleatorio asignado
                graph = enemigo[index].grafico_tipo3;
                angle = 0;
                size = ESCALA_ENEMIGO;
            END
        END

        // Asegurar que graph sea valido
        IF (graph != GRAFICO_ENEMIGO1 AND graph != GRAFICO_ENEMIGO2)
            graph = GRAFICO_ENEMIGO2;
        END

        FRAME;
    END
END

// Funcion: mover_enemigo_tipo1
// Descripcion: Maneja el movimiento horizontal del enemigo tipo 1, cambiando direccion al llegar a los bordes y descendiendo.
// Parametros:
//   - x_offset: Puntero a la posicion x. -> Usamos el puntero para modificar la variable original.
//   - y_offset: Puntero a la posicion y. -> Usamos el puntero para modificar la variable original.
//   - dir_offset: Puntero a la direccion (1 o -1). -> Usamos el puntero para modificar la variable original.
// Los punteros sirven para modificar las variables originales fuera de la funcion.
// - Si modificas una varariable del puntero dentro de la funcion, se refleja fuera tambien.
// - Sirve para evitar el uso de variables globales innecesarias.
// Los PROCESS se ejecutan en paralelo, mientras que las FUNCTION se ejecutan de forma secuencial
// - Es decir, hasta que no termine esta funcion, el proceso que lo llama queda bloqueado
FUNCTION mover_enemigo_tipo1(INT x_offset, INT y_offset, INT dir_offset);
BEGIN
    // Movemos horizontalmente el enemigo segun su direccion actual
    *x_offset += *dir_offset * VEL_ENEMIGO1_HORIZONTAL;
    // Si llega a los bordes, cambiamos direccion y lo hacemos bajar un poco
    IF (*x_offset > ANCHO_PANTALLA - (TAMANO_ENEMIGO1 + DISTANCIA_COLISION) OR *x_offset < TAMANO_ENEMIGO1 + DISTANCIA_COLISION)
        *dir_offset = -*dir_offset;     // Cambiamos direccion
        *y_offset += DESCENSO_ENEMIGO1; // Descendemos
    END
END

// Funcion: disparar_enemigo_tipo1 (MODIFICADA)
// Descripcion: Controla el disparo periodico del enemigo tipo 1.
// - Ahora usa el sistema de balas optimizado con crear_bala()
// Parametros:
//   - tiempo_offset: Puntero al contador de tiempo. -> Usamos el puntero para modificar la variable original.
//   - x: Posicion x para disparar.
//   - y: Posicion y para disparar.
// Los punteros sirven para modificar las variables originales fuera de la funcion.
// - Si modificas una varariable del puntero dentro de la funcion, se refleja fuera tambien.
// - Sirve para evitar el uso de variables globales innecesarias.
// Los PROCESS se ejecutan en paralelo, mientras que las FUNCTION se ejecutan de forma secuencial
// - Es decir, hasta que no termine esta funcion, el proceso que lo llama queda bloqueado
FUNCTION disparar_enemigo_tipo1(INT tiempo_offset, x, y);
PRIVATE
    INT tiempo_disparo_aleatorio;  // Tiempo de disparo con componente aleatorio
BEGIN
    (*tiempo_offset)++;     // (*tiempo_offset) es el valor apuntado por el puntero, con ++ lo incrementamos en una unidad.
    // Anadimos aleatoriedad al tiempo de disparo para evitar que todos disparen a la vez
    tiempo_disparo_aleatorio = TIEMPO_DISPARO_ENEMIGO1 + rand(-VARIACION_TIEMPO_DISPARO_ENEMIGO, VARIACION_TIEMPO_DISPARO_ENEMIGO);
    // Verificamos si se cumple con el espaciado (para que las balas no esten muy juntas)
    IF (*tiempo_offset > tiempo_disparo_aleatorio)
        // Cumplido el tiempo, disparamos una bala
        crear_bala_enemigo(x, y, TIPO_BALA_ENEMIGA1, 0);   // Crear bala en el array (MODIFICADO)
        explosion_pequena(x, y, COLOR_EXPLOSION_PEQUENA);  // Explosion pequena al disparar
        sound(WAV_DISPARO, VOL_MAX, FREQ_NORMAL);  // Reproducir sonido de disparo
        *tiempo_offset = 0;         // Reiniciamos el contador de tiempo
    END
END

// Descripcion: Maneja el movimiento circular del enemigo tipo 2, manteniendolo dentro del mapa.
// Parametros:
//   - x_offset: Puntero a la posicion x. -> Usamos el puntero para modificar la variable original.
//   - y_offset: Puntero a la posicion y. -> Usamos el puntero para modificar la variable original.
//   - ang_offset: Puntero al angulo de movimiento. -> Usamos el puntero para modificar la variable original.
// Los punteros sirven para modificar las variables originales fuera de la funcion.
// - Si modificas una varariable del puntero dentro de la funcion, se refleja fuera tambien.
// - Sirve para evitar el uso de variables globales innecesarias.
// Los PROCESS se ejecutan en paralelo, mientras que las FUNCTION se ejecutan de forma secuencial
// - Es decir, hasta que no termine esta funcion, el proceso que lo llama queda bloqueado
FUNCTION mover_enemigo_tipo2(INT x_offset, INT y_offset, INT ang_offset);
BEGIN
    // Incrementamos el angulo y nos movemos en circulo
    *ang_offset += INCREMENTO_ANGULO_ENEMIGO2;
    *x_offset += get_distx(*ang_offset, RADIO_MOVIMIENTO_ENEMIGO2);
    *y_offset += get_disty(*ang_offset, RADIO_MOVIMIENTO_ENEMIGO2);

    // Verificamos que no salgamos de los limites HORIZONTALES (ancho de pantalla, no del mapa)
    IF (*x_offset < TAMANO_ENEMIGO2_LINEA + TAMANO_ENEMIGO2_CIRCULO)
         *x_offset = TAMANO_ENEMIGO2_LINEA + TAMANO_ENEMIGO2_CIRCULO;
    ELSE
        IF (*x_offset > ANCHO_PANTALLA - (TAMANO_ENEMIGO2_LINEA + TAMANO_ENEMIGO2_CIRCULO))
            *x_offset = ANCHO_PANTALLA - (TAMANO_ENEMIGO2_LINEA + TAMANO_ENEMIGO2_CIRCULO);
        END
    END

    // Verificamos que no salgamos de los limites VERTICALES (altura del mapa, NO de la pantalla)
    IF (*y_offset < TAMANO_ENEMIGO2_LINEA + TAMANO_ENEMIGO2_CIRCULO)
        *y_offset = TAMANO_ENEMIGO2_LINEA + TAMANO_ENEMIGO2_CIRCULO;
    ELSE
        IF (*y_offset > ALTO_MAPA - (TAMANO_ENEMIGO2_LINEA + TAMANO_ENEMIGO2_CIRCULO))
            *y_offset = ALTO_MAPA - (TAMANO_ENEMIGO2_LINEA + TAMANO_ENEMIGO2_CIRCULO);
        END
    END
END

// Funcion: disparar_enemigo_tipo2 (MODIFICADA)
// Descripcion: Controla el disparo periodico del enemigo tipo 2.
// - Ahora usa el sistema de balas optimizado con crear_bala()
// Parametros:
//   - tiempo_offset: Puntero al contador de tiempo. -> Usamos el puntero para modificar la variable original.
//   - x: Posicion x para disparar.
//   - y: Posicion y para disparar.
// Los punteros sirven para modificar las variables originales fuera de la funcion.
// - Si modificas una varariable del puntero dentro de la funcion, se refleja fuera tambien.
// - Sirve para evitar el uso de variables globales innecesarias.
// Los PROCESS se ejecutan en paralelo, mientras que las FUNCTION se ejecutan de forma secuencial
// - Es decir, hasta que no termine esta funcion, el proceso que lo llama queda bloqueado
FUNCTION disparar_enemigo_tipo2(INT tiempo_offset, x, y);
PRIVATE
    INT tiempo_disparo_aleatorio;  // Tiempo de disparo con componente aleatorio
    INT id_jugador;                // ID del jugador para calcular angulo
    INT angulo;                    // Angulo de disparo
BEGIN
    (*tiempo_offset)++; // Incrementamos el contador de tiempo. (*tiempo_offset) es el valor apuntado por el puntero, con ++ lo incrementamos en una unidad.
    // Anadimos aleatoriedad al tiempo de disparo para evitar que todos disparen a la vez
    tiempo_disparo_aleatorio = TIEMPO_DISPARO_ENEMIGO2 + rand(-12, 12);
    // Verificamos si se cumple con el espaciado (para que las balas no esten muy juntas)
    IF (*tiempo_offset > tiempo_disparo_aleatorio)
        // Cumplido el tiempo, disparamos una bala
        // Calcular angulo hacia el jugador
        id_jugador = get_id(type jugador);
        IF (id_jugador != 0)
            // El jugador esta vivo, calculamos el angulo hacia el
            angulo = fget_angle(x, y, id_jugador.x, id_jugador.y);
        ELSE
            // No hay jugador, disparamos hacia abajo por defecto
            angulo = ANGULO_DEFECTO_BALA;
        END
        crear_bala_enemigo(x, y, TIPO_BALA_ENEMIGA2, angulo);   // Crear bala en el array (MODIFICADO)
        explosion_pequena(x, y, COLOR_EXPLOSION_PEQUENA);  // Explosion pequena al disparar
        sound(WAV_DISPARO, VOL_MAX, FREQ_NORMAL);  // Reproducir sonido de disparo
        *tiempo_offset = 0;         // Reiniciamos el contador de tiempo
    END
END

// Funcion: mover_enemigo_tipo3
// Descripcion: Maneja el movimiento vertical (de arriba a abajo) y horizontal (acercándose al jugador) del enemigo tipo 3.
// Parametros:
//   - x_offset: Puntero a la posicion x. -> Usamos el puntero para modificar la variable original.
//   - y_offset: Puntero a la posicion y. -> Usamos el puntero para modificar la variable original.
// Los punteros sirven para modificar las variables originales fuera de la funcion.
// - Si modificas una varariable del puntero dentro de la funcion, se refleja fuera tambien.
// - Sirve para evitar el uso de variables globales innecesarias.
// Los PROCESS se ejecutan en paralelo, mientras que las FUNCTION se ejecutan de forma secuencial
// - Es decir, hasta que no termine esta funcion, el proceso que lo llama queda bloqueado
FUNCTION mover_enemigo_tipo3(INT x_offset, INT y_offset);
PRIVATE
    INT id_jugador;  // ID del jugador
    INT dir_x;       // Direccion horizontal hacia el jugador
BEGIN
    // Movemos verticalmente hacia abajo
    *y_offset += VEL_ENEMIGO3_VERTICAL;

    // Movemos horizontalmente hacia el jugador
    id_jugador = get_id(type jugador);
    IF (id_jugador != 0)
        // Calculamos la direccion hacia el jugador
        IF (id_jugador.x > *x_offset)
            dir_x = 1;  // Derecha
        ELSE
            dir_x = -1; // Izquierda
        END
        *x_offset += dir_x * VEL_ENEMIGO3_HORIZONTAL;
    END

    // Verificamos limites horizontales
    IF (*x_offset < TAMANO_ENEMIGO1 + DISTANCIA_COLISION)
        *x_offset = TAMANO_ENEMIGO1 + DISTANCIA_COLISION;
    ELSE
        IF (*x_offset > ANCHO_PANTALLA - (TAMANO_ENEMIGO1 + DISTANCIA_COLISION))
            *x_offset = ANCHO_PANTALLA - (TAMANO_ENEMIGO1 + DISTANCIA_COLISION);
        END
    END
END

// Proceso: explosion
// Descripcion: Crea una animacion de explosion en la posicion dada.
// - Dibuja circulos crecientes de color especificado durante varias iteraciones.
// - Borra el ultimo dibujo si no es game over (asi podemos ver la explosion "parada" en game over y entender que ha pasado).
// Parametros:
//   - x: Posicion x de la explosion.
//   - y: Posicion y de la explosion.
//   - color: Color de la explosion.
PROCESS explosion(x, y, color);
PRIVATE
    i;                                  // Contador para el bucle
    radio = RADIO_INICIAL_EXPLOSION;    // Radio inicial del circulo
    exp_draw;                           // ID del dibujo de la explosion
    pantalla_x;                         // Coordenada X de pantalla
    pantalla_y;                         // Coordenada Y de pantalla
BEGIN
    // Animamos la explosion con circulos crecientes
    FOR(i=0 ; i <= FRAMES_ANIMACION_EXPLOSION; i++)
        // Convertir coordenadas de mapa a pantalla
        pantalla_x = x - scroll.x0;
        pantalla_y = y - scroll.y0;

        exp_draw = draw(TIPO_DIBUJO_CIRCULO_RELLENO, color, OPACIDAD_DRAW, REGION_DRAW, pantalla_x - radio, pantalla_y - radio, pantalla_x + radio, pantalla_y + radio);  // Dibujamos un circulo
        radio += INCREMENTO_RADIO_EXPLOSION;  // Augmentamos radio
        FRAME;  // Esperamos al siguiente frame
    END
END

// Proceso: explosion_pequena
// Descripcion: Crea una animacion de explosion pequena para efectos de disparo
// - Mas pequena y rapida que la explosion normal
// Parametros:
//   - x: Posicion x de la explosion.
//   - y: Posicion y de la explosion.
//   - color: Color de la explosion.
PROCESS explosion_pequena(x, y, color);
PRIVATE
    i;  // Contador para el bucle
    radio = 3;  // Radio inicial mas pequeno
    exp_draw;  // ID del dibujo de la explosion
    pantalla_x;  // Coordenada X de pantalla
    pantalla_y;  // Coordenada Y de pantalla
BEGIN
    // Animamos la explosion pequena
    FOR(i=0 ; i <= ITERACIONES_EXPLOSION_PEQUENA; i++)   // Menos iteraciones para que sea mas rapida
        // Convertir coordenadas de mapa a pantalla
        pantalla_x = x - scroll.x0;
        pantalla_y = y - scroll.y0;
        exp_draw = draw(TIPO_DIBUJO_CIRCULO_RELLENO, color, OPACIDAD_DRAW, REGION_DRAW, pantalla_x - radio, pantalla_y - radio, pantalla_x + radio, pantalla_y + radio);
        radio++;  // Incremento menor
        FRAME;
    END
END

// Funcion: cuenta_regresiva (OPTIMIZACION: Funcion generica para cuentas regresivas.
// Reduce duplicacion entre cuenta_regresiva e inicio_nivel.)
// Descripcion: Muestra una pantalla de felicitacion con puntos y una cuenta regresiva antes del siguiente nivel.
// - Espera a que el usuario pulse espacio para continuar.
// Los PROCESS se ejecutan en paralelo, mientras que las FUNCTION se ejecutan de forma secuencial
// - Aunque tenga FRAME dentro, es una funcion y bloquea el proceso que la llama (hack de DIV)
// - Segun la documentacion de DIV, el compilador si detecta un FRAME lo transforma en un PROCESS automaticamente
// - Es decir, hasta que no termine esta funcion, el proceso que lo llama queda bloqueado
FUNCTION cuenta_regresiva();
PRIVATE
    INT contador = SEGUNDOS_CUENTA_REGRESIVA;   // Segundos para el siguiente nivel
    INT tiempo = 0;                             // Contador de frames
    STRING puntos_str;                          // String para mostrar puntos
    STRING contador_str;                        // String para mostrar contador
BEGIN
    // Bucle de cuenta regresiva
    WHILE (contador > 0)
        delete_text(all_text);  // Limpiamos TODS los textos anteriores
        mostrar_textos_hud();   // Dibujamos los textos del HUD
        write(FNT_PRESS, CENTRO_X, POS_Y_CUENTA_REGRESIVA_BASE, 1, "¡ENHORABUENA!");       // Mensaje de felicitacion
        write(FNT_NORMAL, CENTRO_X, POS_Y_CUENTA_REGRESIVA_BASE + ESPACIADO_LINEA_NORMAL, 1, "NIVEL COMPLETADO!");
        puntos_str = "Puntos: " + itoa(puntos);                     // Convertimos los puntos a string
        write(FNT_NORMAL, CENTRO_X, POS_Y_CUENTA_REGRESIVA_BASE + ESPACIADO_LINEA_NORMAL * 2, 1, puntos_str);             // Mostramos puntos
        write(FNT_NORMAL, CENTRO_X, POS_Y_CUENTA_REGRESIVA_BASE + ESPACIADO_LINEA_NORMAL * 3, 1, "Siguiente nivel en:");  // Texto estatico
        contador_str = itoa(contador);                              // Convertimos el contador a string
        write(FNT_COUNTER, CENTRO_X, POS_Y_CUENTA_REGRESIVA_BASE + ESPACIADO_LINEA_NORMAL * 4, 1, contador_str);         // Mostramos contador regresivo con fuente grande

        tiempo++;   // Incrementamos el contador de frames
        IF (tiempo >= FPS_JUEGO)
            // Ha pasado 1 segundo, actualizamos la cuenta atras
            contador--;
            tiempo = 0;
        END

        // Siguiente frame
        FRAME;
    END

    delete_draw(all_drawing);  // Limpiamos todos los dibujos de la pantalla
    delete_text(all_text);     // Limpiamos todos los textos
    mostrar_textos_hud();      // Volmemos a dibujar los textos del HUD
END

//------------------------------------------------------------------------------
// FUNCION: fade_to_black
// DESCRIPCION: Hace un fundido a negro (apaga la pantalla)
//              La funcion detiene el programa hasta que el fundido se completa
//------------------------------------------------------------------------------
FUNCTION fade_to_black();
BEGIN
    fade_off();  // Apaga la pantalla gradualmente
END

//------------------------------------------------------------------------------
// FUNCION: fade_from_black
// DESCRIPCION: Deshace el fundido desde negro (enciende la pantalla)
//              La funcion detiene el programa hasta que el fundido se completa
//------------------------------------------------------------------------------
FUNCTION fade_from_black();
BEGIN
    fade_on();  // Enciende la pantalla gradualmente
END

//------------------------------------------------------------------------------
// FUNCION: cargar_y_reproducir_wav
// DESCRIPCION: Carga un wav, muestra "CARGANDO", reproduce el sonido y borra el texto
// PARAMETROS:
//   - ruta: Ruta del archivo wav
//   - loop_mode: Modo de loop (LOOP_SI o LOOP_NO)
//------------------------------------------------------------------------------
FUNCTION cargar_y_reproducir_wav(STRING ruta, INT loop_mode);
PRIVATE
    INT id_texto;
BEGIN
    IF (ruta == musica_actual) RETURN; END
    detener_y_descargar_musica();
    id_texto = write(0, 160, 100, 4, "CARGANDO");
    FRAME;
    WAV_MUSIC = load_wav(ruta, loop_mode);
    WAV_CHANNEL = sound(WAV_MUSIC, VOL_MAX, FREQ_NORMAL);
    musica_actual = ruta;
    delete_text(id_texto);
END

//------------------------------------------------------------------------------
// FUNCION: detener_y_descargar_musica
// DESCRIPCION: Detiene el canal de sonido y descarga la música si están activos
//------------------------------------------------------------------------------
FUNCTION detener_y_descargar_musica();
BEGIN
    IF (WAV_CHANNEL != 0)
        stop_sound(WAV_CHANNEL);
    END
    IF (WAV_MUSIC != 0)
        unload_wav(WAV_MUSIC);
    END
    musica_actual = "";
END

//------------------------------------------------------------------------------
// FUNCION: limpiar_recursos_y_reiniciar
// DESCRIPCION: Descarga recursos del nivel (FPG, música) y reinicia variables globales del juego
//------------------------------------------------------------------------------
FUNCTION limpiar_recursos_y_reiniciar();
BEGIN
    // Descargar FPG del nivel
    IF (FPG_LEVEL != 0)
        unload_fpg(FPG_LEVEL);
        FPG_LEVEL = 0;
    END

    // Reiniciar variables globales del juego
    puntos = 0;
    nivel = 1;
    nivel_actual = NIVEL_INICIAL;
    game_over = 0;
    vidas_jugador = VIDAS_INICIALES;
    jugador_inmune = 0;
    juego_pausado = 0;
    controles_activos = 0;
    scroll_y_objetivo = 0;
    contador_scroll = 0;
    volver_menu = 0;

    // Resetear flags de cinemáticas para nueva partida
    saltar_cinematica = 0;

    // Reiniciar listas enlazadas
    primera_bala_jugador_activa = -1;
    primer_slot_libre_jugador = 0;
    primera_bala_enemigo_activa = -1;
    primer_slot_libre_enemigo = 0;
    primera_enemigo_activo = -1;
END

//------------------------------------------------------------------------------
// PROCESS: mostrar_pagina_cinematica
// DESCRIPCION: Muestra una pagina de texto en el area de dialogo de la cinematica
//              Espera a que se pulse espacio para continuar
//              Setea resultado_pagina_global: 0=continuar, 1=saltar cinematica, 2=menu principal, 3=salir
PROCESS mostrar_pagina_cinematica(INT cinematic_id, INT cg_actual, INT pagina_actual, INT fpg_cg);
PRIVATE
    INT y_base;
    INT parpadeo = 0;               // Contador para el parpadeo
    INT id_enter = 0;               // ID del process del gráfico [ENTER]
    INT resultado_menu;             // Resultado del menu de pausa
    STRING linea1[50], linea2[50], linea3[50], linea4[50];
BEGIN
    // Obtener las líneas de texto desde la nueva estructura paginas
    linea1 = cinematics[cinematic_id].cgs[cg_actual].paginas[pagina_actual].linea1;
    linea2 = cinematics[cinematic_id].cgs[cg_actual].paginas[pagina_actual].linea2;
    linea3 = cinematics[cinematic_id].cgs[cg_actual].paginas[pagina_actual].linea3;
    linea4 = cinematics[cinematic_id].cgs[cg_actual].paginas[pagina_actual].linea4;

    y_base = CG_Y_TEXTO_BASE;

    // Mostrar las líneas de texto que no estén vacías
    IF (linea1 != "")
        write(0, CENTRO_X, y_base, ALINEACION_CENTRADO, linea1);
        y_base = y_base + CG_ESPACIADO_LINEA;
    END
    IF (linea2 != "")
        write(0, CENTRO_X, y_base, ALINEACION_CENTRADO, linea2);
        y_base = y_base + CG_ESPACIADO_LINEA;
    END
    IF (linea3 != "")
        write(0, CENTRO_X, y_base, ALINEACION_CENTRADO, linea3);
        y_base = y_base + CG_ESPACIADO_LINEA;
    END
    IF (linea4 != "")
        write(0, CENTRO_X, y_base, ALINEACION_CENTRADO, linea4);
    END

    // Mostrar gráfico parpadeante de [ENTER]
    id_enter = enter_grafico(fpg_cg, CG_POS_X_ENTER, CG_POS_Y_ENTER);

    // Esperar a que se suelte espacio/enter
    WHILE (key(_space) or key(_enter))
        FRAME;
    END

    // Esperar a que se pulse espacio/enter para avanzar (con parpadeo de [ENTER])
    LOOP
        // Verificar si se pulsa ESC para mostrar menu de pausa
        IF (key(_ESC))
            // Borrar el gráfico [ENTER] si existe
            IF (id_enter != 0)
                signal(id_enter, s_kill);
                id_enter = 0;
            END

            menu_pausa_cinematica();

            // Esperar a que el menu retorne el resultado
            WHILE (resultado_menu_global == -1) FRAME; END

            // Setear el resultado global para que lo procese la cinematica
            resultado_pagina_global = resultado_menu_global;
            delete_text(all_text);
            RETURN;
        END

        // Verificar si se pulsa espacio o enter
        IF (key(_space) OR key(_enter))
            BREAK;
        END

        FRAME;
    END

    // Limpiar gráfico y textos del area de dialogo
    signal(id_enter, s_kill);
    delete_text(all_text);
    resultado_pagina_global = 0;
END

// PROCESS: marco_dialogo
// DESCRIPCION: Muestra el grafico 3 del FPG en la posicion del area de dialogo
//------------------------------------------------------------------------------
PROCESS marco_dialogo(INT fpg);
BEGIN
    file = fpg;
    graph = 3;
    x = 160;
    y = 175;
    LOOP
        FRAME;
    END
END

//------------------------------------------------------------------------------
// FUNCION: cinematica
// DESCRIPCION: Muestra una cinematica completa usando datos del struct
// PARAMETROS:
//   - cinematic_id: ID de la cinematica (0=1_inicio, 1=1_final, etc.)
//------------------------------------------------------------------------------
FUNCTION cinematica(INT cinematic_id)
PRIVATE
    INT cg_actual;
    INT pagina_actual;
    INT fpg_cg;
    INT id_marco;
    INT opcion_seleccionada;
    INT salir_cinematica_local = 0;
BEGIN
    delete_text(all_text);  // Limpiar textos previos
    delete_draw(all_drawing);  // Limpiar dibujos previos
    // Detener música
    detener_y_descargar_musica();

    // Verificar si se debe saltar la cinematica
    IF (saltar_cinematica == 1)
        saltar_cinematica = 0;
        RETURN;
    END


    // Cargar música de la cinemática (una vez por cinemática, no por CG)
    cargar_y_reproducir_wav(cinematics[cinematic_id].cgs[0].wav_ruta, LOOP_SI);

    // Bucle por cada CG
    FOR (cg_actual = 0; cg_actual < cinematics[cinematic_id].num_cg
            && salir_cinematica_local == 0
            && saltar_cinematica == 0
            && volver_menu == 0
            && salir_juego == 0
            ; cg_actual++)
        // Cargar FPG y paleta
        fpg_cg = load_fpg(cinematics[cinematic_id].cgs[cg_actual].fpg_ruta);
        load_pal(cinematics[cinematic_id].cgs[cg_actual].pal_ruta);
        put_screen(fpg_cg, FONDO_SD);
        fade_from_black();
        id_marco = marco_dialogo(fpg_cg);

        // Bucle por cada página
        FOR (pagina_actual = 0; pagina_actual < cinematics[cinematic_id].cgs[cg_actual].num_paginas; pagina_actual++)
            resultado_pagina_global = -1;
            mostrar_pagina_cinematica(cinematic_id, cg_actual, pagina_actual, fpg_cg);
            WHILE (resultado_pagina_global == -1)
                FRAME;
            END
            IF (manejar_resultado_menu(resultado_pagina_global, id_marco, cinematics[cinematic_id].siguiente_nivel) > 0)
                salir_cinematica_local = 1;
                BREAK;
            END
        END

        signal(id_marco, s_kill);
        unload_fpg(fpg_cg);
    END

    // Si el usuario eligió salir al DOS, no hacer transición ni cuenta atrás
    IF (salir_juego == 1)
        salir_juego = 0;
        exit(TEXTO_SALIDA, 0);
    END
    // Si el usuario eligió volver al menú principal, guardar puntuación si corresponde y volver inmediatamente
    IF (volver_menu == 1)
        actualizar_top_scores(puntos);
        guardar_top_scores();
        RETURN(1);
    END

    // Preparar transicion al siguiente nivel solo si no se ha pedido volver al menú ni salir
    preparar_transicion_nivel(cinematics[cinematic_id].siguiente_nivel);
    RETURN(0);
END

//------------------------------------------------------------------------------
// FUNCION: mostrar_creditos
// DESCRIPCION: Muestra los créditos del juego en la esquina superior izquierda
//------------------------------------------------------------------------------
FUNCTION mostrar_creditos();
BEGIN
    if (FNT_COPY == 0)
        FNT_COPY = load_fnt(RUTA_FNT_COPY);
    END
    write(FNT_COPY, 10, 3, ALINEACION_IZQUIERDA, "Le Hamster Ruso (2026)");
    write(FNT_COPY, 10, 13, ALINEACION_IZQUIERDA, "Desarrollado como tutorial");
    write(FNT_COPY, 10, 23, ALINEACION_IZQUIERDA, "educativo para el aprendizaje de");
    write(FNT_COPY, 10, 33, ALINEACION_IZQUIERDA, "programación en entorno MS-DOS.");
    write(FNT_COPY, 10, 43, ALINEACION_IZQUIERDA, "Inspirado en la obra");
    write(FNT_COPY, 10, 53, ALINEACION_IZQUIERDA, "'Yojo Senki' de Carlo Zen");
END

//------------------------------------------------------------------------------
// FUNCION: pantalla_inicio
// DESCRIPCION: Muestra la pantalla inicial con el grafico 1 de START.FPG
//              y un texto parpadeante "[PULSA CUALQUIER BOTON]"
//              El FPG trae su propia paleta de colores
//------------------------------------------------------------------------------
FUNCTION pantalla_inicio();
PRIVATE
    INT parpadeo = 0;       // Contador para el parpadeo del texto
    INT id_texto_parpadeo = 0;  // ID del texto parpadeante
BEGIN
    // Cargar FPG de inicio con su propia paleta
    FPG_START = load_fpg(RUTA_FPG_START);
    load_pal(RUTA_FPG_START);

    detener_y_descargar_musica();

    // Cargar y reproducir música de título en bucle
    cargar_y_reproducir_wav(RUTA_WAV_TITLE, LOOP_SI);

    // Mostrar el grafico 1 del FPG (pantalla completa)
    put_screen(FPG_START, FONDO_SD);

    // Mostrar créditos en la esquina superior izquierda
    mostrar_creditos();

    // Mostrar texto parpadeante
    id_texto_parpadeo = write(0, CENTRO_X, ALTO_PANTALLA - 30, ALINEACION_CENTRADO, "[PULSA CUALQUIER BOTON]");

    // Esperar a que no haya ninguna tecla pulsada
    WHILE (scan_code != 0)
        FRAME;
    END

    // Esperar a que se pulse cualquier tecla
    LOOP
        IF (scan_code != 0)
            // Se ha pulsado alguna tecla
            delete_text(all_text);
            RETURN;
        END

        // Borrar solo el texto parpadeante y redibujarlo segun el parpadeo
        IF (id_texto_parpadeo != 0)
            delete_text(id_texto_parpadeo);
            id_texto_parpadeo = 0;
        END

        // Parpadeo 66% visible (2 de cada 3 frames), 33% oculto (1 de cada 3)
        IF ((parpadeo / FRECUENCIA_PARPADEO_INICIO) MOD 3 != 2)
            id_texto_parpadeo = write(0, CENTRO_X, ALTO_PANTALLA - 30, ALINEACION_CENTRADO, "[PULSA CUALQUIER BOTON]");
        END
        parpadeo++;

        FRAME;
    END
END

//------------------------------------------------------------------------------
// FUNCION: menu_principal
// DESCRIPCION: Muestra el menu principal interactivo con opciones:
//              - Nueva Partida
//              - Salir al DOS
//              Navegacion con cursores arriba/abajo, seleccion con espacio o intro
//              El menu se muestra dentro del recuadro de 160x50 con el grafico 3 del FPG START
//------------------------------------------------------------------------------
FUNCTION menu_principal();
PRIVATE
    INT opcion = 1;  // Opcion seleccionada (1=Nueva Partida, 2=Salir)
    INT id_proceso_grafico = 0;  // ID del proceso que muestra el grafico del menu
    INT id_texto_opcion1 = 0;  // ID del texto de la opcion 1
    INT id_texto_opcion2 = 0;  // ID del texto de la opcion 2
    INT menu_centro_y;  // Posicion Y del centro del menu
BEGIN
    // Cargar FPG de inicio si no esta cargado
    FPG_START = load_fpg(RUTA_FPG_START);

    // Mostrar grafico 3 del FPG en la parte inferior (recuadro 160x50)
    id_proceso_grafico = grafico_menu();

    // Calcular posicion central del menu (dentro del recuadro)
    menu_centro_y = MENU_Y + MENU_ALTO / 2;

    // Esperar especificamente a que se suelten espacio y enter de la pantalla anterior
    WHILE (key(_space) OR key(_enter))
        FRAME;
    END

    // Mostrar créditos en la esquina superior izquierda
    mostrar_creditos();

    // Mostrar el top 10 en la parte superior derecha
    mostrar_top_scores();

    // Bucle del menu interactivo
    LOOP
        // Borrar textos anteriores
        IF (id_texto_opcion1 != 0)
            delete_text(id_texto_opcion1);
        END
        IF (id_texto_opcion2 != 0)
            delete_text(id_texto_opcion2);
        END

        // Mostrar opciones con cursor segun la seleccion actual
        IF (opcion == 1)
            id_texto_opcion1 = write(0, CENTRO_X, menu_centro_y - 10, ALINEACION_CENTRADO, "> NUEVA PARTIDA <");
            id_texto_opcion2 = write(0, CENTRO_X, menu_centro_y + 10, ALINEACION_CENTRADO, "  SALIR AL DOS  ");
        ELSE
            id_texto_opcion1 = write(0, CENTRO_X, menu_centro_y - 10, ALINEACION_CENTRADO, "  NUEVA PARTIDA  ");
            id_texto_opcion2 = write(0, CENTRO_X, menu_centro_y + 10, ALINEACION_CENTRADO, "> SALIR AL DOS <");
        END

        // Navegacion con cursores
        IF (key(_up))
            opcion--;
            IF (opcion < 1)
                opcion = 2;  // Volver a la ultima opcion
            END
            // Esperar a que se suelte la tecla
            WHILE (key(_up))
                FRAME;
            END
        END
        IF (key(_down))
            opcion++;
            IF (opcion > 2)
                opcion = 1;  // Volver a la primera opcion
            END
            // Esperar a que se suelte la tecla
            WHILE (key(_down))
                FRAME;
            END
        END

        // Seleccionar con espacio o intro
        IF (key(_space) OR key(_enter))
            // Esperar a que se suelte la tecla antes de salir
            WHILE (key(_space) OR key(_enter))
                FRAME;
            END
            BREAK;  // Salir del bucle con la opcion seleccionada
        END

        // ESC para salir directamente
        IF (key(_ESC))
            opcion = 2;
            BREAK;
        END

        FRAME;
    END

    // Limpiar pantalla y procesos
    delete_text(all_text);
    signal(id_proceso_grafico, s_kill);
    clear_screen();
    unload_fpg(FPG_START);

    // Ejecutar la opcion seleccionada
    IF (opcion == 2)
        // Salir al DOS
        exit(TEXTO_SALIDA, 0);
    END
    // Si opcion == 1, continuar con el juego (no hacer nada, el flujo continua)
END

//------------------------------------------------------------------------------
// PROCESO: grafico_menu
// DESCRIPCION: Proceso que muestra el grafico 3 del FPG START
//              en un recuadro de 160x50 en la parte inferior de la pantalla
//------------------------------------------------------------------------------
PROCESS grafico_menu();
BEGIN
    file = FPG_START;
    graph = 3;
    x = CENTRO_X;
    y = MENU_Y + MENU_ALTO / 2;
    size = 100;  // Tamano normal
    LOOP
        FRAME;
    END
END

// Funcion: pantalla_game_over
// Descripcion: Muestra la pantalla de game over con puntos y una cuenta regresiva para reiniciar.
//              Espera a que el usuario pulse espacio para continuar.
// Los PROCESS se ejecutan en paralelo, mientras que las FUNCTION se ejecutan de forma secuencial
// - Aunque tenga FRAME dentro, es una funcion y bloquea el proceso que la llama (hack de DIV)
// - Es decir, hasta que no termine esta funcion, el proceso que lo llama queda bloqueado
FUNCTION pantalla_game_over();
PRIVATE
    STRING puntos_str;  // String para mostrar puntos
    INT parpadeo = 0;   // Contador para el parpadeo del texto
    INT id_texto_parpadeo = 0;  // ID del texto parpadeante
BEGIN
    delete_text(all_text);  // Limpiamos TODOS los textos anteriores
    mostrar_textos_hud();   // Volvemos a dibujar los textos del HUD
    write(FNT_GAMEOVER, CENTRO_X, POS_Y_GAMEOVER, ALINEACION_CENTRADO, "GAME OVER!");  // Mensaje de game over
    puntos_str = "Puntos: " + itoa(puntos);  // Mostramos los puntos
    write(FNT_NORMAL, CENTRO_X, POS_Y_PUNTOS_GAMEOVER, ALINEACION_CENTRADO, puntos_str);
    id_texto_parpadeo = write(FNT_PRESS, CENTRO_X, POS_Y_PULSA_ESPACIO, ALINEACION_CENTRADO, "[PULSA ESPACIO]");

    // Esperamos a que se suelte la tecla espacio
    // Evita que se salte la pantalla si se mantiene pulsada
    // scan_code contiene el codigo de la ultima tecla pulsada
    // Si scan_code es 0, no hay ninguna tecla pulsada
    WHILE (scan_code != 0)
        FRAME;
    END

    // Ahora esperar a que se pulse espacio
    LOOP
        IF (key(_space))
            // Se ha pulsado espacio, paramos la funcion para reiniciar la partida
            delete_text(all_text);// Limpiamos TODOS textos
            mostrar_textos_hud(); // Volvemos a dibujar los textos del HUD
            RETURN;
        END

        // Borrar solo el texto parpadeante y redibujarlo segun el parpadeo
        IF (id_texto_parpadeo != 0)
            delete_text(id_texto_parpadeo);
            id_texto_parpadeo = 0;
        END

        IF ((parpadeo / FRECUENCIA_PARPADEO_GAMEOVER) MOD 2 == 0)
            id_texto_parpadeo = write(FNT_PRESS, CENTRO_X, POS_Y_PULSA_ESPACIO, ALINEACION_CENTRADO, "[PULSA ESPACIO]");
        END
        parpadeo++;

        FRAME; // Siguiente frame
    END
END

//------------------------------------------------------------------------------
// FUNCION: inicio_nivel (MODIFICADA PARA SCROLL)
// DESCRIPCION: Inicializa un nuevo nivel mostrando una cuenta regresiva (3, 2, 1, GO!) y creando los procesos de enemigos y jugador.
//              - Desactiva controles durante la cuenta y los activa al final.
//              - Ahora inicializa el sistema de balas y arranca el proceso_balas
//              - Configura el sistema de scroll vertical
//------------------------------------------------------------------------------
FUNCTION inicio_nivel();
PRIVATE
    INT contador;   // Cuenta regresiva: 3, 2, 1, GO!
    INT tiempo;     // Contador de frames
    STRING contador_str;// String para mostrar contador
    STRING ruta_musica = "";
BEGIN
    // Limpiar procesos residuales del nivel anterior para evitar IDs invalidos
    signal(type jugador, s_kill);
    signal(type proceso_balas_jugador, s_kill);  // Matar procesos de balas del jugador anteriores
    signal(type proceso_balas_enemigo, s_kill);  // Matar procesos de balas enemigas anteriores
    // No matar explosiones para que se vean durante la cuenta regresiva

    // Limpiar dibujos, textos y procesos residuales del nivel anterior
    delete_draw(all_drawing);
    delete_text(all_text);
    mostrar_textos_hud();   // Volmemos a dibujar los textos del HUD

    // Cargar música del nivel
    SWITCH (nivel_actual)
        CASE 0: ruta_musica = RUTA_WAV_CG001; END
        CASE 1: ruta_musica = RUTA_WAV_LEVEL02; END
        CASE 2: ruta_musica = RUTA_WAV_LEVEL03; END
        CASE 3: ruta_musica = RUTA_WAV_LEVEL04; END
        CASE 6: ruta_musica = RUTA_WAV_LEVEL7; END
        CASE 7: ruta_musica = RUTA_WAV_LEVEL08; END
        CASE 8: ruta_musica = RUTA_WAV_LEVEL08; END
        CASE 9: ruta_musica = RUTA_WAV_LEVEL10; END
        CASE 10: ruta_musica = RUTA_WAV_LEVEL10; END
        CASE 11: ruta_musica = RUTA_WAV_LEVEL12; END
        CASE 12: ruta_musica = RUTA_WAV_LEVEL13; END
    END

    IF (ruta_musica != "")
        cargar_y_reproducir_wav(ruta_musica, LOOP_SI);
    END

    // Inicializar el sistema de balas
    inicializar_balas_jugador();
    inicializar_balas_enemigo();

    // CONFIGURAR SCROLL VERTICAL
    // Inicializar el sistema de scroll
    // El scroll cubre toda la pantalla (region 0)
    // El mapa tiene 1536px de altura, empezamos desde abajo
    // Numero de scroll (0-9)
    // FPG del mapa
    // Grafico del mapa
    // Grafico de fondo
    // Region (0=pantalla completa)
    // Flags (1=LOCK_SCROLL, scroll bloqueado, se mueve manualmente)
    start_scroll(0, FPG_LEVEL, 1, 0, 0, 1);

    // Posicionar el scroll en la parte inferior del mapa
    scroll.y0 = ALTO_MAPA - ALTO_PANTALLA;  // Empezar desde abajo (1536 - 200 = 1336)
    scroll.x0 = 0;                           // Centrado horizontalmente
    scroll_y_objetivo = scroll.y0;           // Objetivo inicial = posicion actual

    // Desactivamos controles durante la cuenta regresiva
    controles_activos = 0;

    // Reiniciar vidas del jugador solo en el primer nivel (despues de game over)
    // En niveles posteriores mantenemos las vidas
    // La variable vidas_jugador ya se resetea en el bucle principal tras game over

    // Actualizar FPG del jugador segun vidas actuales
    // (importante para mantener el estado visual correcto entre niveles)
    vidas_jugador = 3;
    FPG_PLAYER = load_fpg(RUTA_FPG_PLAYER);  // Recargar por si acaso

    // Creamos naves pero sin movimiento
    crear_enemigos();  // Creamos enemigos
    // Crear jugador solo si no existe
    IF (get_id(type jugador) == 0)
        jugador();  // Crear jugador
    ELSE
        // Si ya existe, actualizar su FPG segun vidas
        get_id(type jugador).file = FPG_PLAYER;
    END
    // OPTIMIZACION: Dos procesos separados para balas del jugador y enemigas
    proceso_balas_jugador();  // Proceso dedicado a balas del jugador
    proceso_balas_enemigo();   // Proceso dedicado a balas enemigas

    // Resetear posicion del jugador para el nuevo nivel

    // Esperar un momento para que se vean las naves
    FRAME;
    FRAME;

    // Cuenta regresiva 3, 2, 1, GO!
    contador = 3;   // Cuenta regresiva: 3, 2, 1, GO!
    tiempo = 0;     // Contador de frames
    WHILE (contador > 0)
        contador_str = itoa(contador);        // Convertimos el numero a string (itoi = integer to ascii)
        write(FNT_COUNTER, CENTRO_X, CENTRO_Y, ALINEACION_CENTRADO, contador_str);  // 4 = centrado

        tiempo++;
        IF (tiempo >= FPS_JUEGO)
            // Ha pasado un segundo, actualizamos la cuenta atras
            contador--;
            tiempo = 0;
            delete_text(all_text);  // Limpiamos todos los textos
            mostrar_textos_hud();   // Volmemos a dibujar los textos del HUD
        END

        FRAME; // Siguiente frame
    END

    // Mostramos el GO!
    write(FNT_COUNTER, CENTRO_X, CENTRO_Y, ALINEACION_CENTRADO, "GO!"); // 4 = centrado
    tiempo = 0;
    WHILE (tiempo < FPS_JUEGO / 2)
        FRAME;
        tiempo++;
    END  // Mostramos GO! por 0,5 segundos

    delete_text(all_text);  // Limpiamos todos los textos
    mostrar_textos_hud();   // Volmemos a dibujar los textos del HUD
    controles_activos = 1;  // Activar controles para empezar el juego
END

//------------------------------------------------------------------------------
// FUNCION: cargar_top_scores
// DESCRIPCION: Carga las 10 mejores puntuaciones desde el archivo TOP.DAT
//              Si el archivo no existe, inicializa con valores por defecto
//              (1000, 900, 800, 700, 600, 500, 400, 300, 200, 100)
//------------------------------------------------------------------------------
FUNCTION cargar_top_scores();
PRIVATE
    INT file_handle;
    INT data_size;
    INT i;
BEGIN
    // Intentar abrir el archivo para lectura
    file_handle = fopen("TOP.DAT", "r");

    IF (file_handle == 0)
        // El archivo no existe, inicializar con valores por defecto
        FROM i = 0 TO 9;
            top_scores[i].score = 1000 - (i * 100);
        END
        RETURN;
    END

    // Leer la estructura completa de puntuaciones
    data_size = sizeof(top_scores);
    fread(OFFSET top_scores, data_size, file_handle);

    // Cerrar el archivo
    fclose(file_handle);
END

//------------------------------------------------------------------------------
// FUNCION: guardar_top_scores
// DESCRIPCION: Guarda las 10 mejores puntuaciones en el archivo TOP.DAT
//------------------------------------------------------------------------------
FUNCTION guardar_top_scores();
PRIVATE
    INT file_handle;
    INT data_size;
BEGIN
    // Abrir el archivo para escritura (crea o sobrescribe)
    file_handle = fopen("TOP.DAT", "w");

    IF (file_handle == 0)
        // Error al crear el archivo
        RETURN;
    END

    // Escribir la estructura completa de puntuaciones
    data_size = sizeof(top_scores);
    fwrite(OFFSET top_scores, data_size, file_handle);

    // Cerrar el archivo
    fclose(file_handle);
END

//------------------------------------------------------------------------------
// FUNCION: actualizar_top_scores
// DESCRIPCION: Actualiza el ranking de puntuaciones con una nueva puntuacion
//              Inserta la puntuacion en la posicion correcta si esta entre las 10 mejores
// PARAMETROS:
//   nueva_puntuacion - La puntuacion a comparar con el top 10
//------------------------------------------------------------------------------
FUNCTION actualizar_top_scores(INT nueva_puntuacion);
PRIVATE
    INT i;
    INT j;
    INT posicion_insercion;
BEGIN
    posicion_insercion = -1;

    // Buscar la posicion donde insertar la nueva puntuacion
    FROM i = 0 TO 9;
        IF (nueva_puntuacion > top_scores[i].score)
            posicion_insercion = i;
            BREAK;
        END
    END

    // Si la puntuacion esta en el top 10, insertarla
    IF (posicion_insercion != -1)
        // Desplazar las puntuaciones inferiores hacia abajo (de abajo hacia arriba)
        FOR (j=9; j>posicion_insercion; j--)
            top_scores[j].score = top_scores[j-1].score;
        END

        // Insertar la nueva puntuacion
        top_scores[posicion_insercion].score = nueva_puntuacion;
    END
END

//------------------------------------------------------------------------------
// FUNCION: mostrar_top_scores
// DESCRIPCION: Muestra las 10 mejores puntuaciones en la parte superior izquierda
//              de la pantalla del menu principal
//------------------------------------------------------------------------------
FUNCTION mostrar_top_scores();
PRIVATE
    INT i;
    INT pos_y;
    STRUCT ranking_lines[10]
        STRING line;
    END
BEGIN
    // Titulo del ranking
    write(0, ANCHO_PANTALLA - 10, 10, 5, "RANKING:");  // 5 = alineacion izquierda

    // Preparar las 10 lineas del ranking
    FOR (i=0; i<10; i++)
        ranking_lines[i].line = itoa(i + 1) + ". " + itoa(top_scores[i].score);
    END

    // Mostrar cada puntuacion
    FOR (i=0; i<10; i++)
        pos_y = 20 + (i * 10);  // Espaciado de 10 pixels entre lineas
        write(0, ANCHO_PANTALLA - 10, pos_y, 5, ranking_lines[i].line);  // 5 = alineacion izquierda
    END
END

//------------------------------------------------------------------------------
// FUNCION: confirmar_salida
// DESCRIPCION: Muestra un menu de confirmacion al pulsar ESC con tres opciones:
//              - Continuar partida
//              - Volver al menu principal
//              - Salir al DOS
//              Navegacion con cursores arriba/abajo, seleccion con espacio o intro
//------------------------------------------------------------------------------
FUNCTION confirmar_salida();
PRIVATE
    INT opcion_seleccionada = 0;  // Opcion seleccionada (0=Continuar, 1=Menu, 2=DOS)
    INT tecla_pulsada = 0;        // Flag para controlar cambios de opcion
    INT id_titulo;                // ID del texto del titulo
    INT id_opcion1;               // ID del texto opcion 1
    INT id_opcion2;               // ID del texto opcion 2
    INT id_opcion3;               // ID del texto opcion 3
    INT pos_y_base;               // Posicion Y base para opciones
BEGIN
    // Pausar el juego
    juego_pausado = 1;

    // Esperar a que se suelte ESC
    WHILE (key(_ESC))
        FRAME;
    END

    // Posicion base para el menu centrado
    pos_y_base = CENTRO_Y - 20;

    // Mostrar mensaje de confirmacion
    id_titulo = write(FNT_NORMAL, CENTRO_X, pos_y_base, ALINEACION_CENTRADO, "DESEAS ABANDONAR LA PARTIDA?");

    // Bucle del menu de confirmacion
    LOOP
        // Borrar textos de opciones previos
        delete_text(id_opcion1);
        delete_text(id_opcion2);
        delete_text(id_opcion3);

        // Mostrar opciones con indicador en la seleccionada
        IF (opcion_seleccionada == 0)
            id_opcion1 = write(FNT_PRESS, CENTRO_X, pos_y_base + 30, ALINEACION_CENTRADO, "> CONTINUAR <");
            id_opcion2 = write(FNT_NORMAL, CENTRO_X, pos_y_base + 50, ALINEACION_CENTRADO, "VOLVER AL MENU");
            id_opcion3 = write(FNT_NORMAL, CENTRO_X, pos_y_base + 70, ALINEACION_CENTRADO, "SALIR AL DOS");
        ELSE
            IF (opcion_seleccionada == 1)
                id_opcion1 = write(FNT_NORMAL, CENTRO_X, pos_y_base + 30, ALINEACION_CENTRADO, "CONTINUAR");
                id_opcion2 = write(FNT_PRESS, CENTRO_X, pos_y_base + 50, ALINEACION_CENTRADO, "> VOLVER AL MENU <");
                id_opcion3 = write(FNT_NORMAL, CENTRO_X, pos_y_base + 70, ALINEACION_CENTRADO, "SALIR AL DOS");
            ELSE
                id_opcion1 = write(FNT_NORMAL, CENTRO_X, pos_y_base + 30, ALINEACION_CENTRADO, "CONTINUAR");
                id_opcion2 = write(FNT_NORMAL, CENTRO_X, pos_y_base + 50, ALINEACION_CENTRADO, "VOLVER AL MENU");
                id_opcion3 = write(FNT_PRESS, CENTRO_X, pos_y_base + 70, ALINEACION_CENTRADO, "> SALIR AL DOS <");
            END
        END

        // Navegacion con cursores
        IF (key(_up) AND tecla_pulsada == 0)
            opcion_seleccionada--;
            IF (opcion_seleccionada < 0)
                opcion_seleccionada = 2;  // Ciclar al final
            END
            tecla_pulsada = 1;
        END

        IF (key(_down) AND tecla_pulsada == 0)
            opcion_seleccionada++;
            IF (opcion_seleccionada > 2)
                opcion_seleccionada = 0;  // Ciclar al inicio
            END
            tecla_pulsada = 1;
        END

        // Resetear flag cuando se sueltan las teclas
        IF (NOT key(_up) AND NOT key(_down))
            tecla_pulsada = 0;
        END

        // Seleccion con espacio o intro
        IF (key(_space) OR key(_enter))
            // Esperar a que se suelte la tecla
            WHILE (key(_space) OR key(_enter))
                FRAME;
            END

            // Borrar textos del menu
            delete_text(id_titulo);
            delete_text(id_opcion1);
            delete_text(id_opcion2);
            delete_text(id_opcion3);

            // Ejecutar accion segun opcion
            IF (opcion_seleccionada == 0)
                // Continuar jugando
                juego_pausado = 0;
                RETURN;
            ELSE
                IF (opcion_seleccionada == 1)
                    // Volver al menu principal
                    // Actualizar y guardar puntuaciones
                    actualizar_top_scores(puntos);
                    guardar_top_scores();
                    // Activar flag para salir del bucle principal y volver al menu
                    volver_menu = 1;
                    juego_pausado = 0;
                    RETURN; // El bucle principal gestionará el menú
                ELSE
                    // Salir al DOS
                    actualizar_top_scores(puntos);
                    guardar_top_scores();
                    exit(TEXTO_SALIDA, 0);
                END
            END
        END

        FRAME;
    END
END

// PROCESS: enter_grafico
// DESCRIPCION: Muestra el grafico 5 del FPG de la cinematica parpadeando como indicador de [ENTER]
//------------------------------------------------------------------------------
PROCESS enter_grafico(INT fpg, INT pos_x, INT pos_y);
PRIVATE
    INT timer_parpadeo = 0;
BEGIN
    file = fpg;
    graph = 5;
    x = pos_x;
    y = pos_y;
    LOOP
        IF ((timer_parpadeo MOD 60) < 30)
            flags = 4; // visible
        ELSE
            flags = 0; // transparente
        END
        timer_parpadeo++;
        FRAME;
    END
END

//------------------------------------------------------------------------------
// FUNCION: manejar_resultado_menu
// DESCRIPCION: Maneja el resultado del menu de pausa en cinematicas
//              Setea los flags apropiados según la opción
// PARAMETROS:
//   - resultado: Resultado del menu (0=continuar, 1=saltar, 2=menu, 3=salir)
//   - id_marco: ID del proceso del marco de dialogo
//   - siguiente_nivel: Nivel siguiente para preparar transicion
//------------------------------------------------------------------------------
FUNCTION manejar_resultado_menu(INT resultado, INT id_marco, INT siguiente_nivel)
BEGIN
    volver_menu = 0;
    salir_juego = 0;
    SWITCH(resultado)
        CASE 1:
            // Saltar cinematica
            signal(id_marco, s_kill);
            preparar_transicion_nivel(siguiente_nivel);
            saltar_cinematica = 1;
        END
        CASE 2:
            // Volver al menu principal
            volver_menu = 1;
        END
        CASE 3:
            // Salir al DOS
            salir_juego = 1;
        END
    END
    RETURN(resultado);
END

//------------------------------------------------------------------------------
// FUNCION: preparar_transicion_nivel
// DESCRIPCION: Prepara la transicion visual al siguiente nivel
//------------------------------------------------------------------------------
FUNCTION preparar_transicion_nivel(INT siguiente_nivel);
BEGIN
    // Fundido a negro
    fade_to_black();
    clear_screen();
    load_pal(RUTA_PALETA);
    fade_from_black();
    mostrar_textos_hud();
END

//------------------------------------------------------------------------------
// PROCESS: menu_pausa_cinematica
// DESCRIPCION: Muestra un menu de pausa durante las cinematicas al pulsar ESC
//              Setea resultado_menu_global: 0=Continuar, 1=Saltar, 2=Menu Principal, 3=Salir al DOS
//------------------------------------------------------------------------------
PROCESS menu_pausa_cinematica();
PRIVATE
    INT opcion = 0;                 // Opcion seleccionada (0=CONTINUAR, 1=SALTAR, 2=MENU, 3=SALIR)
    INT y_opcion;                   // Posicion Y de cada opcion
    INT i;                          // Contador
    INT id_textos[4];               // IDs de los textos de las opciones
    INT id_draw;                    // ID del dibujo del marco
BEGIN
    resultado_menu_global = -1;     // Resetear resultado

    // Esperar a que se suelte ESC
    WHILE (key(_ESC))
        FRAME;
    END

    // Dibujar marco del menu (rectangulo relleno)
    id_draw = draw(3, 15, 15, 0, CENTRO_X - MENU_CG_ANCHO/2, CENTRO_Y - MENU_CG_ALTO/2, CENTRO_X + MENU_CG_ANCHO/2, CENTRO_Y + MENU_CG_ALTO/2);

    // Calcular posicion Y inicial para centrar opciones
    y_opcion = CENTRO_Y - (MENU_CG_OPCIONES * MENU_CG_ESPACIADO) / 2 + 5;

    // Bucle principal del menu
    LOOP
        // Borrar textos previos
        FROM i = 0 TO 3;
            IF (id_textos[i] != 0)
                delete_text(id_textos[i]);
                id_textos[i] = 0;
            END
        END

        // Mostrar opciones (resaltar la seleccionada con >)
        IF (opcion == 0)
            id_textos[0] = write(0, CENTRO_X, y_opcion, ALINEACION_CENTRADO, "> CONTINUAR <");
        ELSE
            id_textos[0] = write(0, CENTRO_X, y_opcion, ALINEACION_CENTRADO, "  CONTINUAR  ");
        END

        IF (opcion == 1)
            id_textos[1] = write(0, CENTRO_X, y_opcion + MENU_CG_ESPACIADO, ALINEACION_CENTRADO, "> SALTAR <");
        ELSE
            id_textos[1] = write(0, CENTRO_X, y_opcion + MENU_CG_ESPACIADO, ALINEACION_CENTRADO, "  SALTAR  ");
        END

        IF (opcion == 2)
            id_textos[2] = write(0, CENTRO_X, y_opcion + MENU_CG_ESPACIADO*2, ALINEACION_CENTRADO, "> MENU PRINCIPAL <");
        ELSE
            id_textos[2] = write(0, CENTRO_X, y_opcion + MENU_CG_ESPACIADO*2, ALINEACION_CENTRADO, "  MENU PRINCIPAL  ");
        END

        IF (opcion == 3)
            id_textos[3] = write(0, CENTRO_X, y_opcion + MENU_CG_ESPACIADO*3, ALINEACION_CENTRADO, "> SALIR <");
        ELSE
            id_textos[3] = write(0, CENTRO_X, y_opcion + MENU_CG_ESPACIADO*3, ALINEACION_CENTRADO, "  SALIR  ");
        END

        // Navegacion con flechas
        IF (key(_up))
            opcion--;
            IF (opcion < 0)
                opcion = MENU_CG_OPCIONES - 1;
            END
            // Esperar a que se suelte la tecla
            WHILE (key(_up))
                FRAME;
            END
        END

        IF (key(_down))
            opcion++;
            IF (opcion >= MENU_CG_OPCIONES)
                opcion = 0;
            END
            // Esperar a que se suelte la tecla
            WHILE (key(_down))
                FRAME;
            END
        END

        // Seleccionar con espacio o enter
        IF (key(_space) OR key(_enter))
            // Esperar a que se suelte la tecla
            WHILE (key(_space) OR key(_enter))
                FRAME;
            END
            BREAK;
        END

        // ESC para continuar (equivale a opcion 0)
        IF (key(_ESC))
            opcion = 0;
            WHILE (key(_ESC))
                FRAME;
            END
            BREAK;
        END

        FRAME;
    END

    // Limpiar textos y rectangulo del menu
    FROM i = 0 TO 3;
        IF (id_textos[i] != 0)
            delete_text(id_textos[i]);
        END
    END
    IF (id_draw != 0)
        delete_draw(id_draw);
    END

    // Verificar si se pulsa espacio o enter
    WHILE (key(_space) OR key(_enter) OR key(_ESC))
        FRAME;
    END

    resultado_menu_global = opcion; // Setear resultado global
END

//------------------------------------------------------------------------------
// FUNCION: init_cinematics
// DESCRIPCION: Inicializa los datos de todas las cinematicas
//------------------------------------------------------------------------------
FUNCTION init_cinematics()
BEGIN
    // Cinematica 0: nivel_1_inicio
    cinematics[0].num_cg = 2;
    cinematics[0].siguiente_nivel = 1;

    // CG 0
    cinematics[0].cgs[0].fpg_ruta = RUTA_FPG_CG001;
    cinematics[0].cgs[0].pal_ruta = RUTA_FPG_CG001;
    cinematics[0].cgs[0].wav_ruta = RUTA_WAV_CG001;
    cinematics[0].cgs[0].num_paginas = 3;
    cinematics[0].cgs[0].paginas[0].linea1 = "Borde Norte, 1923";
    cinematics[0].cgs[0].paginas[0].linea2 = "Academia Militar Imperial";
    cinematics[0].cgs[0].paginas[0].linea3 = "";
    cinematics[0].cgs[0].paginas[0].linea4 = "";
    cinematics[0].cgs[0].paginas[1].linea1 = "Prueba final de graduación";
    cinematics[0].cgs[0].paginas[1].linea2 = "";
    cinematics[0].cgs[0].paginas[1].linea3 = "";
    cinematics[0].cgs[0].paginas[1].linea4 = "";
    cinematics[0].cgs[0].paginas[2].linea1 = "Tanya: La prueba de despliegue aéreo.";
    cinematics[0].cgs[0].paginas[2].linea2 = "Sólo debería completarla...";
    cinematics[0].cgs[0].paginas[2].linea3 = "para graduarme sin problemas.";
    cinematics[0].cgs[0].paginas[2].linea4 = "Me espera una vida feliz en la retaguardia.";
    // CG 1
    cinematics[0].cgs[1].fpg_ruta = RUTA_FPG_CG002;
    cinematics[0].cgs[1].pal_ruta = RUTA_FPG_CG002;
    cinematics[0].cgs[1].wav_ruta = RUTA_WAV_CG002;
    cinematics[0].cgs[1].num_paginas = 6;
    cinematics[0].cgs[1].paginas[0].linea1 = "Operador: Contacto enemigo no autorizado.";
    cinematics[0].cgs[1].paginas[0].linea2 = "Magos de la Alianza Entente Legadonia cruzando";
    cinematics[0].cgs[1].paginas[0].linea3 = "la frontera norte.";
    cinematics[0].cgs[1].paginas[0].linea4 = "";
    cinematics[0].cgs[1].paginas[1].linea1 = "Tanya: ¿Qué demonios?";
    cinematics[0].cgs[1].paginas[1].linea2 = "Esto no es parte de la prueba.";
    cinematics[0].cgs[1].paginas[1].linea3 = "";
    cinematics[0].cgs[1].paginas[1].linea4 = "";
    cinematics[0].cgs[1].paginas[2].linea1 = "Operador: Cadete, mantenga posición.";
    cinematics[0].cgs[1].paginas[2].linea2 = "Esto es una orden directa del Estado Mayor.";
    cinematics[0].cgs[1].paginas[2].linea3 = "";
    cinematics[0].cgs[1].paginas[2].linea4 = "";
    cinematics[0].cgs[1].paginas[3].linea1 = "Tanya: ¿Del Estado Mayor?";
    cinematics[0].cgs[1].paginas[3].linea2 = "Esto es ridículo...";
    cinematics[0].cgs[1].paginas[3].linea3 = "Si soy sólo una cadete.";
    cinematics[0].cgs[1].paginas[3].linea4 = "Solicito que reconsideren la petición.";
    cinematics[0].cgs[1].paginas[4].linea1 = "Operador: Petición denegada.";
    cinematics[0].cgs[1].paginas[4].linea2 = "Neutralice la amenaza y regrese a base.";
    cinematics[0].cgs[1].paginas[4].linea3 = "";
    cinematics[0].cgs[1].paginas[4].linea4 = "";
    cinematics[0].cgs[1].paginas[5].linea1 = "Tanya: Entendido...";
    cinematics[0].cgs[1].paginas[5].linea2 = "Pero que conste que esto";
    cinematics[0].cgs[1].paginas[5].linea3 = "arruina mi graduación perfecta.";
    cinematics[0].cgs[1].paginas[5].linea4 = "";

    // Cinematica 1: nivel_1_final
    cinematics[1].num_cg = 3;
    cinematics[1].siguiente_nivel = 2;

    // CG 0
    cinematics[1].cgs[0].fpg_ruta = RUTA_FPG_CG003;
    cinematics[1].cgs[0].pal_ruta = RUTA_FPG_CG003;
    cinematics[1].cgs[0].wav_ruta = RUTA_WAV_CG002;
    cinematics[1].cgs[0].num_paginas = 4;
    cinematics[1].cgs[0].paginas[0].linea1 = "Superior: Cadete Tanya.";
    cinematics[1].cgs[0].paginas[0].linea2 = "Por méritos extraordinarios en combate real";
    cinematics[1].cgs[0].paginas[0].linea3 = "y demostración de capacidad excepcional...";
    cinematics[1].cgs[0].paginas[0].linea4 = "";
    cinematics[1].cgs[0].paginas[1].linea1 = "Superior: Se le concede el título de";
    cinematics[1].cgs[0].paginas[1].linea2 = "Alas de Plata de Asalto.";
    cinematics[1].cgs[0].paginas[1].linea3 = "Además es promocionada a teniente.";
    cinematics[1].cgs[0].paginas[1].linea4 = "Felicitaciones, teniente.";
    cinematics[1].cgs[0].paginas[2].linea1 = "Tanya: ¿Teniente? ¿Ya?";
    cinematics[1].cgs[0].paginas[2].linea2 = "Esto complicará mi plan de vivir en retaguardia.";
    cinematics[1].cgs[0].paginas[2].linea3 = "Pero bueno, acepto el ascenso.";
    cinematics[1].cgs[0].paginas[2].linea4 = "";
    cinematics[1].cgs[0].paginas[3].linea1 = "Tanya: Las Alas de Plata...";
    cinematics[1].cgs[0].paginas[3].linea2 = "Suena impresionante.";
    cinematics[1].cgs[0].paginas[3].linea3 = "Ahora tendré que lidiar con";
    cinematics[1].cgs[0].paginas[3].linea4 = "más burocracia y propaganda.";
    // CG 1
    cinematics[1].cgs[1].fpg_ruta = RUTA_FPG_CG004;
    cinematics[1].cgs[1].pal_ruta = RUTA_FPG_CG004;
    cinematics[1].cgs[1].wav_ruta = RUTA_WAV_CG002;
    cinematics[1].cgs[1].num_paginas = 5;
    cinematics[1].cgs[1].paginas[0].linea1 = "Sin quererlo me volví famosa y";
    cinematics[1].cgs[1].paginas[0].linea2 = "me obligaron a grabar cortos";
    cinematics[1].cgs[1].paginas[0].linea3 = "para animar a las tropas.";
    cinematics[1].cgs[1].paginas[0].linea4 = "";
    cinematics[1].cgs[1].paginas[1].linea1 = "Operador: Sonría, por favor.";
    cinematics[1].cgs[1].paginas[1].linea2 = "";
    cinematics[1].cgs[1].paginas[1].linea3 = "";
    cinematics[1].cgs[1].paginas[1].linea4 = "";
    cinematics[1].cgs[1].paginas[2].linea1 = "Con todo respeto, señor.";
    cinematics[1].cgs[1].paginas[2].linea2 = "Prefiero que me disparen.";
    cinematics[1].cgs[1].paginas[2].linea3 = "";
    cinematics[1].cgs[1].paginas[2].linea4 = "";
    cinematics[1].cgs[1].paginas[3].linea1 = "Operador: 3, 2, 1... ¡Grabando!";
    cinematics[1].cgs[1].paginas[3].linea2 = "";
    cinematics[1].cgs[1].paginas[3].linea3 = "";
    cinematics[1].cgs[1].paginas[3].linea4 = "";
    cinematics[1].cgs[1].paginas[4].linea1 = "Tanya: Soy Tanya";
    cinematics[1].cgs[1].paginas[4].linea2 = "¡Alas de Plata!";
    cinematics[1].cgs[1].paginas[4].linea3 = "";
    cinematics[1].cgs[1].paginas[4].linea4 = "";
    // CG 2
    cinematics[1].cgs[2].fpg_ruta = RUTA_FPG_CG005;
    cinematics[1].cgs[2].pal_ruta = RUTA_FPG_CG005;
    cinematics[1].cgs[2].wav_ruta = RUTA_WAV_CG002;
    cinematics[1].cgs[2].num_paginas = 5;
    cinematics[1].cgs[2].paginas[0].linea1 = "A pesar de las promociones,";
    cinematics[1].cgs[2].paginas[0].linea2 = "y los experimentos con la joya tipo 95,";
    cinematics[1].cgs[2].paginas[0].linea3 = "Tanya fue enviada al frente del Rin.";
    cinematics[1].cgs[2].paginas[0].linea4 = "";
    cinematics[1].cgs[2].paginas[1].linea1 = "Tanya: Fue un periodo intenso,";
    cinematics[1].cgs[2].paginas[1].linea2 = "pero la joya tipo 95 me otorga poderes";
    cinematics[1].cgs[2].paginas[1].linea3 = "que me protegen en combate.";
    cinematics[1].cgs[2].paginas[1].linea4 = "";
    cinematics[1].cgs[2].paginas[2].linea1 = "El frente del Rin es conocido";
    cinematics[1].cgs[2].paginas[2].linea2 = "por ser uno de los más sangrientos";
    cinematics[1].cgs[2].paginas[2].linea3 = "de toda la guerra.";
    cinematics[1].cgs[2].paginas[2].linea4 = "";
    cinematics[1].cgs[2].paginas[3].linea1 = "Tanya: Esto es ridículo.";
    cinematics[1].cgs[2].paginas[3].linea2 = "¿Por qué me mandan aquí?";
    cinematics[1].cgs[2].paginas[3].linea3 = "Quería evitar el peligro real.";
    cinematics[1].cgs[2].paginas[3].linea4 = "";
    cinematics[1].cgs[2].paginas[4].linea1 = "Tanya: Con mi magia y estrategia,";
    cinematics[1].cgs[2].paginas[4].linea2 = "podría ser más útil en retaguardia.";
    cinematics[1].cgs[2].paginas[4].linea3 = "Pero órdenes son órdenes...";
    cinematics[1].cgs[2].paginas[4].linea4 = "";

    // Cinematica 2: nivel_2_final
    cinematics[2].num_cg = 2;
    cinematics[2].siguiente_nivel = 3;

    // CG 0
    cinematics[2].cgs[0].fpg_ruta = RUTA_FPG_CG006;
    cinematics[2].cgs[0].pal_ruta = RUTA_FPG_CG006;
    cinematics[2].cgs[0].wav_ruta = RUTA_WAV_CG003;
    cinematics[2].cgs[0].num_paginas = 3;
    cinematics[2].cgs[0].paginas[0].linea1 = "Durante los seis meses que Tanya";
    cinematics[2].cgs[0].paginas[0].linea2 = "estuvo en el frente,";
    cinematics[2].cgs[0].paginas[0].linea3 = "se ganó el sobrenombre de";
    cinematics[2].cgs[0].paginas[0].linea4 = "'Demonio del Rin' entre sus enemigos.";
    cinematics[2].cgs[0].paginas[1].linea1 = "Entre muertes y heridos,";
    cinematics[2].cgs[0].paginas[1].linea2 = "logró derribar a 92 magos enemigos.";
    cinematics[2].cgs[0].paginas[1].linea3 = "Todo un récord digno de elogio.";
    cinematics[2].cgs[0].paginas[1].linea4 = "";
    cinematics[2].cgs[0].paginas[2].linea1 = "Tanya: Mi reputación crece,";
    cinematics[2].cgs[0].paginas[2].linea2 = "pero el peligro también.";
    cinematics[2].cgs[0].paginas[2].linea3 = "Esto no era parte del plan.";
    cinematics[2].cgs[0].paginas[2].linea4 = "¡Quiero vivir tranquila en retaguardia!";
    // CG 1
    cinematics[2].cgs[1].fpg_ruta = RUTA_FPG_CG007;
    cinematics[2].cgs[1].pal_ruta = RUTA_FPG_CG007;
    cinematics[2].cgs[1].wav_ruta = RUTA_WAV_CG003;
    cinematics[2].cgs[1].num_paginas = 6;
    cinematics[2].cgs[1].paginas[0].linea1 = "Tras su periodo de seis meses,";
    cinematics[2].cgs[1].paginas[0].linea2 = "Tanya recibe un ascenso";
    cinematics[2].cgs[1].paginas[0].linea3 = "y es enviada a la Academia de Guerra";
    cinematics[2].cgs[1].paginas[0].linea4 = "para estudios avanzados.";
    cinematics[2].cgs[1].paginas[1].linea1 = "Pasado medio año se gradúa";
    cinematics[2].cgs[1].paginas[1].linea2 = "y recibe uno de los mayores honores:";
    cinematics[2].cgs[1].paginas[1].linea3 = "Es nombrada como una de";
    cinematics[2].cgs[1].paginas[1].linea4 = "los Doce Caballeros.";
    cinematics[2].cgs[1].paginas[2].linea1 = "Se le propone crear el Batallón 203";
    cinematics[2].cgs[1].paginas[2].linea2 = "de Magos de Guerra,";
    cinematics[2].cgs[1].paginas[2].linea3 = "compuesto por magos";
    cinematics[2].cgs[1].paginas[2].linea4 = "seleccionados por ella misma.";
    cinematics[2].cgs[1].paginas[3].linea1 = "Su primera misión: Parar la invasión";
    cinematics[2].cgs[1].paginas[3].linea2 = "del Ducado de Dacia en el frente este.";
    cinematics[2].cgs[1].paginas[3].linea3 = "Una pequeña nación";
    cinematics[2].cgs[1].paginas[3].linea4 = "que ha decidido invadir al imperio.";
    cinematics[2].cgs[1].paginas[4].linea1 = "El batallón 203 consigue repeler";
    cinematics[2].cgs[1].paginas[4].linea2 = "la invasión en apenas unas horas";
    cinematics[2].cgs[1].paginas[4].linea3 = "y sin bajas,";
    cinematics[2].cgs[1].paginas[4].linea4 = "demostrando su efectividad.";
    cinematics[2].cgs[1].paginas[5].linea1 = "Tanya: Hay que arrancar";
    cinematics[2].cgs[1].paginas[5].linea2 = "el problema de raíz.";
    cinematics[2].cgs[1].paginas[5].linea3 = "Vayamos a la capital de Dacia,";
    cinematics[2].cgs[1].paginas[5].linea4 = "a ver qué están tramando.";

    // Cinematica 3: nivel_3_final
    cinematics[3].num_cg = 4;
    cinematics[3].siguiente_nivel = 4;

    // CG 0
    cinematics[3].cgs[0].fpg_ruta = RUTA_FPG_CG008;
    cinematics[3].cgs[0].pal_ruta = RUTA_FPG_CG008;
    cinematics[3].cgs[0].wav_ruta = RUTA_WAV_CG004;
    cinematics[3].cgs[0].num_paginas = 3;
    cinematics[3].cgs[0].paginas[0].linea1 = "El Batallón 203 de Tanya llega";
    cinematics[3].cgs[0].paginas[0].linea2 = "a la capital de Dacia sin problemas.";
    cinematics[3].cgs[0].paginas[0].linea3 = "El ejército enemigo no está";
    cinematics[3].cgs[0].paginas[0].linea4 = "a la altura.";
    cinematics[3].cgs[0].paginas[1].linea1 = "Allí descubren una fábrica de armamento";
    cinematics[3].cgs[0].paginas[1].linea2 = "financiada seguramente por potencias";
    cinematics[3].cgs[0].paginas[1].linea3 = "extranjeras.";
    cinematics[3].cgs[0].paginas[1].linea4 = "";
    cinematics[3].cgs[0].paginas[2].linea1 = "Tanya: Esto explica la invasión.";
    cinematics[3].cgs[0].paginas[2].linea2 = "Una amenaza oculta detrás.";
    cinematics[3].cgs[0].paginas[2].linea3 = "Alguien les está ayudando";
    cinematics[3].cgs[0].paginas[2].linea4 = "a fabricar armas.";
    // CG 1
    cinematics[3].cgs[1].fpg_ruta = RUTA_FPG_CG009;
    cinematics[3].cgs[1].pal_ruta = RUTA_FPG_CG009;
    cinematics[3].cgs[1].wav_ruta = RUTA_WAV_CG004;
    cinematics[3].cgs[1].num_paginas = 5;
    cinematics[3].cgs[1].paginas[0].linea1 = "Tanya decide valerse de artimañas legales";
    cinematics[3].cgs[1].paginas[0].linea2 = "para atacar la fábrica sin violar";
    cinematics[3].cgs[1].paginas[0].linea3 = "el derecho internacional.";
    cinematics[3].cgs[1].paginas[0].linea4 = "";
    cinematics[3].cgs[1].paginas[1].linea1 = "Usando interpretaciones creativas";
    cinematics[3].cgs[1].paginas[1].linea2 = "de tratados y leyes de guerra,";
    cinematics[3].cgs[1].paginas[1].linea3 = "autoriza el ataque.";
    cinematics[3].cgs[1].paginas[1].linea4 = "";
    cinematics[3].cgs[1].paginas[2].linea1 = "Tanya hace uso de su voz de niña";
    cinematics[3].cgs[1].paginas[2].linea2 = "para emitir una advertencia de ataque,";
    cinematics[3].cgs[1].paginas[2].linea3 = "pero el enemigo no se lo toma en serio.";
    cinematics[3].cgs[1].paginas[2].linea4 = "Piensa que se trata de una broma.";
    cinematics[3].cgs[1].paginas[3].linea1 = "Con esto, la crisis de Dacia";
    cinematics[3].cgs[1].paginas[3].linea2 = "queda resuelta.";
    cinematics[3].cgs[1].paginas[3].linea3 = "";
    cinematics[3].cgs[1].paginas[3].linea4 = "";
    cinematics[3].cgs[1].paginas[4].linea1 = "Tanya: La ley es un arma poderosa";
    cinematics[3].cgs[1].paginas[4].linea2 = "cuando se sabe usar.";
    cinematics[3].cgs[1].paginas[4].linea3 = "Será cuestionable,";
    cinematics[3].cgs[1].paginas[4].linea4 = "pero evité riesgos innecesarios.";
    // CG 2
    cinematics[3].cgs[2].fpg_ruta = RUTA_FPG_CG010;
    cinematics[3].cgs[2].pal_ruta = RUTA_FPG_CG010;
    cinematics[3].cgs[2].wav_ruta = RUTA_WAV_CG004;
    cinematics[3].cgs[2].num_paginas = 3;
    cinematics[3].cgs[2].paginas[0].linea1 = "Tras el éxito de la misión en Dacia,";
    cinematics[3].cgs[2].paginas[0].linea2 = "Tanya es convocada por el alto mando";
    cinematics[3].cgs[2].paginas[0].linea3 = "imperial para una reunión urgente.";
    cinematics[3].cgs[2].paginas[0].linea4 = "";
    cinematics[3].cgs[2].paginas[1].linea1 = "Rudersdorf: Excelente trabajo en Dacia,";
    cinematics[3].cgs[2].paginas[1].linea2 = "teniente coronel Degurechaff.";
    cinematics[3].cgs[2].paginas[1].linea3 = "Le mostraremos el siguiente objetivo.";
    cinematics[3].cgs[2].paginas[1].linea4 = "";
    cinematics[3].cgs[2].paginas[2].linea1 = "(Le muestran un mapa del frente norte";
    cinematics[3].cgs[2].paginas[2].linea2 = "con posiciones marcadas en Osfjord)";
    cinematics[3].cgs[2].paginas[2].linea3 = "";
    cinematics[3].cgs[2].paginas[2].linea4 = "";
    // CG 3
    cinematics[3].cgs[3].fpg_ruta = RUTA_FPG_CG011;
    cinematics[3].cgs[3].pal_ruta = RUTA_FPG_CG011;
    cinematics[3].cgs[3].wav_ruta = RUTA_WAV_CG004;
    cinematics[3].cgs[3].num_paginas = 5;
    cinematics[3].cgs[3].paginas[0].linea1 = "La misión asignada al batallón 203:";
    cinematics[3].cgs[3].paginas[0].linea2 = "Desplegarse en el frente norte";
    cinematics[3].cgs[3].paginas[0].linea3 = "para derribar las defensas costeras";
    cinematics[3].cgs[3].paginas[0].linea4 = "de Legadonia en la zona de Osfjord.";
    cinematics[3].cgs[3].paginas[1].linea1 = "El objetivo: Neutralizar artillería costera,";
    cinematics[3].cgs[3].paginas[1].linea2 = "posiciones antiaéreas, defensas";
    cinematics[3].cgs[3].paginas[1].linea3 = "y líneas de suministro";
    cinematics[3].cgs[3].paginas[1].linea4 = "para permitir un desembarco masivo por mar.";
    cinematics[3].cgs[3].paginas[2].linea1 = "Tanya: Un ataque sorpresa nocturno";
    cinematics[3].cgs[3].paginas[2].linea2 = "con magos voladores.";
    cinematics[3].cgs[3].paginas[2].linea3 = "Tenemos apenas media hora";
    cinematics[3].cgs[3].paginas[2].linea4 = "antes de que comience el desembarco.";
    cinematics[3].cgs[3].paginas[3].linea1 = "Tanya: Si fallamos, el desembarco";
    cinematics[3].cgs[3].paginas[3].linea2 = "será un desastre y esto se convertirá";
    cinematics[3].cgs[3].paginas[3].linea3 = "en uno de los mayores ridículos";
    cinematics[3].cgs[3].paginas[3].linea4 = "de la historia de la estrategia militar.";
    cinematics[3].cgs[3].paginas[4].linea1 = "Tanya: Pero si tenemos éxito,";
    cinematics[3].cgs[3].paginas[4].linea2 = "romperemos el estancamiento";
    cinematics[3].cgs[3].paginas[4].linea3 = "y aceleraremos el fin de la guerra.";
    cinematics[3].cgs[3].paginas[4].linea4 = "Por fin podré volver a la retaguardia.";

    // Cinematica 4: nivel_6_final
    cinematics[4].num_cg = 1;
    cinematics[4].siguiente_nivel = 7;

    // CG 0
    cinematics[4].cgs[0].fpg_ruta = RUTA_FPG_CG012;
    cinematics[4].cgs[0].pal_ruta = RUTA_FPG_CG012;
    cinematics[4].cgs[0].wav_ruta = RUTA_WAV_LEVEL7;
    cinematics[4].cgs[0].num_paginas = 6;
    cinematics[4].cgs[0].paginas[0].linea1 = "Tras el éxito de la operación";
    cinematics[4].cgs[0].paginas[0].linea2 = "en el frente norte contra Legadonia,";
    cinematics[4].cgs[0].paginas[0].linea3 = "el batallón 203 es reasignado";
    cinematics[4].cgs[0].paginas[0].linea4 = "rápidamente al frente oeste.";
    cinematics[4].cgs[0].paginas[1].linea1 = "El nuevo objetivo: La ciudad de Arene,";
    cinematics[4].cgs[0].paginas[1].linea2 = "recientemente capturada al antiguo";
    cinematics[4].cgs[0].paginas[1].linea3 = "territorio de la República Francois,";
    cinematics[4].cgs[0].paginas[1].linea4 = "pero ahora en llamas por una rebelión.";
    cinematics[4].cgs[0].paginas[2].linea1 = "Milicianos locales y magos";
    cinematics[4].cgs[0].paginas[2].linea2 = "de la República Francois,";
    cinematics[4].cgs[0].paginas[2].linea3 = "liderados por el Lt. Col. Severin Bientot,";
    cinematics[4].cgs[0].paginas[2].linea4 = "han iniciado una feroz resistencia.";
    cinematics[4].cgs[0].paginas[3].linea1 = "Tanya: Órdenes del Estado Mayor.";
    cinematics[4].cgs[0].paginas[3].linea2 = "Reconquistar la ciudad y eliminar";
    cinematics[4].cgs[0].paginas[3].linea3 = "toda resistencia, incluso si implica";
    cinematics[4].cgs[0].paginas[3].linea4 = "bajas civiles masivas.";
    cinematics[4].cgs[0].paginas[4].linea1 = "Tanya: Usando una interpretación legal";
    cinematics[4].cgs[0].paginas[4].linea2 = "de mi tesis en la Academia Militar,";
    cinematics[4].cgs[0].paginas[4].linea3 = "emitiremos una orden de evacuación.";
    cinematics[4].cgs[0].paginas[4].linea4 = "Cualquiera que permanezca será considerado hostil.";
    cinematics[4].cgs[0].paginas[5].linea1 = "Tanya: Esto permitirá bombardear";
    cinematics[4].cgs[0].paginas[5].linea2 = "la ciudad sin restricciones.";
    cinematics[4].cgs[0].paginas[5].linea3 = "La guerra no perdona.";
    cinematics[4].cgs[0].paginas[5].linea4 = "";

    // Cinematica 5: post-nivel 7
    cinematics[5].num_cg = 2;
    cinematics[5].siguiente_nivel = 8;

    // CG 0 - Tanya disparando
    cinematics[5].cgs[0].fpg_ruta = RUTA_FPG_CG013;
    cinematics[5].cgs[0].pal_ruta = RUTA_FPG_CG013;
    cinematics[5].cgs[0].wav_ruta = RUTA_WAV_CG004;
    cinematics[5].cgs[0].num_paginas = 2;
    cinematics[5].cgs[0].paginas[0].linea1 = "Tras la victoria en Arene,";
    cinematics[5].cgs[0].paginas[0].linea2 = "Tanya cumple la misión sin piedad.";
    cinematics[5].cgs[0].paginas[0].linea3 = "Sus disparos siegan muchas";
    cinematics[5].cgs[0].paginas[0].linea4 = "vidas a sangre fría.";
    cinematics[5].cgs[0].paginas[1].linea1 = "Tanya: Solo cumplo órdenes.";
    cinematics[5].cgs[0].paginas[1].linea2 = "La guerra no deja espacio";
    cinematics[5].cgs[0].paginas[1].linea3 = "para sentimentalismos.";
    cinematics[5].cgs[0].paginas[1].linea4 = "";

    // CG 1 - Zettour dando órdenes
    cinematics[5].cgs[1].fpg_ruta = RUTA_FPG_CG014;
    cinematics[5].cgs[1].pal_ruta = RUTA_FPG_CG014;
    cinematics[5].cgs[1].wav_ruta = RUTA_WAV_CG004;
    cinematics[5].cgs[1].num_paginas = 5;
    cinematics[5].cgs[1].paginas[0].linea1 = "Zettour: Excelente trabajo en Arene,";
    cinematics[5].cgs[1].paginas[0].linea2 = "teniente coronel Degurechaff.";
    cinematics[5].cgs[1].paginas[0].linea3 = "Pero el enemigo mantiene";
    cinematics[5].cgs[1].paginas[0].linea4 = "posiciones fuertes en retaguardia.";
    cinematics[5].cgs[1].paginas[1].linea1 = "Zettour: Realice una incursión inmediata";
    cinematics[5].cgs[1].paginas[1].linea2 = "para destruir sus generadores mágicos";
    cinematics[5].cgs[1].paginas[1].linea3 = "y líneas de suministro.";
    cinematics[5].cgs[1].paginas[1].linea4 = "";
    cinematics[5].cgs[1].paginas[2].linea1 = "Zettour: Esto cortará sus comunicaciones";
    cinematics[5].cgs[1].paginas[2].linea2 = "y evitará contraataques masivos.";
    cinematics[5].cgs[1].paginas[2].linea3 = "Debilitaremos a François";
    cinematics[5].cgs[1].paginas[2].linea4 = "antes del asalto final a Parise.";
    cinematics[5].cgs[1].paginas[3].linea1 = "Tanya: Entendido, general Zettour.";
    cinematics[5].cgs[1].paginas[3].linea2 = "Mis hombres incursionarán,";
    cinematics[5].cgs[1].paginas[3].linea3 = "sabotearán y regresarán";
    cinematics[5].cgs[1].paginas[3].linea4 = "victoriosos como siempre.";
    cinematics[5].cgs[1].paginas[4].linea1 = "La incursión post-Arene";
    cinematics[5].cgs[1].paginas[4].linea2 = "prepara  el avance hacia";
    cinematics[5].cgs[1].paginas[4].linea3 = "la capital enemiga.";
    cinematics[5].cgs[1].paginas[4].linea4 = "";

    // Cinematica 6: post-nivel 8
    cinematics[6].num_cg = 1;
    cinematics[6].siguiente_nivel = 9;

    // CG 0 - Frente del Rin
    cinematics[6].cgs[0].fpg_ruta = RUTA_FPG_CG015;
    cinematics[6].cgs[0].pal_ruta = RUTA_FPG_CG015;
    cinematics[6].cgs[0].wav_ruta = RUTA_WAV_CG004;
    cinematics[6].cgs[0].num_paginas = 4;
    cinematics[6].cgs[0].paginas[0].linea1 = "Con los suministros enemigos mermados por";
    cinematics[6].cgs[0].paginas[0].linea2 = "la incursión en territorio de François,";
    cinematics[6].cgs[0].paginas[0].linea3 = "el Alto Mando Imperial decide";
    cinematics[6].cgs[0].paginas[0].linea4 = "concentrar todas las fuerzas.";
    cinematics[6].cgs[0].paginas[1].linea1 = "El objetivo: el frente del Rin,";
    cinematics[6].cgs[0].paginas[1].linea2 = "el sector más sangriento";
    cinematics[6].cgs[0].paginas[1].linea3 = "y peligroso de toda la guerra.";
    cinematics[6].cgs[0].paginas[1].linea4 = "";
    cinematics[6].cgs[0].paginas[2].linea1 = "Tanya: El frente del Rin...";
    cinematics[6].cgs[0].paginas[2].linea2 = "Allí donde la muerte acecha";
    cinematics[6].cgs[0].paginas[2].linea3 = "en cada esquina del campo de batalla.";
    cinematics[6].cgs[0].paginas[2].linea4 = "Esto es una locura absoluta.";
    cinematics[6].cgs[0].paginas[3].linea1 = "El batallón 203 es trasladado";
    cinematics[6].cgs[0].paginas[3].linea2 = "al corazón del conflicto.";
    cinematics[6].cgs[0].paginas[3].linea3 = "Allí donde nació la leyenda";
    cinematics[6].cgs[0].paginas[3].linea4 = "del 'Demonio del Rin'.";

    // Cinematica 7: post-nivel 9
    cinematics[7].num_cg = 2;
    cinematics[7].siguiente_nivel = 10;

    // CG 0 - Rin destruido
    cinematics[7].cgs[0].fpg_ruta = RUTA_FPG_CG016;
    cinematics[7].cgs[0].pal_ruta = RUTA_FPG_CG016;
    cinematics[7].cgs[0].wav_ruta = RUTA_WAV_CG004;
    cinematics[7].cgs[0].num_paginas = 4;
    cinematics[7].cgs[0].paginas[0].linea1 = "Con el frente del Rin bajo control imperial,";
    cinematics[7].cgs[0].paginas[0].linea2 = "las fuerzas del Imperio han logrado";
    cinematics[7].cgs[0].paginas[0].linea3 = "una victoria decisiva";
    cinematics[7].cgs[0].paginas[0].linea4 = "en el frente más sangriento.";
    cinematics[7].cgs[0].paginas[1].linea1 = "El camino hacia la capital de François";
    cinematics[7].cgs[0].paginas[1].linea2 = "queda ahora despejado.";
    cinematics[7].cgs[0].paginas[1].linea3 = "Sin embargo, el Alto Mando";
    cinematics[7].cgs[0].paginas[1].linea4 = "planea una maniobra envolvente.";
    cinematics[7].cgs[0].paginas[2].linea1 = "Para tomar Parise no basta";
    cinematics[7].cgs[0].paginas[2].linea2 = "con avanzar únicamente por tierra";
    cinematics[7].cgs[0].paginas[2].linea3 = "desde el este.";
    cinematics[7].cgs[0].paginas[2].linea4 = "";
    cinematics[7].cgs[0].paginas[3].linea1 = "Es necesario cortar las líneas";
    cinematics[7].cgs[0].paginas[3].linea2 = "de suministro enemigas";
    cinematics[7].cgs[0].paginas[3].linea3 = "y atacar desde múltiples frentes.";
    cinematics[7].cgs[0].paginas[3].linea4 = "";

    // CG 1 - Tanya dirigiéndose a Brest
    cinematics[7].cgs[1].fpg_ruta = RUTA_FPG_CG017;
    cinematics[7].cgs[1].pal_ruta = RUTA_FPG_CG017;
    cinematics[7].cgs[1].wav_ruta = RUTA_WAV_CG004;
    cinematics[7].cgs[1].num_paginas = 5;
    cinematics[7].cgs[1].paginas[0].linea1 = "El objetivo: el puerto de Brest,";
    cinematics[7].cgs[1].paginas[0].linea2 = "clave en la costa atlántica";
    cinematics[7].cgs[1].paginas[0].linea3 = "de François.";
    cinematics[7].cgs[1].paginas[0].linea4 = "";
    cinematics[7].cgs[1].paginas[1].linea1 = "Capturarlo permitirá";
    cinematics[7].cgs[1].paginas[1].linea2 = "desembarcar tropas del imperio";
    cinematics[7].cgs[1].paginas[1].linea3 = "y suministros directamente";
    cinematics[7].cgs[1].paginas[1].linea4 = "en el oeste enemigo.";
    cinematics[7].cgs[1].paginas[2].linea1 = "Además, cortará las rutas";
    cinematics[7].cgs[1].paginas[2].linea2 = "marítimas de refuerzos";
    cinematics[7].cgs[1].paginas[2].linea3 = "desde el Atlántico,";
    cinematics[7].cgs[1].paginas[2].linea4 = "aislando de la Commonwealth.";
    cinematics[7].cgs[1].paginas[3].linea1 = "Esta amenaza desde el oeste";
    cinematics[7].cgs[1].paginas[3].linea2 = "obligará a François";
    cinematics[7].cgs[1].paginas[3].linea3 = "a dividir sus fuerzas,";
    cinematics[7].cgs[1].paginas[3].linea4 = "debilitando la defensa de Parise.";
    cinematics[7].cgs[1].paginas[4].linea1 = "Tanya: Brest...";
    cinematics[7].cgs[1].paginas[4].linea2 = "Otro puerto estratégico";
    cinematics[7].cgs[1].paginas[4].linea3 = "en esta guerra interminable.";
    cinematics[7].cgs[1].paginas[4].linea4 = "La maniobra envolvente comienza.";

    // Cinematica 8: post-nivel 10
    cinematics[8].num_cg = 2;
    cinematics[8].siguiente_nivel = 12;

    // CG 0 - Operación Shock and Awe
    cinematics[8].cgs[0].fpg_ruta = RUTA_FPG_CG018;
    cinematics[8].cgs[0].pal_ruta = RUTA_FPG_CG018;
    cinematics[8].cgs[0].wav_ruta = RUTA_WAV_CG004;
    cinematics[8].cgs[0].num_paginas = 5;
    cinematics[8].cgs[0].paginas[0].linea1 = "Con el frente del Rin asegurado";
    cinematics[8].cgs[0].paginas[0].linea2 = "y Brest bajo control imperial,";
    cinematics[8].cgs[0].paginas[0].linea3 = "el Alto Mando lanza la operación";
    cinematics[8].cgs[0].paginas[0].linea4 = "más audaz de la guerra.";
    cinematics[8].cgs[0].paginas[1].linea1 = "La operación 'Shock and Awe'";
    cinematics[8].cgs[0].paginas[1].linea2 = "busca decapitar al enemigo";
    cinematics[8].cgs[0].paginas[1].linea3 = "de forma rápida y decisiva,";
    cinematics[8].cgs[0].paginas[1].linea4 = "rompiendo su coordinación.";
    cinematics[8].cgs[0].paginas[2].linea1 = "El Batallón 203 es lanzado";
    cinematics[8].cgs[0].paginas[2].linea2 = "dentro de cohetes V-1 experimentales,";
    cinematics[8].cgs[0].paginas[2].linea3 = "tecnología mágica de alta velocidad";
    cinematics[8].cgs[0].paginas[2].linea4 = "e indetectable.";
    cinematics[8].cgs[0].paginas[3].linea1 = "Primera fase: 'Door Knocker'";
    cinematics[8].cgs[0].paginas[3].linea2 = "Ataque directo al cuartel general";
    cinematics[8].cgs[0].paginas[3].linea3 = "enemigo para eliminar el liderazgo";
    cinematics[8].cgs[0].paginas[3].linea4 = "y atraer fuerzas a una emboscada.";
    cinematics[8].cgs[0].paginas[4].linea1 = "Segunda fase: 'Lockpick'";
    cinematics[8].cgs[0].paginas[4].linea2 = "Sabotaje y bombardeos para romper";
    cinematics[8].cgs[0].paginas[4].linea3 = "líneas defensivas y flancos.";
    cinematics[8].cgs[0].paginas[4].linea4 = "";

    // CG 1 - Tanya reflexionando
    cinematics[8].cgs[1].fpg_ruta = RUTA_FPG_CG019;
    cinematics[8].cgs[1].pal_ruta = RUTA_FPG_CG019;
    cinematics[8].cgs[1].wav_ruta = RUTA_WAV_CG004;
    cinematics[8].cgs[1].num_paginas = 1;
    cinematics[8].cgs[1].paginas[0].linea1 = "Tanya: Esta operación es un suicidio";
    cinematics[8].cgs[1].paginas[0].linea2 = "calculado. El riesgo es inmenso,";
    cinematics[8].cgs[1].paginas[0].linea3 = "pero el Imperio necesita";
    cinematics[8].cgs[1].paginas[0].linea4 = "terminar esta guerra ahora.";

    // Cinematica 9: post-nivel 11
    cinematics[9].num_cg = 1;
    cinematics[9].siguiente_nivel = 13;

    // CG 0 - La batalla final por Parise
    cinematics[9].cgs[0].fpg_ruta = RUTA_FPG_CG020;
    cinematics[9].cgs[0].pal_ruta = RUTA_FPG_CG020;
    cinematics[9].cgs[0].wav_ruta = RUTA_WAV_CG004;
    cinematics[9].cgs[0].num_paginas = 4;
    cinematics[9].cgs[0].paginas[0].linea1 = "Con el cuartel general enemigo";
    cinematics[9].cgs[0].paginas[0].linea2 = "del frente abatido, las fuerzas";
    cinematics[9].cgs[0].paginas[0].linea3 = "imperiales avanzan sin oposición";
    cinematics[9].cgs[0].paginas[0].linea4 = "hacia el corazón del enemigo.";
    cinematics[9].cgs[0].paginas[1].linea1 = "El objetivo final: Parise,";
    cinematics[9].cgs[0].paginas[1].linea2 = "la capital de François.";
    cinematics[9].cgs[0].paginas[1].linea3 = "La batalla decisiva que pondrá";
    cinematics[9].cgs[0].paginas[1].linea4 = "fin a esta interminable guerra.";
    cinematics[9].cgs[0].paginas[2].linea1 = "El Batallón 203, endurecido";
    cinematics[9].cgs[0].paginas[2].linea2 = "por años de combate, lidera";
    cinematics[9].cgs[0].paginas[2].linea3 = "el asalto final.";
    cinematics[9].cgs[0].paginas[2].linea4 = "La victoria está al alcance.";
    cinematics[9].cgs[0].paginas[3].linea1 = "Tanya: Después de tanto tiempo,";
    cinematics[9].cgs[0].paginas[3].linea2 = "finalmente podremos volver";
    cinematics[9].cgs[0].paginas[3].linea3 = "a una vida normal.";
    cinematics[9].cgs[0].paginas[3].linea4 = "Esta guerra termina aquí.";

    // Cinematica 10: fin del juego
    cinematics[10].num_cg = 1;
    cinematics[10].siguiente_nivel = 14;

    // CG 0 - Fin de la guerra
    cinematics[10].cgs[0].fpg_ruta = RUTA_FPG_CG021;
    cinematics[10].cgs[0].pal_ruta = RUTA_FPG_CG021;
    cinematics[10].cgs[0].wav_ruta = RUTA_WAV_ENDING;
    cinematics[10].cgs[0].num_paginas = 8;
    cinematics[10].cgs[0].paginas[0].linea1 = "Parise ha caído.";
    cinematics[10].cgs[0].paginas[0].linea2 = "Las fuerzas imperiales desfilan";
    cinematics[10].cgs[0].paginas[0].linea3 = "por las calles de la capital";
    cinematics[10].cgs[0].paginas[0].linea4 = "enemiga en triunfo absoluto.";
    cinematics[10].cgs[0].paginas[1].linea1 = "Las tropas de François,";
    cinematics[10].cgs[0].paginas[1].linea2 = "derrotadas pero no aniquiladas,";
    cinematics[10].cgs[0].paginas[1].linea3 = "se exilian al otro lado";
    cinematics[10].cgs[0].paginas[1].linea4 = "del Mediterráneo.";
    cinematics[10].cgs[0].paginas[2].linea1 = "Se firma un armisticio";
    cinematics[10].cgs[0].paginas[2].linea2 = "que pone fin temporal";
    cinematics[10].cgs[0].paginas[2].linea3 = "a las hostilidades.";
    cinematics[10].cgs[0].paginas[2].linea4 = "La Gran Guerra ha terminado.";
    cinematics[10].cgs[0].paginas[3].linea1 = "Tanya Degurechaff pasea";
    cinematics[10].cgs[0].paginas[3].linea2 = "por las calles conquistadas";
    cinematics[10].cgs[0].paginas[3].linea3 = "de Parise, reflexionando";
    cinematics[10].cgs[0].paginas[3].linea4 = "sobre el precio de la victoria.";
    cinematics[10].cgs[0].paginas[4].linea1 = "Tanya: Esta paz es frágil.";
    cinematics[10].cgs[0].paginas[4].linea2 = "Los exiliados regresarán,";
    cinematics[10].cgs[0].paginas[4].linea3 = "y con ellos, nuevas guerras.";
    cinematics[10].cgs[0].paginas[4].linea4 = "El ciclo nunca termina.";
    cinematics[10].cgs[0].paginas[5].linea1 = "Pero por ahora, el Imperio";
    cinematics[10].cgs[0].paginas[5].linea2 = "ha prevalecido.";
    cinematics[10].cgs[0].paginas[5].linea3 = "La 'Bruja del Imperio'";
    cinematics[10].cgs[0].paginas[5].linea4 = "ha cumplido su deber.";
    cinematics[10].cgs[0].paginas[6].linea1 = "Gracias por jugar.";
    cinematics[10].cgs[0].paginas[6].linea2 = "Esta ha sido la historia";
    cinematics[10].cgs[0].paginas[6].linea3 = "de Tanya en 'Tiny Hellwing'";
    cinematics[10].cgs[0].paginas[6].linea4 = "Basado en la obra de Carlo Zen.";
    cinematics[10].cgs[0].paginas[7].linea1 = "Le Hamster ruso, 2026.";
    cinematics[10].cgs[0].paginas[7].linea2 = "Proyecto creado como tutorial";
    cinematics[10].cgs[0].paginas[7].linea3 = "para enseñar a programar";
    cinematics[10].cgs[0].paginas[7].linea4 = "en MS-DOS. Sin ánimo de lucro";
END


//------------------------------------------------------------------------------
// FUNCION: cargar_recursos_juego
// DESCRIPCION: Carga los recursos globales del juego (FPG del jugador, fuentes, sonidos)
//------------------------------------------------------------------------------
FUNCTION cargar_recursos_juego()
BEGIN
    // Cargar FPG del jugador (el del nivel se carga en cargar_fpg_nivel)
    // FPG_LEVEL se cargara dinamicamente segun el nivel actual
    FPG_PLAYER = load_fpg(RUTA_FPG_PLAYER);
    FPG_PLAYERME = load_fpg(RUTA_FPG_PLAYERME);
    FPG_PLAYERLO = load_fpg(RUTA_FPG_PLAYERLO);

    // Cargar fuentes
    FNT_HUD = load_fnt(RUTA_FNT_HUD);
    FNT_NORMAL = load_fnt(RUTA_FNT_NORMAL);
    FNT_COUNTER = load_fnt(RUTA_FNT_COUNTER);
    FNT_PRESS = load_fnt(RUTA_FNT_PRESS);
    FNT_GAMEOVER = load_fnt(RUTA_FNT_GAMEOVER);
    FNT_COPY = load_fnt(RUTA_FNT_COPY);
    FNT_X = load_fnt(RUTA_FNT_X);

    // Cargar sonidos
    WAV_DISPARO = load_wav(RUTA_WAV_DISPARO, LOOP_NO); // LOOP_NO = Reproducción normal
END

//------------------------------------------------------------------------------
// FUNCION: iniciar_nueva_partida
// DESCRIPCION: Inicializa y comienza una nueva partida desde el principio
//              - Muestra pantalla de inicio y menu principal
//              - Carga recursos necesarios
//              - Ejecuta cinematica inicial
//              - Inicia el primer nivel
//------------------------------------------------------------------------------
FUNCTION iniciar_nueva_partida()
BEGIN
    // Mostrar pantalla de inicio con su propia paleta
    pantalla_inicio();

    // Cargar puntuaciones altas
    cargar_top_scores();

    // Mostrar menu principal
    menu_principal();

    // Cargar paleta del juego al empezar partida
    load_pal(RUTA_PALETA);   // Paleta disponible en DIV2

    // Cinematica inicial antes del nivel 1
    if (cinematica(0) == 1)
        RETURN;
    END

    // Mostramos los puntos y el nivel
    mostrar_textos_hud();

    // Inicializar sistema de niveles
    nivel_actual = NIVEL_INICIAL;
    num_enemigos_nivel = calcular_num_enemigos(nivel_actual);
    enemigos_vivos = num_enemigos_nivel;
    cargar_fpg_nivel(nivel_actual);

    // Iniciar el primer nivel
    // Esto llena la pantalla de enemigos y prepara el juego para empezar.
    // Tambien anade al jugador
    inicio_nivel();
END
