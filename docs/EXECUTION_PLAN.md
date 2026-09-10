# Plano de execução

Este documento é a referência para a ordem dos blocos de trabalho. O backlog registra o escopo do produto; o log de desenvolvimento preserva o histórico de cada data.

## Bloco 0 — Fundação do produto — concluído

- Criar o projeto Flutter, tema e navegação.
- Implementar o vertical slice inicial e as principais telas.
- Definir modelos, contratos, regras iniciais de Ranking e testes de base.

## Bloco 1 — Ambiente local reproduzível — concluído

- Validar Flutter, Dart, Java, Android SDK, Chrome e PostgreSQL.
- Criar e migrar o banco local `limitbreaker`.
- Automatizar a inicialização da API local durante o desenvolvimento.
- Validar testes, aplicação web e APK Android de depuração.

Commit de conclusão: `d92ad93` (`chore: validate local development environment`).

## Bloco 2 — Backend local do onboarding e sugestões — concluído

- Persistir objetivo, modalidades, atividade, histórico familiar, limitações e consentimento.
- Calcular e armazenar o perfil de treino no servidor.
- Gerar e persistir sugestões predefinidas por modalidade e perfil.
- Integrar os fluxos Flutter com endpoints autenticados.
- Validar cadastro, onboarding, criação e consulta de sugestão em um ciclo descartável.

## Bloco 3 — Completar treinos e perfil — próximo

- Implementar edição de treinos e perfil.
- Consolidar recordes por modalidade.
- Adicionar imagens e orientações de execução quando houver conteúdo aprovado.
- Refinar acessibilidade em leitores de tela e dispositivos reais.

## Bloco 4 — Social, conquistas e Ranking real

- Persistir convites, amizades, grupos e conversas.
- Completar conquistas e sua influência explícita no Ranking.
- Substituir valores simulados por pontuação originada de registros reais.
- Implementar QR e notificações quando a infraestrutura estiver definida.

## Bloco 5 — Backend remoto

- Definir arquitetura de sincronização, retenção, exclusão e LGPD.
- Migrar ou sincronizar o armazenamento com o backend remoto escolhido.
- Configurar Google OAuth, callbacks e deep links sem segredos no Flutter.
- Adicionar fotos e recursos em tempo real.

## Bloco 6 — Inteligência e integrações futuras

- Avaliar IA para personalização somente por meio do backend.
- Avaliar relógios, Google Fit, Apple Health e demais integrações fora do MVP.

## Decisões necessárias

- Normalização oficial e regra para menos de três modalidades no Ranking.
- Questionários e textos jurídicos definitivos.
- Política de retenção e exclusão de dados sensíveis.
- Backend remoto e estratégia de migração ou sincronização.
