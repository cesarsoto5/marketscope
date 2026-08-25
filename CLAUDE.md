# ETHFI Monitor de Ruptura Pro — Contexto del proyecto

## Qué es
App de análisis de trading en tiempo real para el token **ETHFI (ether.fi)**, construida como una sola página HTML (`app/index.html`, 1864 líneas). Originalmente desarrollada con otra IA (Kimi) a partir de consultas manuales de análisis de mercado.

## Origen / evolución
El proyecto nació de una serie de prompts de análisis manual:
1. "Revisa libros de órdenes, mapas de calor... ¿llegará ETHFI a $0.50?"
2. "¿Cuál sería la señal para romper con fuerza?"
3. "Sigue sin romper $0.465, ¿se debilita el impulso?"
4. "¿Puedes traer datos de BingX?"
...hasta convertirse en una app web completa.

## Posición del usuario (genérico)
La app NO trae ninguna posición hardcodeada: debe funcionar de forma genérica para cualquier usuario. La posición (tokens + precio promedio) se ingresa por onboarding en modo "holder" y se guarda en `localStorage`; el modo "watcher" no requiere posición. No introducir valores de posición concretos en el código ni en esta documentación.

## Estructura de archivos
- `app/index.html` — **archivo principal activo** (1864 líneas) — aquí van todos los cambios
- `ethfi-monitor/index.html` — copia idéntica (respaldo, verificado con diff)
- `Monitor_ETHFI.html.txt` — copia idéntica (respaldo/exportación)
- `analisis_ETHFI_2026-07-18.md` — análisis manual de mercado del 18-jul-2026
- `plan.md` — plan de análisis original de la IA

---

## Funcionalidades de la app

### Datos de mercado (actualiza cada 12s)
- Precio spot + cambio 24h desde Binance (fallback Gate.io)
- BTC y ETH como contexto macro
- Velas 5m (gráfico de velas con EMA20/EMA50 en canvas)
- MACD en panel separado bajo el gráfico
- RSI(14) multi-temporalidad: 1h, 4h, 1d con sparkline

### Libros de órdenes (agregado multi-exchange)
13 exchanges: Binance, Gate.io, Bybit, OKX, KuCoin, MEXC, Coinbase, Kraken, Bitget, BingX, HTX, Crypto.com, Gate Futures
- Ladder visual ask/bid con barras proporcionales
- Barra "batalla" bids vs asks
- Mapa de calor del libro (canvas, actualiza cada 12s)

### Ballenas (≥10K ETHFI)
- Spot: Binance, Gate.io, Bybit, OKX
- Futuros: Binance Fut, Gate Fut, Bybit Fut, OKX Fut, Bitget Fut
- Timeline canvas con zoom 1h/4h/8h
- Alertas push del navegador para mega-ballenas (≥75K)
- Persistencia en localStorage (12h de historia)
- Relleno anti-huecos en pumps (recupera IDs saltados con `fromId`, máx 3 hops)

### Análisis técnico / decisión
- **Momentum score** (0-100): precio vs niveles + volumen + flujo + libro + mínimos ascendentes + RSI + macro + MACD
- **Niveles dinámicos**: pivotes diarios, pivotes 4h, nodos de volumen, números redondos — recalculados cada ~2 min
- **Motor de decisión** con acciones personalizadas según posición del usuario
- **Banner de estado**: ROMPIENDO / ATACANDO / EN RANGO / ALERTA / DEFENSA

### Pronóstico y ciclos
- Detección de ciclos impulso/enfriamiento (pumps ≥8% en datos diarios)
- Pronóstico 24-72h por modelo de reglas (probabilidad up/range/down + rango estimado)

### Sentimiento y fundamentos
- Sentimiento Binance Futures: ratio long/short top traders, global, taker buy/sell, funding, OI, liquidaciones
- Fundamentos: CoinGecko (MC, FDV, supply, ATH/ATL, cambios 7d/30d), DefiLlama (TVL, fees 24h/7d)
- Miedo y Codicia: alternative.me
- Noticias: Google News RSS últimas 48h

### UX
- Onboarding con modo "holder" (posición propia) o "watcher" (solo análisis)
- Posición guardada en localStorage; sugerencias de acción personalizadas al PnL en tiempo real
- Diagnóstico de conexión desplegable
- Sistema de proxy fallback (allorigins.win → codetabs.com → corsproxy.io)
- Tooltips en mapa de calor y timeline de ballenas
- Sesiones de mercado en el gráfico (Asia / Londres / LON+NY / NY)
- Ayudas contextuales desplegables ("ⓘ ¿qué es esto?")

---

## Configuración clave en el código

```js
const COIN={sym:'ETHFI',pair:'ETHFIUSDT',cg:'ether-fi',llama:'ether.fi',fb:'E'};
// Cambiar estas 5 claves adapta la app completa a otro token
const WHALE_Q=10000, MEGA_Q=75000;  // umbrales ballenas (calibrados en p99 ≈ 7K de ETHFI)
```

### Niveles de respaldo (FB_RES / FB_SUP)
Se usan solo si el cálculo dinámico aún no corrió o falló:
```js
FB_RES: [{p:0.453},{p:0.465},{p:0.48},{p:0.50}]  // resistencias
FB_SUP: [{p:0.446},{p:0.431},{p:0.41},{p:0.376}]  // soportes
```

---

## APIs utilizadas

### Precio / ticker
- Binance: `GET /api/v3/ticker/24hr?symbol=ETHFIUSDT` (6 mirrors: api1–api4 + data-api.binance.vision)
- Gate.io spot fallback: `GET /api/v4/spot/tickers?currency_pair=ETHFI_USDT`

### Velas (klines)
- `5m limit=96` — gráfico principal (~8h de historia)
- `1d limit=21` — volumen promedio 20d
- `4h limit=120` — RSI 4h + pivotes 4h
- `1h limit=72` — RSI 1h + sparkline 48 puntos
- `1d limit=90` — ciclos + ATR + niveles dinámicos
- Todos tienen fallback a Gate.io

### Libros de órdenes
```
Binance:    /api/v3/depth?symbol=ETHFIUSDT&limit=1000
Gate.io:    /api/v4/spot/order_book?currency_pair=ETHFI_USDT&limit=100
Bybit:      /v5/market/orderbook?category=spot&symbol=ETHFIUSDT&limit=200
OKX:        /api/v5/market/books?instId=ETHFI-USDT&sz=100
KuCoin:     /api/v1/market/orderbook/level2_100?symbol=ETHFI-USDT
MEXC:       /api/v3/depth?symbol=ETHFIUSDT&limit=500
Coinbase:   /products/ETHFI-USD/book?level=2
Kraken:     /0/public/Depth?pair=ETHFIUSD&count=100
Bitget:     /api/v2/spot/market/orderbook?symbol=ETHFIUSDT&limit=100
BingX:      /openApi/spot/v1/market/depth?symbol=ETHFI-USDT&limit=100
HTX:        /market/depth?symbol=ethfiusdt&depth=150&type=step0
Crypto.com: /exchange/v1/public/get-book?instrument_name=ETHFI_USD&depth=100
Gate Fut:   /api/v4/futures/usdt/order_book?contract=ETHFI_USDT&limit=100
```

### OI + Funding
- Gate Futures ticker: `GET /api/v4/futures/usdt/tickers?contract=ETHFI_USDT`
- Binance FAPI: `/fapi/v1/openInterest`, `/fapi/v1/premiumIndex`, `/fapi/v1/fundingRate`

### Flujo taker (aggTrades)
- Binance spot: `/api/v3/aggTrades?symbol=ETHFIUSDT&limit=1000`
- Binance Futures: `/fapi/v1/aggTrades?symbol=ETHFIUSDT&limit=1000`
- Ambos incluyen relleno anti-huecos en pumps (hasta 3 hops con `fromId`)

### Ballenas — trades recientes
- Spot: Binance aggTrades, Gate.io `/spot/trades`, Bybit `/v5/market/recent-trade?category=spot`, OKX `/market/trades`
- Futuros: Binance Fut aggTrades, Gate Fut `/futures/usdt/trades`, Bybit Fut `category=linear`, OKX Fut SWAP (ctVal cacheado), Bitget Fut `/mix/market/fills`

### Sentimiento Binance Futures (se refresca cada 60s)
- `/futures/data/topLongShortPositionRatio?symbol=ETHFIUSDT&period=1h&limit=1`
- `/futures/data/globalLongShortAccountRatio?symbol=ETHFIUSDT&period=1h&limit=1`
- `/futures/data/takerlongshortRatio?symbol=ETHFIUSDT&period=1h&limit=1`
- Liquidaciones: Bybit `/v5/market/liquidation?category=linear` (fallback Gate.io `/futures/usdt/liquidates`)

### Fundamentos (se refresca cada ~9.5 min)
- CoinGecko: `GET /api/v3/coins/ether-fi` (MC, FDV, supply, ATH/ATL, chg 7d/30d, icono)
- DefiLlama: `GET /protocol/ether.fi` (TVL histórico, variación 7d)
- DefiLlama fees: `GET /summary/fees/ether.fi?dataType=dailyFees`
- CoinGecko global: `GET /api/v3/global` (dominancia BTC, cambio mcap total 24h)
- Miedo y Codicia: `GET alternative.me/fng/?limit=1`

### Noticias
- Google News RSS: `news.google.com/rss/search?q="ether.fi" OR "ETHFI" when:2d` — vía proxy allorigins.win

### Sistema de proxy fallback
1. Llamada directa
2. allorigins.win
3. codetabs.com
4. corsproxy.io

El proxy que funcionó por última vez se memoriza en `proxyIdx` para usarlo primero en el siguiente ciclo.

---

## Lógica técnica clave

### Momentum Score (0–100) — función `momentum()`
```
precio vs resistencia dinámica r0:  hasta +26 pts
volumen hoy vs media 20d:           hasta +20 pts (ratio × 14, cap 20)
flujo taker buy/sell:               hasta +15 pts (flow/1.6 × 15)
balance bid/ask ±1.5% del precio:   hasta +15 pts ((imb+1)/2 × 15)
mínimos ascendentes (últimas 2h):   +10 o +3 pts
RSI 1h < 70:                        +3 o -4 pts
BTC positivo 24h:                   +4 pts
ETH positivo 24h:                   +4 pts
EMA state (EMA20 > EMA50):          +4 o -3 pts; +2 si precio sobre EMA20
MACD histograma > 0:                +3 o -3 pts
Total: clamp [0, 100]
```

Etiquetas del score:
- 70–100: "Rompiendo con fuerza" (verde)
- 50–69: "Avanzando con pausa" (ámbar)
- 35–49: "Enfriándose" (ámbar)
- 0–34: "Debilitándose" (rojo)

### Contexto de mercado — función `marketContext()` (lectura de trader)
Capa que sintetiza **tendencia + momentum + flujo + ballenas + macro + crowding** en un sesgo direccional `-100..+100` que el motor de decisión consulta ANTES de sugerir entradas. Evita el error clásico de recomendar "compra por valor" en un soporte mientras el precio cae con fuerza (atrapar el cuchillo).
- `swingStruct()`: pivotes swing en 5m (~4h, ventana 3) → máximos/mínimos ascendentes o descendentes (`dir` −1/0/+1)
- Factores ponderados en el sesgo: estructura swings (±18), EMAs 5m + cruce (±12/±6), cambio 24h (±14/±7), posición en el rango del día (±8), **precio vs VWAP de sesión (±6)**, MACD (±7/±3), RSI 1d/1h (±6/±5/±4), flujo taker (±8), **balance del libro ±1.5% (`bookSums`, ±8)**, ballenas spot/fut 1h (±8/±5), macro BTC/ETH (±7), crowding long/short + funding (±4/±2). Nota: el libro se pesa solo cerca del precio (±1.5%), no la profundidad total, porque las órdenes lejanas suelen ser spoofing
- `regime`: TENDENCIA BAJISTA (≤−35) · CORRECCIÓN/DÉBIL (≤−15) · RANGO/INDECISIÓN · ALCISTA MODERADO (≥15) · TENDENCIA ALCISTA (≥35)
- `phase`: caída con presión vendedora / caída en curso / rebote sin confirmar / impulso alcista
- `fallingKnife`: bias ≤−25 **y** (chg 24h ≤−4% con precio en el cuarto inferior del rango) → bloquea sugerencias de compra en soportes
- `stance` (postura): `bearish` / `turn` / `neutral` / `buy` — usada para avisar cambios de estado
- Devuelve además `pros`/`cons` (top 4 razones alcistas/bajistas, en lenguaje llano) mostradas como "Lectura: …" en las sugerencias

### Señales de giro — función `turnSignals(posInRng)`
Detecta ACTIVAMENTE si la caída se está agotando (hasta 4 señales): RSI 1h girando desde sobreventa (usa `S.rsi1hSer`), cruce EMA alcista fresco / precio recuperó EMA20, MACD cruzando al alza o histograma bajista menguando, flujo taker girando a comprador con precio fuera de mínimos, mínimos ascendentes (5m), ballenas spot comprando la caída (30m), precio recuperando el tercio alto del rango. Devuelve `{cues, n}`.
- En `decision()`: con **≥2 señales** en plena caída → cambia de "no atrapes el cuchillo" a **"⚡ Agotamiento a la vista"** con compra escalonada (25–33%) y stop; con 1 señal avisa "(1 señal presente, falta confirmar)"; en rango neutral con ≥2 señales → **"Giro alcista tomando forma"**

### Aviso de cambio de estado — `stanceNotify(ctx)` (en `drawDecision`)
Compara `ctx.stance` con `lastStance` (rank bearish<neutral<turn<buy). Cuando MEJORA (de bearish/neutral a turn/buy) dispara un `dlog` + **notificación push del navegador** (si alertas ON). Solo salta en la transición, no cada tick. Reutiliza el toggle 🔔 de alertas de ballenas.

### Motor de decisión — función `decision()`
**Banner:**
- Precio ≥ r0 × 1.003 → ROMPIENDO
- Precio ≥ r0 × 0.995 → ATACANDO (verde si momentum ≥60, ámbar si no)
- Precio ≥ s0 × 0.998 → EN RANGO
- Precio ≥ s1 × 0.998 → ALERTA (soporte perdido)
- Else → DEFENSA
- **Override**: si `marketContext` es fallingKnife o sesgo ≤−35 y el precio no está atacando r0 → banner pasa a **CAÍDA · <régimen>** (rojo), sobre-escribiendo "EN RANGO"

**Modo análisis (sin posición)** — usa el régimen para decidir el tono:
- Cuchillo cayendo / sesgo ≤−25 → "No atrapes el cuchillo": objetivos bajistas s0→s1→s2, exige señal de agotamiento; los soportes son zona de VIGILANCIA, no compra automática
- Sesgo ≥+25 (tendencia sana) → compra en retroceso con R:R hacia la resistencia
- Rango → compra solo si el precio LLEGA al soporte y rebota (no anticipar)

**Acciones modo holder (con posición):**
- Precio ≥ $0.495 → "VENDE 40% ahora"
- Precio ≥ $0.48 → "VENDE 30% ahora"
- Ataque fuerte a r0 (momentum ≥60) → "Mantén TODO"
- En soporte s0 → "Mantén"
- Soporte perdido → "Reduce la MITAD si 1h cierra bajo $s1"
- Condiciones de add (soporte firme + flujo ≥1 + volumen ≥1× + higherLows) → alerta de añadir

### Niveles dinámicos — función `computeLevels()` (cada ~2 min)
1. Descarga velas diarias 90d y 4h 120 velas
2. Pivotes diarios (ventana 2, sobre últimas 45 velas) y 4h (ventana 4, sobre últimas 90 velas)
3. Perfil de volumen 30d: precio típico (h+l+c)/3 redondeado a 0.005, top 8 nodos
4. Números redondos: 0.40, 0.45, 0.50
5. Clustering: agrupa candidatos dentro del 0.6% (media ponderada por score)
6. $0.50 siempre forzado en resistencias si no hay ninguna cerca
7. Resultado: hasta 6 resistencias y 6 soportes dinámicos

### RSI(14) — implementación Wilder EMA
- 1h: 72 velas; sparkline de las últimas 48 velas
- 4h: 120 velas
- 1d: 90 velas

### ATR(14) — True Range diario
Usado para el rango estimado del pronóstico: `rango = mid ± ATR × 1.7`

### Detección de ciclos — función `detectCycles()`
- Identifica velas diarias con pump ≥ 8% respecto al día anterior
- Para cada pump: localiza el pico (max high en los 5 días siguientes) y el valle (min low hasta el siguiente pump)
- Registra: fecha pump, % subida, precio pico, fecha pico, precio valle, fecha valle, días de enfriamiento, % enfriamiento

### Pronóstico 24-72h — función `forecast()`
Modelo de reglas sobre probabilidades base (up=30, rango=30, down=30):
- Ciclos: máximos/mínimos ascendentes entre últimos 3 ciclos → ±10/6 pts
- Profundidad de enfriamiento vs promedio histórico → ±8/4 pts
- Ventana temporal (días 3–9 desde el último pico) → +4 pts
- RSI 1d alcista (52–68) → +6/-3; sobrecompra (>72) → +7 a la baja; sobreventa (<35) → +5
- RSI 1h sobreventa (<32) → +5; sobrecompra (>72) → +4 a la baja
- Flujo taker ≥1.05 → +5/-3; ≤0.85 → +5/-3 a la baja
- Balance libro >8% bids → +5/-2; >8% asks → +5/-2 a la baja
- Mínimos ascendentes → +4/-2
- BTC+ETH en verde → +3/-2; BTC+ETH rojos >-1% → +4/-2 a la baja
- Long ratio top traders ≥62% → +3 a la baja; ≤42% → +3 al alza
- Miedo extremo F&G ≤20 → +2
- TVL creciendo >2% 7d → +2

### Gráfico de velas (canvas `#chart`, 360px alto)
- Canvas 2D con DPR para pantallas Retina
- Sesiones de mercado como fondos de color (UTC):
  - Asia 00–07: casi invisible
  - Londres 07–13: azul muy sutil
  - LON+NY 13–15: morado muy sutil (máximo volumen del día)
  - NY 15–21: ámbar muy sutil
- EMA20 (turquesa `#4fd1c5`) y EMA50 (morado `#b982ff`)
- **VWAP de sesión** (azul `#8ab4f8`): precio medio ponderado por volumen, anclado a la medianoche UTC (o al inicio de la ventana si no está). Se guarda en `S.vwap` y alimenta `marketContext()` (precio vs VWAP = ±6 al sesgo)
- **Líneas de tendencia automáticas** (punteadas): une los 2 últimos swings de máximos (roja = techo) y de mínimos (verde = piso), ventana de pivote 3, proyectadas al borde derecho. Flecha (↗/↘/→) según pendiente real. Etiqueta pequeña ("techo"/"piso") tipo chip en el ARRANQUE de la línea (no tapa el precio actual)
- **Franja guía `#tlGuide`** (bajo el canvas): traduce las líneas a lenguaje llano y **consulta `marketContext()`** para ser consistente con la tendencia — p.ej. "precio entre piso y techo" en tendencia bajista dice "manda la tendencia, no es zona de compra" en vez de "en pausa". Detecta: tocando techo/piso, rayas juntándose (triángulo), o entre ambas; ícono ⚠️/🚀/✏️ según fuerza del sesgo. Función `tlGuide(tHi,tLo,p)`
- Línea punteada ámbar = precio actual con etiqueta
- Línea blanca punteada = precio promedio del usuario ("tú")
- Línea punteada ámbar tenue = objetivo $0.50
- Zonas resistencia (rojo 13% opac) y soporte (verde 12% opac)
- Marcadores de ballenas ≥25K: triángulos verde▲ (compra) / rojo▼ (venta), agrupados por proximidad ~34px; anillo blanco = mega (≥75K); ×N si hay varias juntas
- `WMARK_ON` controla si se muestran (botón "ballenas: ON/OFF" en leyenda)

### MACD (canvas `#macd`, 66px alto)
- Histograma (barras verde/rojo) + línea MACD (turquesa) + línea señal (ámbar)
- Detecta último cruce y si el histograma está creciendo o menguando
- Estado guardado en `S.macdState` para uso en momentum y decisión

### Mapa de calor del libro (canvas `#heat`, 250px alto)
- Snapshot del libro cada 12s (columna de 12px de ancho)
- Brillo ∝ tamaño de la orden; verde = bids, rojo = asks
- Línea ámbar = precio actual
- Tooltip al pasar el mouse: nivel de precio y tamaño exacto de la orden
- Botón "limpiar historial" borra snapshots acumulados

### RSI sparkline (canvas `#rsiSpark`, 86px alto)
- Línea ámbar del RSI 1h sobre las últimas 48 velas
- Bandas de color de fondo: verde <30 (sobreventa), rojo >70 (sobrecompra)

### Timeline de ballenas (canvas `#wtl`, 170px alto)
- Triángulos para futuros (LONG verde ▲ / SHORT rojo ▼), círculos para spot
- Tamaño del símbolo ∝ monto en USDT
- Anillo blanco = mega-ballena (≥75K)
- Zoom: 1h / 4h / 8h (botones)
- Tooltip: tipo, exchange, precio, cantidad, liquidación estimada (asume 20x, muestra también 10x/50x)
- Cinta (`#wtape`): lista de las últimas ~10 ballenas en dos columnas

---

## Persistencia localStorage
| Clave | Contenido |
|---|---|
| `ethfi_profile` | modo (holder/watcher) + tokens + avg |
| `ethfi_pos` | posición antigua (migración desde versiones previas) |
| `ethfi_snap` | snapshot del último tick (precio, chg, BTC, ETH) |
| `ethfi_whales_v1` | hasta 400 ballenas, ventana 12h (debounce 3s + pagehide) |
| `ethfi_notif` | '1' si alertas push activadas |

## Estado global (objeto `S`)
Todas las variables de estado viven en el objeto `S`:
```js
S = {
  price, chg, high, low, vol24,       // ticker
  candles[],                           // velas 5m
  books{},                             // libros por exchange
  exStatus{},                          // qué exchanges respondieron
  flow, flowSpan,                      // flujo taker
  volAvg20, volToday,                  // volumen vs media
  oi, oi0, funding,                    // derivados
  btc, btcChg, eth, ethChg,           // macro
  lastUpd,
  days[], h4[],                        // velas diarias y 4h
  atr, cycles[],                       // ATR y ciclos detectados
  rsi1h, rsi4h, rsi1d, rsi1hSer[],   // RSI multi-TF
  whales[], whaleSeen{},              // ballenas
  sent{}, sentT,                       // sentimiento futuros
  fund{}, fundT,                       // fundamentos
  whaleSrc{}, whaleSrcT,              // qué exchanges de ballenas respondieron
  emaState, macdState,                 // estado técnico calculado en drawChart/drawMacd
  vwap,                                // VWAP de sesión (calculado en drawChart, usado en marketContext)
  curSess,                             // sesión de mercado actual (ASIA/LON/LON+NY/NY)
  perpAggId, spotAggId,               // último ID de aggTrades para relleno anti-huecos
  okxCt,                               // ctVal de OKX SWAP (cacheado)
  futVol,                              // volumen futuros Gate 24h
}
```
