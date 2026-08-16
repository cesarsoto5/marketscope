# Plan — Análisis ETHFI (ether.fi) ¿llegará a $0.50?

## Contexto
- Usuario con posición en ETHFI: $3,880.44 invertidos, precio promedio $0.456.
- Fecha actual: 2026-07-18. Evento mencionado: sesión con inversionistas el 30 de julio.
- Objetivo: revisar libros de órdenes, "mapas de calor", flujos de entrada/salida y noticias; evaluar probabilidad de que ETHFI alcance $0.50 en los próximos días.

## Etapa 1 — Datos cuantitativos de mercado (yo, en paralelo)
- Precio spot y estadísticas 24h: Binance API pública (fallback: OKX, Bybit, KuCoin, CoinGecko).
- Libros de órdenes agregados (Binance spot + futuros, OKX, Bybit, KuCoin): detectar muros de compra/venta, soportes y resistencias, distancia a $0.50.
- Datos de derivados (proxy de "mapa de calor"/apalancamiento): open interest, funding rate, ratios long/short, volumen taker buy/sell.
- Velas recientes (1h/4h/1d) para tendencia y niveles clave.
- Cotización de referencia con plugin Yahoo Finance (ETHFI-USD) para citar dato factual.

## Etapa 2 — Noticias y sentimiento (subagente explore, en segundo plano)
- Verificar noticia de X sobre sesión con inversionistas el 30 de julio.
- Noticias recientes de ether.fi (buybacks, roadmap, TVL, listados, FUD).
- Sentimiento general en X/cripto media sobre ETHFI.

## Etapa 3 — Integración y respuesta (español)
- Cruzar datos: niveles del libro vs. $0.50, flujos, derivados, catalizador del 30-jul.
- Escenarios (alcista/base/bajista) con niveles concretos y probabilidades cualitativas.
- Advertencias: limitaciones (Coinglass/on-chain sin API key), no es asesoría financiera.
- Citas de fuentes con fecha para cada dato factual.
