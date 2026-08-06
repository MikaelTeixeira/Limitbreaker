# Sistema de Ranking

## Normalização

As categorias devem chegar a uma escala comparável de 0 a 100. Nesta fase, os mocks já fornecem valores normalizados e `PassThroughScoreNormalizer` apenas os limita à faixa válida. Critérios por modalidade permanecem pendentes.

## Seleção e fórmula

1. Normalizar todas as categorias.
2. Ordenar da maior para a menor.
3. Selecionar somente as três maiores.
4. Calcular: `(principal × 0,75) + (secundária × 0,15) + (terciária × 0,10)`.

Os pesos vivem em `RankingCalculator.weights`. O resultado contém total, categorias ordenadas, pesos aplicados, status, sinalização provisória e data do cálculo.

## Menos de três categorias

Com zero categorias, o status é `unavailable`. Com uma ou duas, o status é `provisionalInsufficientCategories`, o total oficial é nulo e os pesos não são redistribuídos. A decisão definitiva — aguardar, zerar ausentes, redistribuir ou classificar com pesos reduzidos — permanece pendente.

## Testes

Os testes cobrem ordenação, top 3, 75/15/10, exclusão de categorias inferiores, decimais, zero/uma/duas categorias e limites de 0 a 100.
