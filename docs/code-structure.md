# Estrutura do código

Este projeto usa uma organização simples por responsabilidade. A ideia é que o nome do arquivo já indique onde procurar cada assunto, sem exigir uma arquitetura grande demais para a fase atual.

## Entrada do aplicativo

- `lib/main.dart`: inicia o Flutter, prepara o Riverpod e carrega o aplicativo principal.
- `lib/app/app.dart`: configura o `MaterialApp`, o tema visual e o roteador.
- `lib/app/router/app_router.dart`: concentra as rotas de navegação, como login, onboarding, início, ranking, amigos, perfil, treinos e admin.
- `lib/app/theme/app_theme.dart`: define cores, fontes, botões, cards, campos e o tema escuro do app.

## Modelos compartilhados

- `lib/shared/models/models.dart`: arquivo índice. Ele só exporta os modelos menores para manter imports simples.
- `lib/shared/models/user_profile.dart`: dados principais do usuário, como e-mail, nome, idade, altura e peso.
- `lib/shared/models/sport_models.dart`: objetivos e modalidades esportivas do onboarding.
- `lib/shared/models/health_models.dart`: respostas de saúde, declarações, perfil de treino e consentimento.
- `lib/shared/models/workout_models.dart`: planos, exercícios, séries e sessões de treino.
- `lib/shared/models/activity_models.dart`: atividades esportivas, categorias, atributos de radar e recordes pessoais.
- `lib/shared/models/ranking_models.dart`: estruturas históricas e visuais relacionadas ao ranking.
- `lib/shared/models/achievement_models.dart`: conquistas e progresso de conquistas.
- `lib/shared/models/social_models.dart`: amigos, convites, conversas e mensagens.

## Dados e repositórios

- `lib/shared/data/local_api.dart`: cliente HTTP da API local. Faz login, cadastro, chamadas administrativas e criação/listagem de treinos autenticados.
- `lib/shared/repositories/repositories.dart`: arquivo índice. Ele exporta contratos, providers e implementações locais.
- `lib/shared/repositories/repository_contracts.dart`: define o que cada área precisa oferecer, como autenticação, perfil, treino, atividade, ranking, conquistas e amigos.
- `lib/shared/repositories/local_onboarding_repository.dart`: salva localmente se o onboarding já foi concluído.
- `lib/shared/repositories/local_demo_repository.dart`: implementação temporária em memória para telas que ainda não usam backend completo.
- `lib/shared/repositories/app_repository_providers.dart`: providers Riverpod que conectam telas aos repositórios e à API local.

## Regras de domínio

- `lib/features/onboarding/domain/training_profile_calculator.dart`: calcula o perfil de treino a partir das respostas de saúde e rotina.
- `lib/features/ranking/domain/ranking_calculator.dart`: normaliza categorias, ordena as três maiores e aplica os pesos 75%, 15% e 10%.
- `lib/features/exercises/data/exercise_catalog.dart`: catálogo provisório de exercícios e opções de atividades.
- `lib/features/workouts/data/in_memory_workout_repository.dart`: repositório em memória usado por testes e fluxos provisórios de treino.

## Telas

- `lib/features/auth/presentation/access_screens.dart`: telas de login e acesso.
- `lib/features/onboarding/presentation/onboarding_screen.dart`: fluxo de cadastro inicial e perguntas do onboarding.
- `lib/features/dashboard/presentation/dashboard_screen.dart`: tela inicial com resumo de progresso.
- `lib/features/ranking/presentation/ranking_screen.dart`: tela de pontuação e estágio do ranking.
- `lib/features/friends/presentation/friends_screen.dart`: tela social de amigos e convites.
- `lib/features/profile/presentation/profile_screen.dart`: dados e ações do perfil.
- `lib/features/workouts/presentation/workouts_screens.dart`: listagem e sessão de treinos.
- `lib/features/workouts/presentation/workout_registration_screen.dart`: registro manual de treinos e atividades.
- `lib/features/workouts/presentation/suggested_workout_screen.dart`: sugestão de treino.
- `lib/features/activities/presentation/activities_screen.dart`: histórico de atividades esportivas.
- `lib/features/exercises/presentation/exercises_screen.dart`: catálogo de exercícios.
- `lib/features/achievements/presentation/achievements_screen.dart`: conquistas.
- `lib/features/admin/presentation/admin_screen.dart`: administração de usuários, exercícios e eventos.

## Backend local

- `server/bin/server.dart`: API Dart local. Recebe `DATABASE_URL`, autentica usuários e acessa o PostgreSQL.
- `server/bin/initialize_database.dart`: comando para criar o banco local e aplicar migrações pendentes sem iniciar a API.
- `server/lib/database/local_database_initializer.dart`: camada de persistência que verifica a existência do banco, o cria quando necessário e controla as migrações aplicadas.
- `database/migrations/`: migrações do PostgreSQL local usado no desenvolvimento.
- `supabase/migrations/`: migrações separadas para uma futura integração Supabase.
