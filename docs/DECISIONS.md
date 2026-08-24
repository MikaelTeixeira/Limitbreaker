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

## ADR-009 — Acesso local manual antes de OAuth

Cadastro e login locais usam nome de usuário ou e-mail e senha por uma API local. Senhas são armazenadas exclusivamente em hash bcrypt; o Flutter mantém somente o token de sessão no armazenamento seguro do dispositivo. Google OAuth permanece pendente de credenciais e callbacks próprios.

## ADR-010 — Quinze estágios de Ranking

O Ranking apresenta Bronze, Prata, Ouro, Diamante e Platina, cada qual com três estágios crescentes (I, II e III). Enquanto a normalização por modalidade estiver em evolução, as faixas usam a escala normalizada 0–100 dividida igualmente entre os 15 estágios.

## ADR-011 — Administração autorizada pelo servidor

O tipo de conta fica em `users.user_type`, com os papéis `standard` e `administrator`. A tela administrativa é separada da navegação comum, mas as operações críticas também exigem uma sessão de administrador validada na API.
