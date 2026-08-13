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

## ADR-006 — Perfil de treino por autorrelato conservador

O perfil de treino é uma classificação de produto baseada em respostas autorrelatadas, e não um diagnóstico. A classificação mais restritiva requer confirmação explícita de necessidade de treino muito leve/adaptado; condições e histórico familiar isolados não recebem interpretação clínica automática.

## ADR-007 — PostgreSQL atrás de uma API local

O PostgreSQL local é o armazenamento de desenvolvimento. O Flutter não se conecta a ele diretamente, pois isso exporia credenciais no APK e impediria controles de autorização. Uma API local autenticada fará a ponte até a futura migração para Supabase.

## ADR-008 — Sugestões pré-definidas antes de IA

Enquanto não houver uma chave de API e um backend seguro, as sugestões de treino usam rotinas pré-definidas e explicáveis com base na modalidade escolhida. A futura IA será chamada exclusivamente pelo backend; sua chave não será incluída no Flutter.

## ADR-009 — Interface de acesso sem autenticação simulada

Login e Registro existem como entradas de navegação durante os testes, mas não criam sessão, não aceitam senha e não afirmam autenticação. A persistência por usuário e qualquer gravação de dados sensíveis permanecem bloqueadas até a configuração de um provedor de identidade real.
