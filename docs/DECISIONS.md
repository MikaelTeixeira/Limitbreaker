# Decisões

## ADR-001 — Arquitetura feature-first proporcional

Escolhida separação por feature com domínio isolado somente onde há regra real. Evita acoplamento a backend sem criar abstrações vazias para cada widget.

## ADR-002 — Riverpod e GoRouter

Riverpod centraliza injeção e estados assíncronos; GoRouter fornece rotas declarativas. Não serão misturados outros padrões de estado/rota sem necessidade comprovada.

## ADR-003 — Persistência mínima

`shared_preferences` armazena somente a conclusão do onboarding. Respostas sensíveis não são persistidas nesta fase até existir estratégia de segurança e exclusão de dados.

## ADR-004 — Ranking provisório explícito

Com menos de três categorias, nenhum total oficial é calculado. O resultado tipado sinaliza insuficiência para que a interface não quebre nem transforme uma pendência de produto em regra definitiva.

## ADR-005 — Marca desenhada em Flutter

A fratura e a silhueta são `CustomPainter`, mantendo o produto integralmente Flutter, evitando assets externos e permitindo evolução visual por tokens.
