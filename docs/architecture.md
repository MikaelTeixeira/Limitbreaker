# Arquitetura

## Direção

O aplicativo é 100% Flutter/Dart, mobile-first e preparado para Android e iOS. A arquitetura é feature-first, com separação suficiente para substituir mocks por integrações reais sem transformar a primeira fase em uma Clean Architecture burocrática.

## Camadas

- `presentation`: telas, widgets, navegação e estados visuais.
- `domain`: regras puras, como o cálculo de Ranking.
- `data/application`: cliente de API, contratos, implementações locais/mock e providers Riverpod.
- `core/shared`: design system, componentes reutilizáveis e modelos transversais.

## Estrutura simplificada

Os modelos e repositórios compartilhados ficam divididos por responsabilidade, mas mantêm arquivos índice para facilitar imports:

- `shared/models/models.dart` exporta arquivos menores como `user_profile.dart`, `health_models.dart`, `workout_models.dart` e `social_models.dart`.
- `shared/repositories/repositories.dart` exporta contratos, providers e implementações locais.

Um guia arquivo por arquivo fica em [estrutura do código](code-structure.md).

## Dependências e fluxo

Os widgets consomem providers Riverpod. Providers expõem contratos de repositório, hoje implementados por `LocalAppRepository` ou `LocalOnboardingRepository`. Ele inicia vazio e só contém dados criados durante a sessão. A apresentação não conhece banco, API ou detalhes de armazenamento. O PostgreSQL local `limitbreaker` já possui migrações em `database/migrations/`; a conexão será feita por API autenticada, nunca diretamente pelo aplicativo Flutter.

GoRouter declara o fluxo `/` → `/welcome` ou `/home`; as rotas principais usam uma navegação inferior com Início, Ranking, Amigos, Conquistas e Perfil. Não existe barra lateral.

## Design system

O sistema visual fica em `app/theme/app_theme.dart` e centraliza cores, espaçamento, tipografia, cards, inputs e botões. A paleta usa preto-vazio, carbono, grafite, aço, branco-osso e um acento frio discreto. A assinatura visual é uma fratura angular e uma silhueta abstrata desenhadas com `CustomPainter`, evitando dependência de assets externos.

## Evolução planejada

- Separar repositórios mock por feature quando cada módulo ganhar regras próprias.
- Adicionar estados tipados de aplicação para edição de treinos e atividades.
- Definir backend e autenticação somente após decisão técnica explícita.
- Manter saúde isolada, sem logs de respostas sensíveis e sem analytics desses campos.
- Implementar Google Auth na Fase 4 via Supabase Auth. O Client Secret OAuth ficará exclusivamente no provedor/backend; o Flutter nunca o armazenará.
