# Backlog

## Estado consolidado

- Fase 1 — Fundação e vertical slice: concluída.
- Fase 2 — Treinos e atividades: concluída no fluxo principal; edição, imagens e recordes ampliados permanecem pendentes.
- Fase 3 — Social e conquistas: em desenvolvimento.
- Fase 4A — Backend local: concluída para autenticação, perfil autenticado e persistência de treinos.
- Fase 4B — Backend remoto: planejada; inclui Supabase, Google OAuth, sincronização ampliada, fotos e tempo real.
- Fase 5 — Inteligência e personalização: fora do escopo imediato.

## Implementado — Fase 1

- Projeto Flutter Android/iOS e design system provisório.
- Abertura com fade, boas-vindas e onboarding local.
- Navegação inferior com cinco destinos.
- Dashboard, Ranking, Amigos, Conquistas e Perfil demonstrativos.
- Ranking ponderado e dois gráficos poligonais.
- Contratos de repositório, mocks e estados de loading/erro/vazio essenciais.
- Testes de domínio, fluxo e regressão visual.

## Próximo

- Revalidação do build APK no toolchain Android local.
- Refinamento de acessibilidade com leitores de tela reais.
- Persistir onboarding e sugestões de treino na API local PostgreSQL.
- Fase 3: convites locais, amizades, chat demonstrativo e conquistas completas.
- Completar edição de treinos e perfil, imagens de execução e recordes por modalidade.
- Sugestão de treino: usar rotinas pré-definidas conforme as preferências até a contratação de uma chave de API; depois substituir por IA via backend, sem chave no Flutter.

## Planejado — Próximas fases

- Fase 3: convites, QR real, chat, grupos, conquistas completas e notificações.
- Fase 4B: Supabase, Google OAuth, sincronização ampliada, fotos e tempo real.

## Pendente de decisão

- Normalização oficial por modalidade.
- Regra oficial para menos de três categorias.
- Questionários de saúde e histórico familiar.
- Textos jurídicos, níveis e nomes de Ranking.
- Arquitetura do backend remoto, migração/sincronização com Supabase e política formal de LGPD.
- Credenciais OAuth do Google, URLs de callback e deep links para Android/iOS.

## Fora do MVP

- Pagamentos, anúncios, IA, diagnóstico, integrações com relógios, Google Fit/Apple Health, painel web e algoritmo fisiológico definitivo.
